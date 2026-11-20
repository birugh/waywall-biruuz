return {
    -- crafts: ow, wo, got
    ["A"] = "O",
    ["O"] = "L",

    -- move to root in piechart
    ["grave"] = "0",
    ["0"] = "grave",

    -- remove word
    ["2"] = "8",
    ["8"] = "2",

    -- craft: ket 
    ["Z"] = "K",
    ["K"] = "Z",

    -- craft: rm 
    ["3"] = "KPPLUS",
    ["KPPLUS"] = "3",

    -- craft: -
    ["X"] = "A",
    ["G"] = "X",

    -- craft: tn 
    ["F"] = "N",
    ["N"] = "F",

    -- craft: sh 
    ["1"] = "H",
    ["H"] = "1",

    -- crafts: ie, wi
    ["I"] = "Q",
    ["Q"] = "I",

    -- crafts: be, bre, br, bo, sb
    ["D"] = "B",
    ["B"] = "P",

    -- crafts: el, fl
    ["L"] = "V",
    ["V"] = "G",

    -- crafts: pp, esp
    ["P"] = "C",
    ["C"] = "D",

    -- to easily open piechart, also without crouching
    ["MOUSE4"] = "BACKSPACE",
    ["BACKSPACE"] = "MOUSE4",

    -- to select words from end to the beginning
    ["MOUSE5"] = "HOME",
    ["HOME"] = "MOUSE5",
}
