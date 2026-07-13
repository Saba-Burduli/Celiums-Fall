local Collision = require("src.systems.collision")
local Config = require("src.core.config")
local Graph = require("src.systems.navigation_graph")
local Navigation = {}

local function safeMove(e, node, targetX, speed, dt)
  local x1, x2 = Graph.bounds(node)
  local direction = targetX > e.x + 3 and 1 or targetX < e.x - 3 and -1 or 0
  local nextX = e.x + direction * speed * dt
  e.x = math.max(x1, math.min(x2, nextX))
end

function Navigation.update(e, player, runtime, dt, preferredDistance)
  e.nav = e.nav or { route = nil, waypoint = 1, replanTimer = 0, waitTime = 0, waitState = nil }
  local nav, graph = e.nav, runtime.navigation
  nav.replanTimer = math.max(0, nav.replanTimer - dt)
  local current, goal = Graph.nodeFor(runtime, e), Graph.nodeFor(runtime, player)
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
    nav.route, nav.waypoint, nav.goalNode, nav.replanTimer = Graph.route(runtime, current.id, goal.id),
      1, goal.id, Config.navigation.replanInterval
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
  local edge = Graph.edgeTo(graph, current.id, nextId)
  if not target or not edge then nav.route, nav.replanTimer = nil, 0; return true end
  local tx1, tx2 = Graph.bounds(target)
  local cx1, cx2 = Graph.bounds(current)
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
    local actualGap = Graph.gap(current.platform.x, current.platform.x + current.platform.w,
      target.platform.x, target.platform.x + target.platform.w)
    local reachable = actualGap <= Config.navigation.maxGap
      and current.platform.y - target.platform.y <= Config.navigation.maxRise
    if edge.kind == "board" and not reachable then
      nav.waitState, nav.waitTime = "waiting_for_platform", nav.waitTime + dt
      if nav.waitTime > Config.navigation.blockedReplanTime then
        nav.route, nav.replanTimer, nav.waitTime = nil, 0, 0
      end
      return true
    end
    nav.waitState, nav.waitTime = nil, 0
    safeMove(e, current, launchX, e.speed, dt)
    if math.abs(e.x - launchX) < 10 and e.onGround then
      nav.airTargetX = targetX
      e.vy, e.onGround, e.supportingPlatform, e.supportingPlatformId =
        -Config.physics.enemyJumpImpulse, false, nil, nil
    end
  end
  return true
end

return Navigation
