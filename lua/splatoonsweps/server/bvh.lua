
local ss = SplatoonSWEPs
if not ss then return end

-- Begin constructing AABB-tree ------------------------------------------------
-- Reference: Ingo Wald, et al., 2007,
-- "Ray Tracing Deformable Scenes using Dynamic Bounding Volume Hierarchies",
-- and its Japanese explaination
-- https://qiita.com/omochi64/items/9336f57118ba918f82ec

local function AABB()
    return {
        Maxs = ss.vector_one * -math.huge,
        Mins = ss.vector_one * math.huge,
    }
end

local function surfaceAreaAABB(x)
    local diff = x.Maxs - x.Mins
    return 2 * (diff.x * diff.y + diff.x * diff.z + diff.y * diff.z)
end

local function mergeAABB(a, b)
    local aabb = AABB()
    aabb.Maxs = ss.MaxVector(a.Maxs, b.Maxs)
    aabb.Mins = ss.MinVector(a.Mins, b.Mins)
    return aabb
end

local function createWholeAABB(indices)
    local aabb = AABB()
    for _, i in ipairs(indices) do
        local surfaceAABB = AABB()
        surfaceAABB.Maxs = ss.SurfaceArray[i].Maxs
        surfaceAABB.Mins = ss.SurfaceArray[i].Mins
        aabb = mergeAABB(aabb, surfaceAABB)
    end

    return aabb
end

function ss.GenerateAABBTree()
    local treeIndex = 2
    local axes = { { 1, 2, 3 }, { 2, 3, 1 }, { 3, 1, 2 } }
    local function makeNodes(indices, nodeIndex)
        local node = { AABB = createWholeAABB(indices) }
        local bestCost = #indices
        local bestAxis = nil
        local bestSplitIndex = -1
        local surfaceArea = surfaceAreaAABB(node.AABB)
        local sortedIndices = {}
        local axisToSort = 1
        local function sorter(i, j)
            i, j = ss.SurfaceArray[i], ss.SurfaceArray[j]
            local iCenter = (i.Maxs + i.Mins) / 2
            local jCenter = (j.Maxs + j.Mins) / 2
            for axisIndex = 1, 3 do
                local iComponent = iCenter[axes[axisIndex][axisToSort]]
                local jComponent = jCenter[axes[axisIndex][axisToSort]]
                if iComponent ~= jComponent then
                    return iComponent < jComponent
                end
            end
        end

        for axisIndex = 1, 3 do
            axisToSort = axisIndex
            sortedIndices[axisIndex] = table.Copy(indices)
            table.sort(sortedIndices[axisIndex], sorter)
            local total = #sortedIndices[axisIndex]
            local split1, split2 = {}, sortedIndices[axisIndex]
            local testAABB = AABB()
            local split1SurfaceAreas = {}
            local split2SurfaceAreas = {}
            for i = 1, total do
                split1SurfaceAreas[i] = surfaceAreaAABB(testAABB)
                split1[#split1 + 1] = ss.tablepop(split2)
                local aabb = AABB()
                aabb.Maxs = ss.SurfaceArray[split1[#split1]].Maxs
                aabb.Mins = ss.SurfaceArray[split1[#split1]].Mins
                testAABB = mergeAABB(testAABB, aabb)
            end

            testAABB = AABB()
            for i = total, 1, -1 do
                split2SurfaceAreas[i] = surfaceAreaAABB(testAABB)
                local cost = split1SurfaceAreas[i] * #split1 / surfaceArea
                           + split2SurfaceAreas[i] * #split2 / surfaceArea
                if cost < bestCost then
                    bestCost = cost
                    bestAxis = axisIndex
                    bestSplitIndex = i + 1
                end

                local aabb = AABB()
                aabb.Maxs = ss.SurfaceArray[split1[#split1]].Maxs
                aabb.Mins = ss.SurfaceArray[split1[#split1]].Mins
                testAABB = mergeAABB(testAABB, aabb)
                ss.tablepush(split2, split1[#split1])
                split1[#split1] = nil
            end
        end

        ss.AABBTree[nodeIndex] = node
        if not bestAxis then
            node.SurfIndices = indices
            return
        end

        node.Children = {treeIndex, treeIndex + 1}
        treeIndex = treeIndex + 2

        local leftIndices, rightIndices = {}, {}
        for i, index in ipairs(sortedIndices[bestAxis]) do
            if i < bestSplitIndex then
                leftIndices[#leftIndices + 1] = index
            else
                rightIndices[#rightIndices + 1] = index
            end
        end

        makeNodes(leftIndices, node.Children[1])
        makeNodes(rightIndices, node.Children[2])
    end

    local indices = {}
    for i = 1, #ss.SurfaceArray do indices[i] = i end

    ss.AABBTree = {}
    makeNodes(indices, 1)
end
