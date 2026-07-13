local Config = require("src.core.config")
local Graph = {}

local MARGIN = Config.navigation.platformMargin
local MAX_RISE = Config.navigation.maxRise
local MAX_GAP = Config.navigation.maxGap

function Graph.bounds(node, envelope)
  local platform = node.platform
  local x = envelope and platform.minX or platform.x
  local y = envelope and platform.minY or platform.y
  local maxX = envelope and platform.maxX or platform.x
  local maxY = envelope and platform.maxY or platform.y
  return x + node.offset1, maxX + node.offset2, y, maxY
end

function Graph.gap(a1, a2, b1, b2)
  if a2 < b1 then return b1 - a2 end
  if b2 < a1 then return a1 - b2 end
  return 0
end

local function addEdge(graph, from, to, kind)
  local ax1, ax2, ay = Graph.bounds(from, true)
  local bx1, bx2, by = Graph.bounds(to, true)
  local horizontal = Graph.gap(ax1, ax2, bx1, bx2)
  graph.edges[from.id][#graph.edges[from.id] + 1] = {
    to = to.id,
    kind = kind,
    cost = horizontal + math.abs(by - ay) * 1.3 + (kind == "walk" and 0 or 45),
  }
end

local function splitPlatform(platform, walls)
  local spans = { { platform.x + MARGIN, platform.x + platform.w - MARGIN } }
  for _, wall in ipairs(walls or {}) do
    if wall.y < platform.y and wall.y + wall.h >= platform.y - 2 then
      local nextSpans = {}
      for _, span in ipairs(spans) do
        if wall.x < span[2] and wall.x + wall.w > span[1] then
          if wall.x - MARGIN > span[1] then nextSpans[#nextSpans + 1] = { span[1], wall.x - MARGIN } end
          if wall.x + wall.w + MARGIN < span[2] then
            nextSpans[#nextSpans + 1] = { wall.x + wall.w + MARGIN, span[2] }
          end
        else
          nextSpans[#nextSpans + 1] = span
        end
      end
      spans = nextSpans
    end
  end
  return spans
end

function Graph.build(runtime)
  local graph = { nodes = {}, byId = {}, edges = {} }
  for _, platform in ipairs(runtime.platforms) do
    local spans = platform.moving
      and { { platform.x + MARGIN, platform.x + platform.w - MARGIN } }
      or splitPlatform(platform, runtime.walls)
    for index, span in ipairs(spans) do
      local node = {
        id = platform.id .. ":" .. index,
        platform = platform,
        offset1 = span[1] - platform.x,
        offset2 = span[2] - platform.x,
      }
      graph.nodes[#graph.nodes + 1] = node
      graph.byId[node.id] = node
      graph.edges[node.id] = {}
    end
  end
  for _, from in ipairs(graph.nodes) do
    for _, to in ipairs(graph.nodes) do
      if from ~= to then
        local ax1, ax2, ay1, ay2 = Graph.bounds(from, true)
        local bx1, bx2, by1, by2 = Graph.bounds(to, true)
        local horizontal = Graph.gap(ax1, ax2, bx1, bx2)
        local rise = ay1 - by2
        local moving = from.platform.moving or to.platform.moving
        if from.platform == to.platform then
          if horizontal <= 90 then addEdge(graph, from, to, "jump") end
        elseif not moving and math.abs(by1 - ay1) <= 4 and horizontal <= 4 then
          addEdge(graph, from, to, "walk")
        elseif moving and horizontal <= MAX_GAP and rise <= MAX_RISE then
          addEdge(graph, from, to, "board")
        elseif by1 > ay2 + 12 and horizontal == 0 and from.platform.oneWay then
          addEdge(graph, from, to, "drop")
        elseif horizontal <= MAX_GAP and rise <= MAX_RISE then
          addEdge(graph, from, to, "jump")
        end
      end
    end
  end
  return graph
end

function Graph.nodeFor(runtime, actor)
  local graph = runtime.navigation
  local supportId = actor.supportingPlatformId
  if not supportId then return nil end
  local best
  for _, node in ipairs(graph.nodes) do
    if node.platform.id == supportId then
      local x1, x2 = Graph.bounds(node)
      if actor.x >= x1 - 4 and actor.x <= x2 + 4 then return node end
      local distance = math.abs(actor.x - (x1 + x2) / 2)
      if not best or distance < best.distance then best = { node = node, distance = distance } end
    end
  end
  return best and best.node or nil
end

function Graph.route(runtime, startId, goalId)
  if not startId or not goalId then return nil end
  if startId == goalId then return { startId } end
  local graph = runtime.navigation
  local open, came = { startId }, {}
  local score, estimate = { [startId] = 0 }, { [startId] = 0 }

  local function heuristic(nodeId)
    local node, goal = graph.byId[nodeId], graph.byId[goalId]
    local nx1, nx2, ny = Graph.bounds(node, true)
    local gx1, gx2, gy = Graph.bounds(goal, true)
    return math.abs((nx1 + nx2) / 2 - (gx1 + gx2) / 2) + math.abs(ny - gy)
  end

  estimate[startId] = heuristic(startId)
  while #open > 0 do
    local bestIndex = 1
    for index = 2, #open do
      if estimate[open[index]] < estimate[open[bestIndex]] then bestIndex = index end
    end
    local current = table.remove(open, bestIndex)
    if current == goalId then
      local route = { current }
      while came[current] do
        current = came[current]
        table.insert(route, 1, current)
      end
      return route
    end
    for _, edge in ipairs(graph.edges[current] or {}) do
      local nextScore = score[current] + edge.cost
      if not score[edge.to] or nextScore < score[edge.to] then
        came[edge.to] = current
        score[edge.to] = nextScore
        estimate[edge.to] = nextScore + heuristic(edge.to)
        local present = false
        for _, id in ipairs(open) do
          if id == edge.to then present = true; break end
        end
        if not present then open[#open + 1] = edge.to end
      end
    end
  end
  return nil
end

function Graph.edgeTo(graph, fromId, toId)
  for _, edge in ipairs(graph.edges[fromId] or {}) do
    if edge.to == toId then return edge end
  end
end

return Graph
