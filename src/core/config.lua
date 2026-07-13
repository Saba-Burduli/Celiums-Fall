local Config = {
  world = {
    width = 1280,
    height = 720,
    groundY = 632,
    groundHeight = 88,
    edgePadding = 5,
  },
  render = {
    width = 640,
    height = 360,
  },
  physics = {
    playerGravity = 1500,
    actorGravity = 1450,
    playerJumpImpulse = 670,
    enemyJumpImpulse = 650,
    deathY = 760,
  },
  navigation = {
    platformMargin = 18,
    maxRise = 145,
    maxGap = 255,
    replanInterval = .35,
    blockedReplanTime = 2,
  },
}

return Config
