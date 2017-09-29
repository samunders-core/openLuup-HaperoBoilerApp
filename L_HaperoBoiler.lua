ABOUT = {
  NAME          = "Hapero",
  VERSION       = "2017.09.29",
  DESCRIPTION   = "Hapero boilers integration",
  AUTHOR        = "@sam_",
  COPYRIGHT     = "(c) 2017-",
  DOCUMENTATION = "https://github.com/samunders-core/...",
}

-- plugin initialisation
function hbStartup(d, relayId, controllerId)
  devNo = d  
  _log "starting..." 
  display (ABOUT.NAME,'')  
  
  do -- version number
    local y,m,d = ABOUT.VERSION:match "(%d+)%D+(%d+)%D+(%d+)"
    local version = ("v%d.%d.%d"): format (y%2000,m,d)
    setVar ("Version", version)
    _log (version)
  end
  
  set_failure (0)
  return true, "OK", ABOUT.NAME
end
