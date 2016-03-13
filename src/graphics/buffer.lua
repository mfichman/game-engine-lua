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
local gl = require('gl')
local math = require('math')

local Buffer = {}; Buffer.__index = Buffer

-- Create a new attribute or index buffer that is an array of the elements 
-- indicated by 'kind'
function Buffer.new(target, usage, buffer)
  local handle = gl.Handle(gl.glGenBuffers, gl.glDeleteBuffers)
  local id = handle[0]
  local size = buffer.stride * buffer.count
  gl.glBindBuffer(target, id)
  gl.glBufferData(target, size, buffer.element, usage)

  local self = {
    id = handle[0],
    handle = handle,
    target = target,
    usage = usage,
    count = buffer.count,
    stride = buffer.stride,
  }
  return setmetatable(self, Buffer)
end

return Buffer.new
