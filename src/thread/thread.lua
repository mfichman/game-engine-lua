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

local ffi = require('ffi')
local lib = require('thread.lib')

local Message = require('thread.message')

local Thread = {}; Thread.__index = Thread
local ThreadType = ffi.typeof('thread_Thread')

-- Create a new thread, and immediately start executing it. The first argument
-- is the path to a Lua file to pass to luaL_dofile when the new thread starts.
-- The new thread begins executing this file in a new lua state.
function Thread.new(args)
  return lib.thread_Thread_new(args.file) 
end

-- Send a message to the thread. The 'data' argument must be an FFI C struct.
-- This struct is copied into a fixed-size message type that's added to the
-- message queue of the thread.
function Thread:send(data)
  local msg = Message()
  msg:write(data)
  return lib.thread_Thread_send(self, msg)
end

-- Wait for another thread to send a message to this thread. When the message
-- is received, copy it into the FFI C struct given in 'data'.
function Thread:recv()
  local msg = Message()
  local err = lib.thread_Thread_recv(self, msg)
  assert(err == lib.thread_ok)
  return msg:read()
end

-- Poll to determine if another thread has sent a message. If the thread has a
-- waiting message, then poll() dequeues it and returns true. Otherwise, poll()
-- returns false immediately.
function Thread:poll()
  local msg = Message()
  local err = lib.thread_Thread_poll(self, msg)
  if err == lib.thread_empty then
    return nil
  else
    return msg:read()
  end
end

function Thread:join()
  lib.thread_Thread_join(self)
end

ffi.metatype(ThreadType, Thread)

return Thread.new
