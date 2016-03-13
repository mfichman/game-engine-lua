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

local thread = require('thread')
local ffi = require('ffi')
local debug = require('debug')
local os = require('os')

local Worker = {}; Worker.__index = Worker

-- Create a new worker instance.
function Worker.new(args) 
  local self = {
    func = {},
    nextCallId = 0,
    nextReturnId = 1,
  }
  return setmetatable(self, Worker)
end

-- Register a worker function by name. The ctype argument is the type of the
-- parameter that 'func' takes as an argument.
function Worker:register(func)
  local info = debug.getinfo(func)
  local name = info.source..':'..info.linedefined
  self.func[name] = func
end

-- Submit a new job/message to the worker. 'msg' must be a ctype. Returns the
-- job ID as an integer.
function Worker:call(func, ...)
  local info = debug.getinfo(func)
  local name = info.source..':'..info.linedefined
  local msg = {...}
  self.thread:send(name)
  self.thread:send(msg)
  self.nextCallId = self.nextCallId+1

  local id = self.nextCallId
  while true do
    local msg = self:poll(id)
    if msg then 
      return unpack(msg)
    else
      coroutine.yield()
    end
  end
end

-- Poll for the result of a previous call.
function Worker:poll(id)
  if id ~= self.nextReturnId then
    return false
  else
    local name = self.thread:poll()
    if not name then
      return false
    end
    self.nextReturnId = self.nextReturnId+1
    return self.thread:recv(ret)
  end
end

function Worker:run()
  if thread.current() == nil then
    local file = debug.getinfo(2,'S').source
    local file = file:sub(2)
    if not self.thread then
      self.thread = thread.Thread{file = file}
    end
    return true
  end

  while true do
    local name = thread.recv()
    local msg = thread.recv()
    local func = self.func[name]
    local ret = {func(unpack(msg))}
    thread.send(name)
    thread.send(ret)
  end
end

return Worker.new
