-- module("L_HaperoBoilerLcd", package.seeall)

local t = {
	["12"] = ' ',
	["DA"] = '2',
	["F2"] = '3',
	["66"] = '4',
	["B6"] = '5',
	["BE"] = '6',
	["E0"] = '7',
	["FE"] = '8',
	["F6"] = '9',
	["FC"] = '0',
	["9E"] = 'E',
	["CE"] = 'P',
	["02"] = '-',
	["00"] = '-',
	["1C"] = 'L',
	["6E"] = 'H',
-- 	["FC"] = 'O',
	["3B"] = 'o',
	["2A"] = 'n',
	["8E"] = 'F',
	["9C"] = 'C',
	["EE"] = 'A',
-- 	["EE"] = 'R',
	["0B"] = 'r',
	["7A"] = 'd',
	["F4"] = 'J',
	["21"] = 'i',
	["3F"] = 'b',
-- 	["B6"] = 'S',
	["7C"] = 'V',
-- 	["7C"] = 'U',
-- 	["BF"] = 'G', -- prevents 6
	["39"] = 'u',
	["1E"] = 't',
	["2E"] = 'h',
	["3A"] = 'a',
	["77"] = 'y',
	["ED"] = 'm',
-- 	["E1"] = 'Q', -- prevents 7
	["63"] = '<',
	["0F"] = '>',
	["1D"] = 'q',
	["11"] = '_',
	["81"] = '#',
	["C7"] = ':',
-- 	["3B"] = '.',
-- 	["9C"] = '[',
	["F0"] = ']',
	["0C"] = 'X',
	["6C"] = 'M',
	["60"] = '1'
}

function decoDEbyte(hex, dot)
  local result = t[hex]
  if not result then
    if dot then
      local c = hex.byte(2)
      c = 1 == (c % 2) and c - 1 or (c + 1)
      hex = string.gsub(hex, "(%w)%w( )", "%1" .. c .. "%2")
      return decoDEbyte(hex) .. '.'
    end
  end
  return (result or hex) .. (dot or '')
end

function decoDE4bytes(hex)
  luup.log(hex)
  local result = ""
  for hexByte in string.gmatch(hex, "%w%w") do
    result = result .. decoDEbyte(hexByte, ' ')
  end
  return result
end

