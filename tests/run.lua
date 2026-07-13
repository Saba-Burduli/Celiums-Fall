local Helper = require("tests.test_helper")

require("tests.config_test")
require("tests.utils_test")
require("tests.storage_test")
require("tests.world_test")

print(("Lua unit tests passed: %d"):format(Helper.count))
