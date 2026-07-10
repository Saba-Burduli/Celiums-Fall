local ground = { x = 0, y = 632, w = 1280, h = 88 }

return {
  forest = {
    name = "Cursed Forest", theme = "forest", background = { .018, .02, .035 }, accent = { .14, .18, .19 },
    entry = { 70, 600 }, next = "forest_depths", exit = { x = 1235, y = 590, label = "Forest Depths" },
    platforms = { ground, { x = 210, y = 520, w = 190, h = 24 }, { x = 500, y = 448, w = 180, h = 24 }, { x = 805, y = 520, w = 210, h = 24 } },
    props = { { "window", 250, 632 }, { "altar", 680, 632 }, { "column", 1080, 632 } },
  },
  forest_depths = {
    name = "Forest Depths", theme = "forest", background = { .012, .025, .025 }, accent = { .09, .2, .16 },
    entry = { 70, 600 }, next = "shrine", exit = { x = 1235, y = 590, label = "Ruined Shrine" },
    platforms = { ground, { x = 170, y = 500, w = 210, h = 24 }, { x = 470, y = 410, w = 180, h = 24 }, { x = 760, y = 490, w = 190, h = 24 }, { x = 1010, y = 395, w = 170, h = 24 } },
    hazards = { { x = 430, y = 615, radius = 26, damage = 8 }, { x = 980, y = 615, radius = 28, damage = 8 } },
    props = { { "column", 420, 632 }, { "window", 930, 632 } },
  },
  shrine = {
    name = "Ruined Shrine", theme = "church", background = { .025, .018, .045 }, accent = { .25, .15, .31 },
    entry = { 70, 600 }, next = "shrine_crypt", exit = { x = 1235, y = 590, label = "Shrine Crypt" },
    platforms = { ground, { x = 180, y = 510, w = 180, h = 24 }, { x = 450, y = 425, w = 190, h = 24 }, { x = 735, y = 510, w = 180, h = 24 }, { x = 1010, y = 430, w = 170, h = 24 } },
    props = { { "window", 120, 632 }, { "altar", 575, 632 }, { "column", 1030, 632 } },
  },
  shrine_crypt = {
    name = "Shrine Crypt", theme = "crypt", background = { .018, .012, .03 }, accent = { .28, .1, .22 },
    entry = { 70, 600 }, next = "mountain_path", exit = { x = 1235, y = 590, label = "Mountain Path" },
    platforms = { ground, { x = 140, y = 480, w = 210, h = 24 }, { x = 430, y = 545, w = 165, h = 24 }, { x = 670, y = 420, w = 205, h = 24 }, { x = 970, y = 500, w = 190, h = 24 } },
    hazards = { { x = 395, y = 615, radius = 24, damage = 10 }, { x = 920, y = 615, radius = 24, damage = 10 } },
    props = { { "column", 320, 632 }, { "altar", 760, 632 }, { "window", 1080, 632 } },
  },
  mountain_path = {
    name = "Black Mountain Path", theme = "mountain", background = { .02, .016, .03 }, accent = { .28, .07, .12 },
    entry = { 70, 600 }, next = "mountain", exit = { x = 1235, y = 590, label = "Celium's Summit" },
    platforms = { ground, { x = 130, y = 520, w = 170, h = 24 }, { x = 390, y = 430, w = 180, h = 24 }, { x = 650, y = 350, w = 175, h = 24 }, { x = 900, y = 455, w = 190, h = 24 } },
    hazards = { { x = 340, y = 615, radius = 28, damage = 12 }, { x = 850, y = 615, radius = 28, damage = 12 } },
    props = { { "column", 520, 632 }, { "window", 1010, 632 } },
  },
  mountain = {
    name = "Celium's Summit", theme = "summit", background = { .018, .01, .028 }, accent = { .35, .05, .15 },
    entry = { 70, 600 }, exit = nil,
    platforms = { ground, { x = 180, y = 500, w = 190, h = 24 }, { x = 470, y = 410, w = 160, h = 24 }, { x = 730, y = 500, w = 190, h = 24 }, { x = 1010, y = 410, w = 160, h = 24 } },
    props = { { "window", 150, 632 }, { "column", 610, 632 }, { "altar", 1040, 632 } },
  },
}
