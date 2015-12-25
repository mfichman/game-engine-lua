-- ========================================================================== --
--                                                                            --
-- Copyright (c) 2015 Matt Fichman <matt.fichman@gmail.com>                   --
--                                                                            --
-- This file is part of Quadrant.  It is subject to the license terms in the  --
-- LICENSE.md file found in the top-level directory of this software package  --
-- and at http://github.com/mfichman/quadrant/blob/master/LICENSE.md.         --
-- No person may use, copy, modify, publish, distribute, sublicense and/or    --
-- sell any part of Quadrant except according to the terms contained in the   --
-- LICENSE.md file.                                                           --
--                                                                            --
-- ========================================================================== --

local Socket = {}; Socket.__index = Socket

local ffi = require('ffi')
local net = ffi.load('net')

function Socket.new()
  local self = {
    sd = ffi.gc(net.net_Socket_new(), net.net_Socket_del),
  }
  return setmetatable(self, Socket)
end

function Socket:connect(host, port)
  local err = net.net_Socket_connect(self.sd, host, port)
  if err ~= net.net_OK then
    return nil, err
  else
    return true
  end
end

function Socket:bind(port)
  local err = net.net_Socket_bind(self.sd, port)
  if err ~= net.net_OK then
    return nil, err
  else
    return true
  end
end

function Socket:accept()
  local new = Socket.new()
  while true do
    local err = net.net_Socket_accept(self.sd, new.sd)
    if err == net.net_OK then
      return new
    elseif err == net.net_YIELD then
      coroutine.yield()
    else
      return nil, err
    end
  end
end

function Socket:listen()
  local err = net.net_Socket_listen(self.sd)
  if err ~= net.net_OK then
    return nil, err
  else
    return true
  end
end

function Socket:read(n)
  local buf = ffi.new('char[?]', n)
  local len = n
  local start = buf

  while true do
    local result = net.net_Socket_read(self.sd, buf, len)
    if net.net_OK == result.err then
      return ffi.string(start, n)
    elseif net.net_YIELD == result.err then 
      buf = buf + result.bytes
      len = len - result.bytes
      coroutine.yield()
    else
      return nil, result.err
    end
  end
end

function Socket:write(...)
  local str = table.concat({...})
  local len = str:len()
  local buf = ffi.new('char[?]', len)
  ffi.copy(buf, str, len)

  while true do
    local result = net.net_Socket_write(self.sd, buf, len)
    if net.net_OK == result.err then
      return true
    elseif net.net_YIELD == result.err then
      buf = buf + result.bytes
      len = len - result.bytes
      coroutine.yield()
    else
      return nil, result.err
    end
  end
end

function Socket:close()
  net.net_Socket_close(self.sd)
end

return Socket.new
