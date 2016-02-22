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

local net = require('net')
local ffi = require('ffi')
local dbg = require('dbg')

local l = net.Socket()
assert(l:bind(9000))
assert(l:listen())

local c = net.Socket()
assert(c:connect('127.0.0.1',9000))

local msglen = bit.lshift(1,16)

sender = coroutine.create(function()
  local buf = ffi.new('char[?]', msglen)
  for i=1,100 do
    buf[0] = i
    buf[ffi.sizeof(buf)-1] = i
    local str = ffi.string(buf, ffi.sizeof(buf))
    local _, err = c:write(str)
    assert(_ == true)
  end
  c:close()
end)

receiver = coroutine.create(function()
  local s = l:accept()
  for i=1,100 do
    local buf, err = s:read(msglen)
    assert(buf)
    assert(buf:byte(1) == i)
  end
  s:close()
end)

while coroutine.status(sender) ~= 'dead' and coroutine.status(receiver) ~= 'dead' do
  print(coroutine.resume(sender))
  print(coroutine.resume(receiver))
end






