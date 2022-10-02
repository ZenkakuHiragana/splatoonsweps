
-- Structures used in UV packing process.
local ss = SplatoonSWEPs
if not ss then return end

local function CellTs(a)    return tostring(a.value)  end
local function CellEq(a, b) return a.value == b.value end
local function CellLe(a, b) return a.value <= b.value end
local function CellLt(a, b) return a.value <  b.value end
function ss.LinkedList(values)
    local function Cell(parent, value)
        return setmetatable({
            after = nil,
            before = nil,
            parent = parent,
            value = value,
            remove = function(self) self.parent:remove(self) end,
            __type = "SplatoonSWEPsLinkedListCell",
        }, {
            __eq = CellEq,
            __le = CellLe,
            __lt = CellLt,
            __tostring = CellTs,
        })
    end

    local meta = {}
    local t = { count = 0, first = nil, last = nil }
    function meta:__call() -- iterator
        local index, current = 1, self.first
        return function()
            local i, v = index, current
            if not v then return end
            index, current = i + 1, v.after
            return i, v
        end
    end
    function meta:__index(key)
        if not isnumber(key) then return end
        for i, v in self() do
            if i == key then return v end
        end
    end
    function meta:__newindex(key, value)
        if key == "first" or key == "last" then
            return rawset(self, key, value)
        elseif not isnumber(key) then
            return
        end

        for i, v in self() do
            if i == key then
                v.value = value
                return
            end
        end
    end
    function meta:__tostring()
        local s = ""
        for _, v in self() do s = s .. "\n  " .. tostring(v.value) end
        return "[" .. s .. "\n]"
    end
    function t:append(value)
        local cell = Cell(self, value)
        if self.count == 0 then
            self.first = cell
        else
            self.last.after, cell.before = cell, self.last
        end
        self.last = cell
        self.count = self.count + 1
    end
    function t:insert(value, i) -- insert before that element
        if self.count == 0 then
            return self:append(value)
        elseif istable(i) and i.__type == "SplatoonSWEPsLinkedListCell" then
            local before = i.before
            local cell = Cell(self, value)
            cell.after, i.before = i, cell
            self.count = self.count + 1
            if before then
                before.after, cell.before = cell, before
            else
                self.first = cell
            end
        elseif isnumber(i) then
            return self:insert(value, self[i])
        end
    end
    function t:remove(i)
        if istable(i) then
            self.count = self.count - 1
            if i.before then
                i.before.after = i.after
            else
                self.first = i.after
            end
            if i.after then
                i.after.before = i.before
            else
                self.last = i.before
            end
        elseif isnumber(i) then
            return self:remove(self[i])
        end
    end

    if values ~= nil and not istable(values) then
        t:append(values)
    elseif istable(values) then
        if values.__type == "SplatoonSWEPsLinkedList" then
            for _, v in values() do t:append(ss.deepcopy(v.value)) end
        else
            for _, v in ipairs(values) do t:append(ss.deepcopy(v)) end
        end
    end

    t.__type = "SplatoonSWEPsLinkedList"
    return setmetatable(t, meta)
end

