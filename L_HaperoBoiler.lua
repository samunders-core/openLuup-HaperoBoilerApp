-- uncomment next lines when using in 'Lua Code Test'
-- module("L_HaperoBoiler", package.seeall)
-- require("L_HaperoBoilerLcd")

ABOUT = {
  NAME          = "Hapero",
  VERSION       = "2017.09.29",
  DESCRIPTION   = "Hapero boilers integration",
  AUTHOR        = "@sam_",
  COPYRIGHT     = "(c) 2017-",
  DOCUMENTATION = "https://github.com/samunders-core/...",
}

local devNo                      -- our device number
local ip                         -- OBD2 WiFi dongle ip:port
local timeoutSeconds = 5

local function readNonEmptyLines()
  local function iterator(state, i)
    luup.io.intercept(devNo)
    local response = luup.io.read(timeoutSeconds, devNo)
    if response and "" ~= response then
      return response
    end
    return
  end
  return iterator, nil, nil
end

local function log(message)
  if message then
    luup.log(ABOUT.NAME .. " boiler at " .. ip .. " - " .. message)
  end
end

local function status(message)
  local result = not message or "OK" == message
  luup.set_failure(result and 0 or 1)
  return result, message or "OK", ABOUT.NAME
end

local function command(cmd, ...)
  log(cmd)
  luup.io.intercept(devNo)
  if not luup.io.write(cmd, devNo) then
    log("connect call failed")
    return status("CAN-Bus gateway communication failed")
  end      -- should respond with unquoted "cmd\rOK\r\r>"
  for _, expected in ipairs({...}) do
    luup.io.intercept(devNo)
    local response = luup.io.read(timeoutSeconds, devNo)
    if expected == response or ('>' .. expected) == response then
      log(response)
    else
      log(cmd .. " failed - received '" .. (response or "nil") .. "' instead of '" .. expected .. "'")
      return status("CAN-Bus gateway communication failed")
    end
  end
  local message
  for response in readNonEmptyLines() do
    log(cmd .. " - received '" .. response .. "'")
    message = response
  end
  return true, message, ABOUT.NAME
end

local function atCommand(cmd)
  cmd = "AT " .. cmd
  local result, message, name = command(cmd, cmd, "OK")
  return result, message, name
end

function received(data)
  log(data)
end

-- plugin initialisation/reconnect
function pollHapero(d)
  if not devNo then
    devNo = d
  end

  ip = luup.attr_get("ip", devNo)
  if not ip then
    luup.log(ABOUT.NAME .. " manager: missing ip=address:port property")
    return status("CAN-Bus gateway address not set")
  end
  local ipAddress = string.match(ip, '^(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)')
  local ipPort    = string.match(ip, ':(%d+)$')

  log("polling...")
  if d or not luup.io.is_connected(devNo) then
    luup.io.open(devNo, ipAddress, ipPort)
    local cmds = {"L0", "H1", "S1", "SH 07C"}
    for _, cmd in ipairs(cmds) do
      local result, message, name = atCommand(cmd)
      if not result then
        luup.call_delay("pollHapero", 30, luup.devices[devNo].local_udn or tostring(d))
        return status(message)
      end
    end
  end

  local cmd = "DE 00 00"
  local valid, data, name = command(cmd)	-- expecting 07B 8 DE 00 00 00 00 00 FF 00
  if valid then
    luup.call_delay("pollHapero", 30, nil)    -- state changes 1/min tops
    local bytes, removed = string.gsub(data, "(07B 8 DE )", "")
    if 1 == removed then
      log(data .. " = " .. decoDE4bytes(string.sub(bytes, 1, 12)))
    else
      log("protocol mismatch: '" .. data .. "' received as response for '" .. cmd .. "'")
    end
  end

  return status("OK")
end

