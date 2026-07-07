return {
  forest = {
    name = "Cursed Forest", background = { .045, .075, .065 }, accent = { .12, .22, .14 },
    entry = { 95, 360 }, exit = { x = 1228, y = 360, label = "Ruined Shrine" },
    trees = { {190,130,35}, {330,570,45}, {510,170,30}, {720,590,40}, {930,135,36}, {1080,580,45} },
  },
  shrine = {
    name = "Ruined Shrine", background = { .075, .065, .09 }, accent = { .26, .19, .3 },
    entry = { 90, 360 }, exit = { x = 1228, y = 360, label = "Black Mountain" },
    trees = { {250,120,55}, {250,600,55}, {640,110,45}, {640,610,45}, {1020,120,55}, {1020,600,55} },
  },
  mountain = {
    name = "Black Mountain", background = { .055, .045, .07 }, accent = { .3, .09, .16 },
    entry = { 100, 360 }, exit = nil,
    trees = { {250,100,55}, {250,620,55}, {640,85,65}, {640,635,65}, {1030,100,55}, {1030,620,55} },
  },
}

