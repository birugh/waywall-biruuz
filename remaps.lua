return {
    -- crafts: ow, wo, got
    ["A"] = "O",
    ["O"] = "L",

    -- move to root in piechart
    ["grave"] = "0",
    ["0"] = "grave",

    -- remove word
    ["2"] = "8",
    ["backspace"] = "2",

    -- craft: ket 
    ["Z"] = "S",
    ["S"] = "K",
    ["K"] = "Z",

    -- craft: rm 
    ["3"] = "KPPLUS",

    -- craft: -
    ["X"] = "G",
    ["G"] = "X",

    -- craft: tn 
    ["F"] = "N",

    -- craft: sh 
    ["1"] = "H",

    -- crafts: ie, wi
    ["I"] = "Q",
    ["Q"] = "I",

    -- crafts: be, bre, br, bo, sb
    ["D"] = "B",
    ["B"] = "P",

    -- crafts: el, fl
    ["L"] = "V",
    ["V"] = "A",

    -- crafts: pp, esp
    ["P"] = "C",
    ["C"] = "D",

    -- to easily open piechart, also without crouching
    ["MOUSE4"] = "BACKSPACE",

    -- to select words from end to the beginning
    ["MOUSE5"] = "HOME",
    ["HOME"] = "MOUSE5",
}
