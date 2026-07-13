local Config = require("src.core.config")

function love.conf(t)
  t.identity = "celiums-fall"
  t.version = "11.4"
  t.console = false
  t.window.title = "Celium's Fall"
  t.window.width = Config.world.width
  t.window.height = Config.world.height
  t.window.resizable = true
  t.window.minwidth = 960
  t.window.minheight = 540
end
