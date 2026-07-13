local Config = require("src.core.config")
local Helper = require("tests.test_helper")

Helper.test("world and render dimensions keep the 2x pixel scale", function()
  Helper.equal(Config.world.width / Config.render.width, 2)
  Helper.equal(Config.world.height / Config.render.height, 2)
end)

Helper.test("ground fills the space below its top edge", function()
  Helper.equal(Config.world.groundY + Config.world.groundHeight, Config.world.height)
end)

Helper.test("player jump clears the tallest authored first ledge", function()
  local rise = Config.physics.playerJumpImpulse ^ 2 / (2 * Config.physics.playerGravity)
  assert(rise >= 140, "configured player jump is too short")
end)
