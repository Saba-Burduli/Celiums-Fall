local ground = { x = 0, y = 632, w = 1280, h = 88 }

return {
  forest = {
    name = "Cursed Forest", theme = "forest", background = { .018, .02, .035 }, accent = { .14, .18, .19 },
    entry = { 70, 600 }, next = "forest_depths", exit = { x = 1235, y = 590, label = "Forest Depths" },
    platforms = { ground, { x = 190, y = 520, w = 200, h = 24 }, { x = 485, y = 448, w = 190, h = 24 }, { x = 780, y = 520, w = 220, h = 24 } },
    walls = { { x = 420, y = 536, w = 34, h = 96 } },
    props = { { "window", 250, 632 }, { "altar", 680, 632 }, { "column", 1080, 632 } },
  },
  forest_depths = {
    name = "Forest Depths", theme = "forest", background = { .012, .025, .025 }, accent = { .09, .2, .16 },
    entry = { 70, 600 }, next = "shrine", exit = { x = 1235, y = 590, label = "Ruined Shrine" },
    platforms = { ground, { x = 150, y = 510, w = 220, h = 24 }, { x = 455, y = 420, w = 190, h = 24 }, { x = 745, y = 500, w = 200, h = 24 }, { x = 1025, y = 410, w = 175, h = 24 } },
    movingPlatforms = { { x = 660, y = 535, w = 112, h = 20, axis = "y", range = 72, speed = 1.15 } },
    walls = { { x = 395, y = 548, w = 34, h = 84 } },
    hazards = { { x = 430, y = 615, radius = 26, damage = 8 }, { x = 980, y = 615, radius = 28, damage = 8 } },
    props = { { "column", 420, 632 }, { "window", 930, 632 } },
  },
  shrine = {
    name = "Ruined Shrine", theme = "church", background = { .025, .018, .045 }, accent = { .25, .15, .31 },
    entry = { 70, 600 }, next = "shrine_crypt", exit = { x = 1235, y = 590, label = "Shrine Crypt" },
    platforms = { ground, { x = 165, y = 515, w = 190, h = 24 }, { x = 445, y = 430, w = 200, h = 24 }, { x = 730, y = 510, w = 190, h = 24 }, { x = 1000, y = 425, w = 180, h = 24 } },
    movingPlatforms = { { x = 655, y = 555, w = 110, h = 20, axis = "x", range = 62, speed = .9, phase = 1.2 } },
    walls = { { x = 390, y = 530, w = 34, h = 102 } },
    props = { { "window", 120, 632 }, { "altar", 575, 632 }, { "column", 1030, 632 } },
  },
  shrine_crypt = {
    name = "Shrine Crypt", theme = "crypt", background = { .018, .012, .03 }, accent = { .28, .1, .22 },
    entry = { 70, 600 }, next = "mountain_path", exit = { x = 1235, y = 590, label = "Mountain Path" },
    platforms = { ground, { x = 130, y = 490, w = 220, h = 24 }, { x = 430, y = 550, w = 175, h = 24 }, { x = 680, y = 445, w = 210, h = 24 }, { x = 980, y = 510, w = 195, h = 24 } },
    movingPlatforms = { { x = 600, y = 520, w = 110, h = 20, axis = "y", range = 78, speed = 1.05, phase = 2.1 } },
    walls = { { x = 910, y = 520, w = 36, h = 112 } },
    hazards = { { x = 395, y = 615, radius = 24, damage = 10 }, { x = 920, y = 615, radius = 24, damage = 10 } },
    props = { { "column", 320, 632 }, { "altar", 760, 632 }, { "window", 1080, 632 } },
  },
  mountain_path = {
    name = "Black Mountain Path", theme = "mountain", background = { .02, .016, .03 }, accent = { .28, .07, .12 },
    entry = { 70, 600 }, next = "mountain", exit = { x = 1235, y = 590, label = "Celium's Summit" },
    platforms = { ground, { x = 120, y = 525, w = 185, h = 24 }, { x = 385, y = 440, w = 190, h = 24 }, { x = 655, y = 360, w = 185, h = 24 }, { x = 920, y = 455, w = 200, h = 24 } },
    movingPlatforms = { { x = 560, y = 530, w = 120, h = 20, axis = "x", range = 88, speed = 1.2 } },
    walls = { { x = 335, y = 525, w = 36, h = 107 }, { x = 865, y = 535, w = 36, h = 97 } },
    hazards = { { x = 340, y = 615, radius = 28, damage = 12 }, { x = 850, y = 615, radius = 28, damage = 12 } },
    props = { { "column", 520, 632 }, { "window", 1010, 632 } },
  },
  mountain = {
    name = "Celium's Summit", theme = "summit", background = { .018, .01, .028 }, accent = { .35, .05, .15 },
    entry = { 70, 600 }, exit = nil,
    platforms = { ground, { x = 165, y = 510, w = 200, h = 24 }, { x = 460, y = 420, w = 175, h = 24 }, { x = 730, y = 505, w = 200, h = 24 }, { x = 1010, y = 415, w = 175, h = 24 } },
    movingPlatforms = { { x = 630, y = 555, w = 110, h = 20, axis = "y", range = 65, speed = .8, phase = .7 } },
    props = { { "window", 150, 632 }, { "column", 610, 632 }, { "altar", 1040, 632 } },
  },
}
