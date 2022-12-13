
local ss = SplatoonSWEPs
if not ss then return end

local TOLERANCE = 1e-9 -- Relative tolerance
function ss.isclose(a, b)
    return math.abs(a - b) <= math.max(
        TOLERANCE * math.max(math.abs(a), math.abs(b)), 0)
end

-- An implementation of "A New Placement Heuristic
-- for the Orthogonal Stock-Cutting Problem", but having two skylines.
function ss.MakeRectanglePacker(rectangles)
    -- Baseline (or skyline) definition to manage free space.
    -- It has origin (x = offset, y = height),
    -- length, and rectangle touching it.
    -- 
    --   offset   <----length---->
    -- ---------->|===baseline===|
    --            ^
    --            | height
    --            |
    --
    -- Rectangle packer has a list of baseline
    -- and it looks like the following:
    -- +--------+
    --          |          +--------
    --          |          |
    -- height-> @----------+
    --          <--length-->
    --          ^
    --        offset
    local function Baseline(offset, length, height, rectangle)
        return setmetatable({
            offset = offset,
            length = length,
            height = height,
            rectangle = rectangle,
            __type = "SplatoonSWEPsRectanglePackerBaseline",
        }, {__tostring = function(self)
            return string.format("(%6.2f, %6.2f) = %6.2f @ %s",
            self.offset, self.height, self.length, tostring(self.rectangle))
        end})
    end

    local function sortinputs(rects)
        for _, r in ipairs(rects) do
            if r.istall then r:rotate() end
        end
        table.SortDesc(rects)
    end

    local function generateRotatedIndices(rects)
        local rotatedIndices = {}
        for i = 1, #rects do rotatedIndices[i] = i end
        table.sort(rotatedIndices, function(i, j)
            if rects[i].height ~= rects[j].height then
                return rects[i].height > rects[j].height
            elseif rects[i].width ~= rects[j].width then
                return rects[i].width > rects[j].width
            else
                return i > j
            end
        end)
        return rotatedIndices
    end

    local t = {}
    local meta = {}
    function meta:__index(key)
        local sum = 0
        if key == "width" then
            for _, v in self.xbase() do sum = math.max(sum, v.value.height) end
            return sum
        elseif key == "height" then
            for _, v in self.ybase() do sum = math.max(sum, v.value.height) end
            return sum
        elseif key == "framesize" then
            return { self.width, self.height }
        elseif key == "maxsize" then
            return math.max(self.width, self.height)
        else
            return rawget(self, key)
        end
    end

    sortinputs(rectangles)
    t.dones        = {}
    t.optimized    = {}
    t.rects        = rectangles
    t.queue        = ss.MakeAVL()
    t.queueRotated = ss.MakeAVL()
    t.xbase        = ss.LinkedList()
    t.ybase        = ss.LinkedList()

    local rrects = generateRotatedIndices(t.rects)
    for i, r in ipairs(t.rects) do t.queue:insert(-r.width, i) end
    for _, i in ipairs(rrects) do t.queueRotated:insert(-t.rects[i].height, i) end
    t.xbase:append(Baseline(0, t.rects[1].width, 0))
    t.ybase:append(Baseline(0, t.rects[1].height, 0))

    -- Returns the smallest baseline, with respect to larger positional components.
    -- That means to select the following using a line y = x:
    -- 1. For ones in the area between y = x and x-axis, pick the leftmost one.
    -- 2. For ones in the area between y = x and y-axis, pick the lowest one.
    -- If these two choises have the same score, prefer_y is used to decide one.
    -- 
    -- y
    -- ^
    -- |  returns
    -- |  lowest one       /
    -- |---  v  ------  / y = x
    -- |   =====     /
    -- |          /  ||
    -- |       /     ||
    -- |    /      ||<= returns
    -- | /         ||   leftmost one
    -- +----------------------------> x
    local function pickLowest(a, b)
        if not a then return b end
        if not b then return a end
        local A = math.max(a.value.offset, a.value.height)
        local B = math.max(b.value.offset, b.value.height)
        return A < B and a or b
    end

    function t:getlowest(prefer_y)
        local xmin, ymin -- Calculated in O(N = # of baseline segments)
        for _, v in self.xbase() do xmin = pickLowest(xmin, v) end
        for _, v in self.ybase() do ymin = pickLowest(ymin, v) end

        -- Calculated in a constant time
        local xdist = math.max(xmin.value.offset, xmin.value.height)
        local ydist = math.max(ymin.value.offset, ymin.value.height)
        if xdist == ydist then
            return prefer_y and ymin or xmin, prefer_y, true
        elseif xdist > ydist then
            return ymin, true, false
        else
            return xmin, false, false
        end
    end

    -- Changes the given baseline "origin" to that of adjacent one to fill the gap.
    -- For x-baseline:
    --        Fills this baseline
    --     ------+     v
    --           |==========+---------
    --           |          |
    --           +----------+
    --           ^
    --         origin
    -- For y-baseline:
    --                         |
    --              +----------+
    --              |    ||
    --              |    || <= Fill this
    --              |    ||       baseline
    --    origin -> +-----+
    --                    |
    --                    |
    function t:fillline(origin)
        -- If the previous one exists,
        -- and it is higher than the current,
        -- and satisfying either of the following:
        -- (1) the following one does not exist
        -- (2) it is lower than the following one
        --                  +- - - - - +
        -- +-------+
        --         |        |
        --         +--------+
        local before, after = origin.before, origin.after
        local hbase = origin.value.height
        local hbefore = before and before.value.height
        local hafter = after and after.value.height
        if hbefore and hbefore >= hbase and not (
            hafter and hbefore >= hafter and hafter >= hbase) then
            before.value.length = before.value.length + origin.value.length
            before.value.height = hbefore
            origin:remove()
        -- Or vice-versa
        -- +- - - -+
        --                  +----------
        --         |        |
        --         +--------+
        elseif hafter and hafter >= hbase and not (
            hbefore and hafter >= hbefore and hbefore >= hbase) then
            after.value.offset = after.value.offset - origin.value.length
            after.value.length = after.value.length + origin.value.length
            after.value.height = hafter
            origin:remove()
        end

        -- Merge adjacent baselines if their height are the same
        -- +-------+        +----------
        --         |        |
        --         +--------+
        if hafter and hbefore and ss.isclose(hafter, hbefore) then
            before.value.length = before.value.length + after.value.length
            before.value.height = hbefore
            after:remove()
        end
    end

    -- Finds the best-fit rectangle for given length.
    -- y is set to true if this forcuses along y-baseline.
    -- Returns two values: index of the rectangle, rotation flag
    function t:findrect(length, y)
        local i = self.queue:lowerbound(-length)
        local j = self.queueRotated:lowerbound(-length)
        local width, height
        if i then
            width = self.rects[i.value].width
        end

        if j then
            height = self.rects[j.value].height
            if width and width < height then
                return j.value, not y
            end
        end

        if width then
            return i.value, y
        else
            return -1, false
        end
    end

    -- Find the next rectangle to be placed
    function t:findbestlocation()
        local prefer_y = false -- Which axis do we prefer if both are considered as candidate?
        while true do
            local x, is_y, alt = self:getlowest(prefer_y)
            local best, rotated = self:findrect(x.value.length, is_y)
            if best >= 0 then
                return x, best, rotated, is_y
            elseif alt and not prefer_y then
                prefer_y = true
            else
                prefer_y = false
                self:fillline(x)
            end
        end
    end

    -- Place given rectangle and apply changes to baselines
    -- ri:    Index of the rectangle
    -- xline: Baseline to be placed on
    -- is_y:  Is the baseline along y-axis?
    -- n:     Baseline that is prependicular to xline
    --     <-----rw---->     n
    --   ^ +-----------+     v
    --   | |           |     |
    --  rh | rectangle |      
    --   | |           |     |
    --   v +-----------+-----+-^- --- <- xline.parent
    --   ^ <-------Lx------->| |
    --   | ^                 | Ly
    --   | x                 | |
    --   |              y -> + v
    --   | hx                ^
    --   |                   hy
    function t:placebox(ri, xline, is_y)
        local r  = self.rects[ri]
        local n  = is_y and self.xbase or self.ybase
        local rw = is_y and r.height or r.width
        local rh = is_y and r.width or r.height
        local x  = xline.value.offset
        local Lx = xline.value.length
        local hx = xline.value.height
        local xend, hxend = x + rw, hx + rh
        local xbefore, xafter = xline.before, xline.after
        local xmax = math.max(1, x, Lx, hx, xend, hxend)

        for _, yline in n() do
            local y = yline.value.offset
            local Ly = yline.value.length
            local hy = yline.value.height
            local yend = y + Ly
            local ybefore = yline.before
            local eps = TOLERANCE * math.max(xmax, y, Ly, hy, yend)

            -- Ensure the baseline are not completely inside the following area
            -- ///////////////////////XXXX
            -- ///////////////////////XXXX
            --      +<------rw------>+\\\\
            --      ^                |\\\\
            --     rh                |\\\\
            --      v                |\\\\
            --      @<=(x, hx)-------+\\\\
            -- ///////////////////////XXXX
            -- ///////////////////////XXXX
            if not (yend <= hx - eps or hy >= xend + eps or y >= hxend + eps) then
                -- In case both end points are within the rectangle
                --      +<------rw------>+
                --      ^                |
                --     rh           || <-+-- yline
                --      v                |
                --      @<=(x, hx)-------+
                if hx <= y + eps and y + eps < yend - eps and yend - eps <= hxend then
                    yline.value.rectangle = ri
                    yline.value.offset    = y
                    yline.value.height    = xend
                    if not yline.after then
                        yline.value.length = hxend - y
                    else
                        yline.value.length = Ly
                    end
                -- In case the starting point is out of the bottom of the rectangle
                --      +<------rw------>+
                --      ^                |
                --     rh           || <-+-- yline
                --      v           ||   |
                --      @<=(x, hx)--++---+
                --                  ||
                elseif y - eps < hx and hx < yend - eps and yend - eps <= hxend then
                    if not ss.isclose(hx, y) then
                        n:insert(Baseline(y, hx - y, hy), yline)
                    end
                    yline.value.offset    = hx
                    yline.value.height    = xend
                    yline.value.rectangle = ri
                    if not yline.after then
                        yline.value.length = rh
                    elseif ss.isclose(yend, hx) then
                        yline:remove()
                    else
                        yline.value.length = yend - hx
                    end
                -- In case the end point is out of the top of the rectangle
                --                  ||
                --      +<------rw--++-->+
                --      ^           ||   |
                --     rh           || <-+-- yline
                --      v                |
                --      @<=(x, hx)-------+
                elseif hx <= y + eps and y + eps < hxend and hxend < yend + eps then
                    if not ss.isclose(hxend, y) then
                        n:insert(Baseline(y, hxend - y, xend, ri), yline)
                    end

                    if ss.isclose(yend, hxend) then
                        yline:remove()
                    else
                        yline.value.offset = hxend
                        yline.value.length = yend - hxend
                        yline.value.height = hy
                    end
                end

                -- Merge the current baseline with the previous one
                -- if their height are the same
                --                  ||
                --      +<------rw------>||
                --      ^                ||
                --     rh                || <- yline
                --      v                // <- ybefore
                --      @<=(x, hx)-------//
                --                 //
                --                 //
                if ybefore and ss.isclose(ybefore.value.height, ybefore.after.value.height) then
                    ybefore.after.value.offset = ybefore.value.offset
                    ybefore.after.value.length = ybefore.value.length + ybefore.after.value.length
                    ybefore.after.value.height = ybefore.value.height
                    ybefore.after.value.rectangle = nil
                    ybefore:remove()
                end
            end
        end

        -- Extend the prependicular baseline
        -- if the last edge ends within the following area:
        --     +<------rw------>+
        --     ^                |
        --    rh                |
        --     v                |
        --     @<=(x, hx)-------+
        -- //////////////////////////
        -- //////////////////////////
        local lastoffset = n.last.value.offset
        local lastlength = n.last.value.length
        local lastheight = n.last.value.height
        local lastend = lastoffset + lastlength
        if not ss.isclose(lastend, hx) and lastend <= hx then
            local diff = hx - lastend
            if ss.isclose(lastheight, xend) then
                n.last.value.length = hxend - lastoffset
                n.last.value.rectangle = ri
            else
                n.last.value.length = n.last.value.length + diff
                n:append(Baseline(hx, rh, xend, ri))
            end
        -- Extension is also applied in this case,
        -- which is excluded in the former loop
        --      +<------rw------>+//////
        --      ^                |//////
        --     rh                |//////
        --      v                |//////
        --      @<=(x, hx)-------+//////
        elseif ss.isclose(lastheight, xend) then
            local diff = hxend - lastend
            n.last.value.length = n.last.value.length + diff
            n.last.value.rectangle = ri
        elseif lastheight > xend then
            local diff = hxend - lastend
            if diff > 0 then
                n:append(Baseline(lastend, diff, xend, ri))
            end
        end

        -- Apply changes for parallel baseline
        --          x        xend
        --          v          v
        -- hxend -> +----------+
        --          |          |
        --          |          |
        --    hx -> +----------+----+
        --          <----rw---->
        --          <------Lx------->
        local xlineadd = Baseline(x, rw, hxend, ri)
        if ss.isclose(Lx, rw) then
            xline.value.offset = xlineadd.offset
            xline.value.length = xlineadd.length
            xline.value.height = xlineadd.height
            xline.value.rectangle = xlineadd.rectangle
        else
            xline.parent:insert(xlineadd, xline)
            xline.value.offset = xend
            xline.value.length = Lx - rw
            xline.value.height = hx
        end

        -- Merge parallel baselines
        -- if adjacent ones have the same height as currently placing rectangle.
        --            x         xend
        --            v           v
        -- ==xbefore==+-----------+==xafter== <- hxend
        --            |           |
        --            | rectangle |
        --            |           |
        --            +-----------+---------+ <- hx
        if xbefore and ss.isclose(xbefore.value.height, xbefore.after.value.height) then
            xbefore.value.length = xbefore.value.length + rw
            xbefore.value.rectangle = nil
            xbefore.after:remove()
        end
        if xafter and ss.isclose(xafter.value.height, xafter.before.value.height) then
            xafter.value.offset = xafter.before.value.offset
            xafter.value.length = xafter.value.length + xafter.before.value.length
            xafter.value.height = xafter.before.value.height
            xafter.value.rectangle = nil
            xafter.before:remove()
        end
    end

    -- Find the best-fit baseline to place given rectangle index ri.
    function t:findbaseline(ri)
        local prefer_y = false -- Which axis do we prefer if both are considered as candidate?
        local rect = self.rects[ri]
        while true do
            local x, is_y, alt = self:getlowest(prefer_y)
            local Lx = x.value.length
            if Lx >= math.max(rect.width, rect.height) then
                return x, is_y
            elseif alt and not prefer_y then
                prefer_y = true
            else
                prefer_y = false
                self:fillline(x)
            end
        end
    end

    -- Optimization around edges after packing (actual part).
    -- is_y is set to true if this attempt forcuses y-baseline.
    function t:replace(is_y)
        local xbackup = self.xbase
        local ybackup = self.ybase
        self.xbase = ss.LinkedList(self.xbase)
        self.ybase = ss.LinkedList(self.ybase)

        local line
        local lines = is_y and self.ybase or self.xbase
        for _, v in lines() do
            if not line then line = v end
            if line.value.height < v.value.height then line = v end
        end

        local i = line.value.rectangle
        if not i or self.optimized[i] then return false end
        self.optimized[i] = true

        local h = line.value.height
        local r = self.rects[i]
        local rwidth = is_y and r.height or r.width
        local rheight = is_y and r.width or r.height
        r:rotate()
        line.value.height = line.value.height - rheight
        line.value.rectangle = nil
        local newline, new_y = self:findbaseline(i)
        if newline.value.height + rwidth < h then
            local offset = newline.value.offset
            local height = newline.value.height
            if new_y ~= is_y then r:rotate() end
            if new_y then offset, height = height, offset end
            r:place(offset, height)
            self:placebox(i, newline, new_y)
            return true
        else
            r:rotate()
            self.xbase = xbackup
            self.ybase = ybackup
            return false
        end
    end

    -- Optimization around edges after packing.
    -- Remove rectangles touching the baselines
    -- and place them again with no-rotation constraint.
    -- If the attempt actually makes better result, it will be approved.
    function t:optimize()
        local xreplaced = self:replace(false)
        local yreplaced = xreplaced or self:replace(true)
        return not yreplaced
    end

    -- Entry point of rectangle packing.
    function t:pack()
        if self.queue.root then
            local lowest, best, istall, is_y = self:findbestlocation()
            assert(best >= 0, "Can't fit")
            local r = self.rects[best]
            self.queue:remove(-r.width, best)
            self.queueRotated:remove(-r.height, best)
            if istall then r:rotate() end
            local offset = lowest.value.offset
            local height = lowest.value.height
            if is_y then offset, height = height, offset end
            r:place(offset, height)
            self.dones[#self.dones + 1] = best
            self:placebox(best, lowest, is_y)
            return false
        else
            return self:optimize()
        end
    end

    function t:packall()
        while true do
            if self:pack() then return end
        end
    end

    t.__type = "SplatoonSWEPsRectanglePacker"
    return setmetatable(t, meta)
end
