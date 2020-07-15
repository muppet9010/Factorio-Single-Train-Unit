local Colors = {}
--https://www.rapidtables.com/web/color/html-color-codes.html
--Excel conversion string: =CONCATENATE("Colors.", B1, " = {",  SUBSTITUTE(SUBSTITUTE(D1, "(", ""),")",""), ",255}")
-- Custom colors can be added, but shouldn't be removed or changed.

--Custom
Colors.lightred = {255, 100, 100, 255}
Colors.guiheadingcolor = {255, 230, 192, 255}

--Red
Colors.lightsalmon = {255, 160, 122, 255}
Colors.salmon = {250, 128, 114, 255}
Colors.darksalmon = {233, 150, 122, 255}
Colors.lightcoral = {240, 128, 128, 255}
Colors.indianred = {205, 92, 92, 255}
Colors.crimson = {220, 20, 60, 255}
Colors.firebrick = {178, 34, 34, 255}
Colors.red = {255, 0, 0, 255}
Colors.darkred = {139, 0, 0, 255}

--Orange
Colors.coral = {255, 127, 80, 255}
Colors.tomato = {255, 99, 71, 255}
Colors.orangered = {255, 69, 0, 255}
Colors.gold = {255, 215, 0, 255}
Colors.orange = {255, 165, 0, 255}
Colors.darkorange = {255, 140, 0, 255}

--Yellow
Colors.lightyellow = {255, 255, 224, 255}
Colors.lemonchiffon = {255, 250, 205, 255}
Colors.lightgoldenrodyellow = {250, 250, 210, 255}
Colors.papayawhip = {255, 239, 213, 255}
Colors.moccasin = {255, 228, 181, 255}
Colors.peachpuff = {255, 218, 185, 255}
Colors.palegoldenrod = {238, 232, 170, 255}
Colors.khaki = {240, 230, 140, 255}
Colors.darkkhaki = {189, 183, 107, 255}
Colors.yellow = {255, 255, 0, 255}

--Green
Colors.lawngreen = {124, 252, 0, 255}
Colors.chartreuse = {127, 255, 0, 255}
Colors.limegreen = {50, 205, 50, 255}
Colors.lime = {0, 255, 0, 255}
Colors.forestgreen = {34, 139, 34, 255}
Colors.green = {0, 128, 0, 255}
Colors.darkgreen = {0, 100, 0, 255}
Colors.greenyellow = {173, 255, 47, 255}
Colors.yellowgreen = {154, 205, 50, 255}
Colors.springgreen = {0, 255, 127, 255}
Colors.mediumspringgreen = {0, 250, 154, 255}
Colors.lightgreen = {144, 238, 144, 255}
Colors.palegreen = {152, 251, 152, 255}
Colors.darkseagreen = {143, 188, 143, 255}
Colors.mediumseagreen = {60, 179, 113, 255}
Colors.seagreen = {46, 139, 87, 255}
Colors.olive = {128, 128, 0, 255}
Colors.darkolivegreen = {85, 107, 47, 255}
Colors.olivedrab = {107, 142, 35, 255}

--Cyan
Colors.lightcyan = {224, 255, 255, 255}
Colors.cyan = {0, 255, 255, 255}
Colors.aqua = {0, 255, 255, 255}
Colors.aquamarine = {127, 255, 212, 255}
Colors.mediumaquamarine = {102, 205, 170, 255}
Colors.paleturquoise = {175, 238, 238, 255}
Colors.turquoise = {64, 224, 208, 255}
Colors.mediumturquoise = {72, 209, 204, 255}
Colors.darkturquoise = {0, 206, 209, 255}
Colors.lightseagreen = {32, 178, 170, 255}
Colors.cadetblue = {95, 158, 160, 255}
Colors.darkcyan = {0, 139, 139, 255}
Colors.teal = {0, 128, 128, 255}

