local Helper = require("tests.test_helper")

require("tests.config_test")
require("tests.utils_test")

print(("Lua unit tests passed: %d"):format(Helper.count))
