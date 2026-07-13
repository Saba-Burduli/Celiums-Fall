local Graph = require("src.systems.navigation_graph")
local Helper = require("tests.test_helper")
local Platforms = require("src.systems.platforms")

local function traversalRoom()
  return Platforms.create({
    platforms = {
      { x = 0, y = 632, w = 1280, h = 88 },
      { x = 240, y = 500, w = 180, h = 24 },
      { x = 500, y = 400, w = 180, h = 24 },
    },
    walls = { { x = 400, y = 532, w = 36, h = 100 } },
  })
end

Helper.test("walls split a supported platform into separate graph nodes", function()
  local runtime = traversalRoom()
  local groundNodes = 0
  for _, node in ipairs(runtime.navigation.nodes) do
    if node.platform.id == "static:1" then groundNodes = groundNodes + 1 end
  end
  Helper.equal(groundNodes, 2)
end)

Helper.test("A star finds a route across multiple platform heights", function()
  local runtime = traversalRoom()
  local actor = { x = 100, supportingPlatformId = "static:1" }
  local target = { x = 570, supportingPlatformId = "static:3" }
  local startNode = Graph.nodeFor(runtime, actor)
  local goalNode = Graph.nodeFor(runtime, target)
  local route = Graph.route(runtime, startNode.id, goalNode.id)
  assert(route and #route > 1, "expected a multi-node route")
  Helper.equal(route[1], startNode.id)
  Helper.equal(route[#route], goalNode.id)
end)

Helper.test("moving-platform envelopes produce boarding edges", function()
  local runtime = Platforms.create({
    platforms = { { x = 0, y = 632, w = 620, h = 88 } },
    movingPlatforms = { { x = 1000, y = 500, w = 120, h = 20, axis = "x", range = 350 } },
  })
  local ground = Graph.nodeFor(runtime, { x = 600, supportingPlatformId = "static:1" })
  local moving = Graph.nodeFor(runtime, { x = 1000, supportingPlatformId = "moving:1" })
  local edge = Graph.edgeTo(runtime.navigation, ground.id, moving.id)
  Helper.equal(edge.kind, "board")
end)