--Blue
Colors.powderblue = {176, 224, 230, 255}
Colors.lightblue = {173, 216, 230, 255}
Colors.lightskyblue = {135, 206, 250, 255}
Colors.skyblue = {135, 206, 235, 255}
Colors.deepskyblue = {0, 191, 255, 255}
Colors.lightsteelblue = {176, 196, 222, 255}
Colors.dodgerblue = {30, 144, 255, 255}
Colors.cornflowerblue = {100, 149, 237, 255}
Colors.steelblue = {70, 130, 180, 255}
Colors.royalblue = {65, 105, 225, 255}
Colors.blue = {0, 0, 255, 255}
Colors.mediumblue = {0, 0, 205, 255}
Colors.darkblue = {0, 0, 139, 255}
Colors.navy = {0, 0, 128, 255}
Colors.midnightblue = {25, 25, 112, 255}
Colors.mediumslateblue = {123, 104, 238, 255}
Colors.slateblue = {106, 90, 205, 255}
Colors.darkslateblue = {72, 61, 139, 255}

--Purple
Colors.lavender = {230, 230, 250, 255}
Colors.thistle = {216, 191, 216, 255}
Colors.plum = {221, 160, 221, 255}
Colors.violet = {238, 130, 238, 255}
Colors.orchid = {218, 112, 214, 255}
Colors.fuchsia = {255, 0, 255, 255}
Colors.magenta = {255, 0, 255, 255}
Colors.mediumorchid = {186, 85, 211, 255}
Colors.mediumpurple = {147, 112, 219, 255}
Colors.blueviolet = {138, 43, 226, 255}
Colors.darkviolet = {148, 0, 211, 255}
Colors.darkorchid = {153, 50, 204, 255}
Colors.darkmagenta = {139, 0, 139, 255}
Colors.purple = {128, 0, 128, 255}
Colors.indigo = {75, 0, 130, 255}

--Pink
Colors.pink = {255, 192, 203, 255}
Colors.lightpink = {255, 182, 193, 255}
Colors.hotpink = {255, 105, 180, 255}
Colors.deeppink = {255, 20, 147, 255}
Colors.palevioletred = {219, 112, 147, 255}
Colors.mediumvioletred = {199, 21, 133, 255}

--White
Colors.white = {255, 255, 255, 255}
Colors.snow = {255, 250, 250, 255}
Colors.honeydew = {240, 255, 240, 255}
Colors.mintcream = {245, 255, 250, 255}
Colors.azure = {240, 255, 255, 255}
Colors.aliceblue = {240, 248, 255, 255}
Colors.ghostwhite = {248, 248, 255, 255}
Colors.whitesmoke = {245, 245, 245, 255}
Colors.seashell = {255, 245, 238, 255}
Colors.beige = {245, 245, 220, 255}
Colors.oldlace = {253, 245, 230, 255}
Colors.floralwhite = {255, 250, 240, 255}
Colors.ivory = {255, 255, 240, 255}
Colors.antiquewhite = {250, 235, 215, 255}
Colors.linen = {250, 240, 230, 255}
Colors.lavenderblush = {255, 240, 245, 255}
Colors.mistyrose = {255, 228, 225, 255}

--Grey
Colors.gainsboro = {220, 220, 220, 255}
Colors.lightgrey = {211, 211, 211, 255}
Colors.silver = {192, 192, 192, 255}
Colors.darkgrey = {169, 169, 169, 255}
Colors.grey = {128, 128, 128, 255}
Colors.dimgrey = {105, 105, 105, 255}
Colors.lightslategrey = {119, 136, 153, 255}
Colors.slategrey = {112, 128, 144, 255}
Colors.darkslategrey = {47, 79, 79, 255}
Colors.black = {0, 0, 0, 255}

--Brown
Colors.cornsilk = {255, 248, 220, 255}
Colors.blanchedalmond = {255, 235, 205, 255}
Colors.bisque = {255, 228, 196, 255}
Colors.navajowhite = {255, 222, 173, 255}
Colors.wheat = {245, 222, 179, 255}
Colors.burlywood = {222, 184, 135, 255}
Colors.tan = {210, 180, 140, 255}
Colors.rosybrown = {188, 143, 143, 255}
Colors.sandybrown = {244, 164, 96, 255}
Colors.goldenrod = {218, 165, 32, 255}
Colors.peru = {205, 133, 63, 255}
Colors.chocolate = {210, 105, 30, 255}
Colors.saddlebrown = {139, 69, 19, 255}
Colors.sienna = {160, 82, 45, 255}
Colors.brown = {165, 42, 42, 255}
Colors.maroon = {128, 0, 0, 255}

return Colors