function ss.MakeAVL()
    local function Node(key, value, parent)
        local meta = {}
        local t = {
            bias = 0,
            parent = parent,
            key = key, value = value,
            left = nil, right = nil,
        }
        function meta:__tostring()
            local s = self.parent and "" or "^"
            s = s .. tostring(self.key) .. " = " .. tostring(self.value)
            .. " (" .. tostring(self.bias) .. ")"
            return s
        end
        function t:display()
            local textroot = tostring(self)
            local widthroot = string.len(textroot)
            local textleft, wleft, hleft, centerleft = {}, 0, 0, 0
            local textright, wright, hright, centerright = {}, 0, 0, 0
            if self.left then  textleft,  wleft,  hleft,  centerleft  = self.left:display() end
            if self.right then textright, wright, hright, centerright = self.right:display() end
            if not self.right and not self.left then
                return { textroot }, widthroot, 1, math.floor(widthroot / 2)
            end
            if 0 < hleft and hleft < hright then
                local spaces = string.rep(" ", wleft)
                for _ = 1, hright - hleft do table.insert(textleft, spaces) end
            end
            if 0 < hright and hright < hleft then
                local spaces = string.rep(" ", wright)
                for _ = 1, hleft - hright do table.insert(textright, spaces) end
            end
            local lines = { "", "" }
            local totalwidth = widthroot
            local totalheight = math.max(hleft, hright) + 2
            local mergedcenter = wleft + math.floor(widthroot / 2)
            for i = 1, math.max(#textleft, #textright) do
                local L = textleft[i] or ""
                local R = textright[i] or ""
                table.insert(lines, L .. string.rep(" ", widthroot) .. R)
            end
            if self.left then
                totalwidth = totalwidth + wleft
                lines[1] = lines[1] .. string.rep(" ", centerleft + 1)
                lines[1] = lines[1] .. string.rep("_", wleft - centerleft - 1)
                lines[2] = lines[2] .. string.rep(" ", centerleft)
                lines[2] = lines[2] .. "/"
                lines[2] = lines[2] .. string.rep(" ", wleft - centerleft - 1)
            end
            lines[1] = lines[1] .. textroot
            lines[2] = lines[2] .. string.rep(" ", widthroot)
            if self.right then
                totalwidth = totalwidth + wright
                lines[1] = lines[1] .. string.rep("_", centerright)
                lines[1] = lines[1] .. string.rep(" ", wright - centerright)
                lines[2] = lines[2] .. string.rep(" ", centerright)
                lines[2] = lines[2] .. "|"
                lines[2] = lines[2] .. string.rep(" ", wright - centerright - 1)
            end
            return lines, totalwidth, totalheight, mergedcenter
        end

        t.__type = "SplatoonSWEPsAVLNode"
        return setmetatable(t, meta)
    end

    local meta = {}
    local t = { root = nil }
    function meta:__tostring()
        if not self.root then return "*Empty AVL Tree*" end
        local s = ""
        local lines = (self.root:display())
        for _, line in ipairs(lines) do s = s .. line .. "\n" end
        return s
    end

    function t:rotateleft(node)
        if not node.right then return end
        local grandchild = node.right.left
        local parent, child = node.parent, node.right
        child.left, child.parent = node, parent
        node.right, node.parent  = grandchild, child
        if grandchild then grandchild.parent = node end
        if not parent then
            self.root = child
        elseif parent.left == node then
            parent.left = child
        else
            parent.right = child
        end
        node.bias  = node.bias  + 1 - math.min(0, child.bias)
        child.bias = child.bias + 1 + math.max(0, node.bias)
    end

    function t:rotateright(node)
        if not node.left then return end
        local grandchild = node.left.right
        local parent, child = node.parent, node.left
        child.right, child.parent = node, parent
        node.left,   node.parent  = grandchild, child
        if grandchild then grandchild.parent = node end
        if not parent then
            self.root = child
        elseif parent.right == node then
            parent.right = child
        else
            parent.left = child
        end
        node.bias  = node.bias  - (1 + math.max(0, child.bias))
        child.bias = child.bias - (1 - math.min(0, node.bias))
    end

    function t:updateinsert(node)
        while node.parent do
            if node.parent.left == node then
                node = node.parent
                node.bias = node.bias + 1
                if node.bias == 0 then
                    return
                elseif node.bias > 1 then
                    if node.left.bias < 0 then self:rotateleft(node.left) end
                    self:rotateright(node)
                    return
                end
            else
                node = node.parent
                node.bias = node.bias - 1
                if node.bias == 0 then
                    return
                elseif node.bias < -1 then
                    if node.right.bias > 0 then self:rotateright(node.right) end
                    self:rotateleft(node)
                    return
                end
            end
        end
    end

    function t:updateremove(node)
        while node and node.parent do
            if node.parent.left == node then
                node = node.parent
                node.bias = node.bias - 1
                if node.bias == -1 then
                    return
                elseif node.bias < -1 then
                    local bias = node.right.bias
                    if bias > 0 then self:rotateright(node.right) end
                    self:rotateleft(node)
                    node = node.parent
                    if bias == 0 then return end
                end
            else
                node = node.parent
                node.bias = node.bias + 1
                if node.bias == 1 then
                    return
                elseif node.bias > 1 then
                    local bias = node.left.bias
                    if bias < 0 then self:rotateleft(node.left) end
                    self:rotateright(node)
                    node = node.parent
                    if bias == 0 then return end
                end
            end
        end
    end

    function t:insert(key, value)
        local node = self:lowerbound(key, value)
        local new = Node(key, value, node)
        if not self.root then
            self.root = new
            return
        elseif node and not node.left then
            node.left = new
        else
            node = node and node.left or self.root
            while node.right do node = node.right end
            node.right = new
            new.parent = node
        end
        self:updateinsert(new)
    end

    function t:remove(key, value)
        local node = istable(key) and key or self:lowerbound(key, value)
        if not node then return end
        if node.left then
            local rightmost = node.left
            while rightmost.right do rightmost = rightmost.right end
            node.key, node.value = rightmost.key, rightmost.value
            return self:remove(rightmost)
        elseif node.right then
            local leftmost = node.right
            while leftmost.left do leftmost = leftmost.left end
            node.key, node.value = leftmost.key, leftmost.value
            return self:remove(leftmost)
        elseif not node.parent then
            self.root = nil
            return
        else
            self:updateremove(node)
            if node.parent.left == node then
                node.parent.left = nil
            else
                node.parent.right = nil
            end
        end
        return self
    end

    function t:lowerbound(key, value)
        local node = self.root
        local candidate = nil
        while node do
            if key < node.key or not value and key == node.key then
                candidate, node = node, node.left
            elseif key > node.key then
                node = node.right
            elseif value <= node.value then
                candidate, node = node, node.left
            else
                node = node.right
            end
        end
        return candidate
    end

    t.__type = "SplatoonSWEPsAVLTree"
    return setmetatable(t, meta)
end

local function REQ(a, b)
    return a.width == b.width and a.height == b.height
end
local function RLT(a, b)
    if a.width == b.width then
        return a.height < b.height
    else
        return a.width < b.width
    end
end
local function RLE(a, b)
    return RLT(a, b) or REQ(a, b)
end
local function RTS(a)
    return string.format(
        "(%6.2f, %6.2f)@(%6.2f, %6.2f)",
        a.width, a.height, a.left, a.bottom)
end

function ss.MakeRectangle(width, height, x, y, tag)
    local t = {}
    local meta = { __eq = REQ, __lt = RLT, __le = RLE, __tostring = RTS }
    function t:rotate()
        self.width, self.height = self.height, self.width
        self.size = Vector(self.width, self.height)
        self.right = self.left + self.width
        self.top = self.bottom + self.height
        self.topright = Vector(self.right, self.top)
        self.istall = not self.istall
    end

    function t:place(px, py)
        self.left       = px
        self.bottom     = py
        self.bottomleft = Vector(px, py)
        self.right      = px + self.width
        self.top        = py + self.height
        self.topright   = Vector(px + self.width, py + self.height)
    end

    x, y = x or 0, y or 0
    t.left       = x
    t.bottom     = y
    t.bottomleft = Vector(x, y)
    t.width      = width
    t.height     = height
    t.size       = Vector(width, height)
    t.right      = x + width
    t.top        = y + height
    t.topright   = Vector(x + width, y + height)
    t.istall     = width < height
    t.tag        = tag

    t.__type = "SplatoonSWEPsRectangle"
    return setmetatable(t, meta)
end

function ss.RectangleRand(widthrange, aspectrange, tag)
    local aspect = math.Remap(math.random(), 0, 1, aspectrange[1], aspectrange[2])
    local width = math.Remap(math.random(), 0, 1, widthrange[1], widthrange[2])
    local height = width * aspect
    return ss.MakeRectangle(width, height, tag)
end