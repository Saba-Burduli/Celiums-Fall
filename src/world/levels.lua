return {
  forest = {
    name = "Cursed Forest", background = { .045, .075, .065 }, accent = { .12, .22, .14 },
    entry = { 95, 360 }, next = "forest_depths", exit = { x = 1228, y = 360, label = "Forest Depths" },
    trees = { {190,130,35}, {330,570,45}, {510,170,30}, {720,590,40}, {930,135,36}, {1080,580,45} },
  },
  forest_depths = {
    name = "Forest Depths", background = { .035, .065, .055 }, accent = { .1, .26, .17 },
    entry = { 95, 360 }, next = "shrine", exit = { x = 1228, y = 360, label = "Ruined Shrine" },
    trees = { {180,120,46}, {280,610,50}, {520,100,38}, {735,620,48}, {980,115,44}, {1100,590,50} },
    hazards = { { x = 500, y = 390, radius = 48, damage = 8 }, { x = 820, y = 240, radius = 42, damage = 8 } },
  },
  shrine = {
    name = "Ruined Shrine", background = { .075, .065, .09 }, accent = { .26, .19, .3 },
    entry = { 90, 360 }, next = "shrine_crypt", exit = { x = 1228, y = 360, label = "Shrine Crypt" },
    trees = { {250,120,55}, {250,600,55}, {640,110,45}, {640,610,45}, {1020,120,55}, {1020,600,55} },
  },
  shrine_crypt = {
    name = "Shrine Crypt", background = { .06, .045, .075 }, accent = { .3, .14, .27 },
    entry = { 90, 360 }, next = "mountain_path", exit = { x = 1228, y = 360, label = "Mountain Path" },
    trees = { {210,110,42}, {210,610,42}, {470,115,34}, {760,605,38}, {1040,110,44}, {1040,610,44} },
    hazards = { { x = 430, y = 320, radius = 35, damage = 10 }, { x = 720, y = 450, radius = 35, damage = 10 }, { x = 960, y = 280, radius = 35, damage = 10 } },
  },
  mountain_path = {
    name = "Mountain Path", background = { .05, .045, .065 }, accent = { .27, .08, .13 },
    entry = { 90, 360 }, next = "mountain", exit = { x = 1228, y = 360, label = "Celium's Summit" },
    trees = { {220,100,50}, {310,620,45}, {570,90,48}, {820,625,48}, {1080,100,52}, {1110,610,42} },
    hazards = { { x = 620, y = 260, radius = 38, damage = 12 }, { x = 780, y = 500, radius = 38, damage = 12 } },
  },
  mountain = {
    name = "Black Mountain", background = { .055, .045, .07 }, accent = { .3, .09, .16 },
    entry = { 100, 360 }, exit = nil,
    trees = { {250,100,55}, {250,620,55}, {640,85,65}, {640,635,65}, {1030,100,55}, {1030,620,55} },
  },
}
