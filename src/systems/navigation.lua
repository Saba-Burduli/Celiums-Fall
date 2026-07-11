local Collision = require("src.systems.collision")
local Navigation = {}

local MARGIN, MAX_RISE, MAX_GAP = 18, 145, 255

local function bounds(node, envelope)
  local p = node.platform
  local x = envelope and p.minX or p.x
  local y = envelope and p.minY or p.y
  local maxX = envelope and p.maxX or p.x
  local maxY = envelope and p.maxY or p.y
  return x + node.offset1, maxX + node.offset2, y, maxY
end

local function gap(a1, a2, b1, b2)
  if a2 < b1 then return b1 - a2 end
  if b2 < a1 then return a1 - b2 end
  return 0
end

local function addEdge(graph, from, to, kind)
  local ax1, ax2, ay = bounds(from, true)
  local bx1, bx2, by = bounds(to, true)
  local horizontal = gap(ax1, ax2, bx1, bx2)
  graph.edges[from.id][#graph.edges[from.id] + 1] = {
    to = to.id, kind = kind, cost = horizontal + math.abs(by - ay) * 1.3 + (kind == "walk" and 0 or 45)
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
          if wall.x + wall.w + MARGIN < span[2] then nextSpans[#nextSpans + 1] = { wall.x + wall.w + MARGIN, span[2] } end
        else nextSpans[#nextSpans + 1] = span end
      end
      spans = nextSpans
    end
  end
  return spans
end

function Navigation.build(runtime)
  local graph = { nodes = {}, byId = {}, edges = {} }
  for _, platform in ipairs(runtime.platforms) do
    local spans = platform.moving and { { platform.x + MARGIN, platform.x + platform.w - MARGIN } } or splitPlatform(platform, runtime.walls)
    for index, span in ipairs(spans) do
      local node = { id = platform.id .. ":" .. index, platform = platform,
        offset1 = span[1] - platform.x, offset2 = span[2] - platform.x }
      graph.nodes[#graph.nodes + 1], graph.byId[node.id], graph.edges[node.id] = node, node, {}
    end
  end
  for _, from in ipairs(graph.nodes) do
    for _, to in ipairs(graph.nodes) do
      if from ~= to then
        local ax1, ax2, ay1, ay2 = bounds(from, true)
        local bx1, bx2, by1, by2 = bounds(to, true)
        local horizontal = gap(ax1, ax2, bx1, bx2)
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

function Navigation.nodeFor(runtime, actor)
  local graph = runtime.navigation
  local supportId = actor.supportingPlatformId
  if not supportId then return nil end
  local best
  for _, node in ipairs(graph.nodes) do
    if node.platform.id == supportId then
      local x1, x2 = bounds(node)
      if actor.x >= x1 - 4 and actor.x <= x2 + 4 then return node end
      if not best or math.abs(actor.x - (x1 + x2) / 2) < best.distance then
        best = { node = node, distance = math.abs(actor.x - (x1 + x2) / 2) }
      end
    end
  end
  return best and best.node or nil
end

function Navigation.route(runtime, startId, goalId)
  if not startId or not goalId then return nil end
  if startId == goalId then return { startId } end
  local graph, open, came, score, estimate = runtime.navigation, { startId }, {}, { [startId] = 0 }, { [startId] = 0 }
  local function heuristic(nodeId)
    local node, goal = graph.byId[nodeId], graph.byId[goalId]
    local nx1, nx2, ny = bounds(node, true)
    local gx1, gx2, gy = bounds(goal, true)
    return math.abs((nx1 + nx2) / 2 - (gx1 + gx2) / 2) + math.abs(ny - gy)
  end
  estimate[startId] = heuristic(startId)
  while #open > 0 do
    local bestIndex = 1
    for i = 2, #open do if estimate[open[i]] < estimate[open[bestIndex]] then bestIndex = i end end
    local current = table.remove(open, bestIndex)
    if current == goalId then
      local route = { current }
      while came[current] do current = came[current]; table.insert(route, 1, current) end
      return route
    end
    for _, edge in ipairs(graph.edges[current] or {}) do
      local nextScore = score[current] + edge.cost
      if not score[edge.to] or nextScore < score[edge.to] then
        came[edge.to], score[edge.to], estimate[edge.to] = current, nextScore, nextScore + heuristic(edge.to)
        local present = false
        for _, id in ipairs(open) do if id == edge.to then present = true end end
        if not present then open[#open + 1] = edge.to end
      end
    end
  end
  return nil
end

local function edgeTo(graph, fromId, toId)
  for _, edge in ipairs(graph.edges[fromId] or {}) do if edge.to == toId then return edge end end
end

local function safeMove(e, node, targetX, speed, dt)
  local x1, x2 = bounds(node)
  local direction = targetX > e.x + 3 and 1 or targetX < e.x - 3 and -1 or 0
  local nextX = e.x + direction * speed * dt
  e.x = math.max(x1, math.min(x2, nextX))
end

function Navigation.update(e, player, runtime, dt, preferredDistance)
  e.nav = e.nav or { route = nil, waypoint = 1, replanTimer = 0, waitTime = 0, waitState = nil }
  local nav, graph = e.nav, runtime.navigation
  nav.replanTimer = math.max(0, nav.replanTimer - dt)
  local current, goal = Navigation.nodeFor(runtime, e), Navigation.nodeFor(runtime, player)
  if not current then
    if nav.airTargetX then
      local direction = nav.airTargetX > e.x and 1 or -1
      e.x = e.x + direction * math.max(e.speed, 150) * dt
    end
    return nav.route ~= nil
  end
  nav.airTargetX = nil
  if not goal then nav.route = nil; return false end
  nav.currentNode = current.id
  if nav.replanTimer == 0 or nav.goalNode ~= goal.id or not nav.route then
    local goalChanged = nav.goalNode ~= goal.id
    nav.route, nav.waypoint, nav.goalNode, nav.replanTimer = Navigation.route(runtime, current.id, goal.id), 1, goal.id, .35
    if goalChanged then nav.waitTime, nav.waitState = 0, nil end
  end
  if not nav.route then return true end
  while nav.waypoint < #nav.route and nav.route[nav.waypoint] == current.id do nav.waypoint = nav.waypoint + 1 end
  if current.id == goal.id or nav.waypoint > #nav.route then
    local target = player.x
    if preferredDistance then
      local dx = player.x - e.x
      if math.abs(dx) < preferredDistance - 35 then target = e.x - (dx >= 0 and 1 or -1) * 80
      elseif math.abs(dx) <= preferredDistance + 35 then target = e.x end
    end
    safeMove(e, current, target, e.speed, dt)
    return true
  end
  local nextId = nav.route[nav.waypoint]
  local target = graph.byId[nextId]
  local edge = edgeTo(graph, current.id, nextId)
  if not target or not edge then nav.route, nav.replanTimer = nil, 0; return true end
  local tx1, tx2 = bounds(target)
  local cx1, cx2 = bounds(current)
  local targetX = math.max(tx1, math.min(tx2, e.x))
  if targetX == e.x then targetX = (tx1 + tx2) / 2 end
  local launchX = targetX
  if tx1 > cx2 then launchX = cx2 elseif tx2 < cx1 then launchX = cx1 end

  if edge.kind == "walk" then
    local direction = targetX > e.x and 1 or -1
    e.x = e.x + direction * e.speed * dt
  elseif edge.kind == "drop" then
    local overlap1, overlap2 = math.max(tx1, cx1), math.min(tx2, cx2)
    if overlap1 <= overlap2 then targetX = math.max(overlap1, math.min(overlap2, player.x)) end
    safeMove(e, current, targetX, e.speed, dt)
    if math.abs(e.x - targetX) < 10 and Collision.dropThrough(e) then nav.waitState = "dropping" end
  else
    local actualGap = gap(current.platform.x, current.platform.x + current.platform.w,
      target.platform.x, target.platform.x + target.platform.w)
    local reachable = actualGap <= MAX_GAP and current.platform.y - target.platform.y <= MAX_RISE
    if edge.kind == "board" and not reachable then
      nav.waitState, nav.waitTime = "waiting_for_platform", nav.waitTime + dt
      if nav.waitTime > 2 then nav.route, nav.replanTimer, nav.waitTime = nil, 0, 0 end
      return true
    end
    nav.waitState, nav.waitTime = nil, 0
    safeMove(e, current, launchX, e.speed, dt)
    if math.abs(e.x - launchX) < 10 and e.onGround then
      nav.airTargetX = targetX
      e.vy, e.onGround, e.supportingPlatform, e.supportingPlatformId = -650, false, nil, nil
    end
  end
  return true
end

return Navigation
