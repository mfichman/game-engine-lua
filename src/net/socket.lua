-- Copyright (c) 2016 Matt Fichman
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

local Socket = {}; Socket.__index = Socket

local ffi = require('ffi')
local net = path.load('net')

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
