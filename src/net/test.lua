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






