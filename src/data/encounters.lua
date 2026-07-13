return {
  forest = {
    enemies = {
      { kind = "shadow_thrall", x = 420, y = 595 },
      { kind = "cursed_hound", x = 610, y = 430 },
      { kind = "ash_cultist", x = 890, y = 500 },
      { kind = "shadow_thrall", x = 1080, y = 595 },
    },
    items = {
      { kind = "blood", x = 560, y = 410, unlessFlag = "blood" },
      { kind = "moon", x = 930, y = 480, questItem = true, unlessFlag = "questMoon" },
    },
  },
  forest_depths = {
    enemies = {
      { kind = "shielded_knight", x = 520, y = 385 },
      { kind = "rift_witch", x = 820, y = 460 },
      { kind = "winged_curse", x = 1030, y = 300 },
    },
  },
  forest_ruins = {
    enemies = {
      { kind = "cursed_hound", x = 270, y = 470 },
      { kind = "ash_cultist", x = 500, y = 380 },
      { kind = "shadow_thrall", x = 820, y = 450 },
      { kind = "winged_curse", x = 1080, y = 315 },
    },
  },
  shrine = {
    enemies = {
      { kind = "shadow_thrall", x = 350, y = 595 },
      { kind = "ash_cultist", x = 540, y = 400 },
    },
    boss = { kind = "mire_priest", x = 870, y = 590, unlessFlag = "mireDead" },
    items = {
      { kind = "moon", x = 540, y = 390, unlessFlag = "moon" },
      { kind = "ash", x = 810, y = 475, unlessFlag = "ash" },
    },
  },
  shrine_crypt = {
    enemies = {
      { kind = "shielded_knight", x = 250, y = 450 },
      { kind = "rift_witch", x = 760, y = 390 },
      { kind = "ash_cultist", x = 1040, y = 470 },
    },
  },
  ossuary = {
    enemies = {
      { kind = "shadow_thrall", x = 260, y = 465 },
      { kind = "rift_witch", x = 500, y = 370 },
      { kind = "cursed_hound", x = 800, y = 455 },
      { kind = "ash_cultist", x = 1080, y = 370 },
    },
  },
  mountain_path = {
    enemies = {
      { kind = "winged_curse", x = 380, y = 280 },
      { kind = "winged_curse", x = 690, y = 250 },
      { kind = "shielded_knight", x = 960, y = 430 },
      { kind = "rift_witch", x = 1090, y = 300 },
    },
  },
  black_keep = {
    enemies = {
      { kind = "shielded_knight", x = 245, y = 480 },
      { kind = "ash_cultist", x = 485, y = 390 },
      { kind = "winged_curse", x = 760, y = 270 },
      { kind = "rift_witch", x = 1060, y = 400 },
    },
  },
  mountain = {
    enemies = {
      { kind = "cursed_hound", x = 360, y = 590 },
      { kind = "ash_cultist", x = 540, y = 385 },
    },
    boss = { kind = "lord_celium", x = 980, y = 585 },
    items = {
      { kind = "wind", x = 540, y = 375, unlessFlag = "wind" },
    },
  },
}
