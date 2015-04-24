-- Copyright (c) 2014 Matt Fichman
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

local ffi = require('ffi')
local lib = require('thread.lib')
local msgpack = require('msgpack')

local Message = {}; Message.__index = Message
local MessageType = ffi.typeof('thread_Message')

function Message.new(args)
  return MessageType()
end

function Message:read()
  local data = ffi.string(self.buffer, self.len)
  return msgpack.unpack(data)
end

function Message:write(data)
  local data = msgpack.pack(data)
  if data:len() > ffi.sizeof(self.buffer) then
    error('message is too large')
  else
    self.len = data:len()
    ffi.copy(self.buffer, data, self.len)
  end
end

ffi.metatype(MessageType, Message)
return Message.new
