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
local gl = require('gl')
local bit = require('bit')

local StreamDrawBuffer = {}; StreamDrawBuffer.__index = StreamDrawBuffer

-- Create a new buffer that streams data to the GPU using buffer orphaning.
function StreamDrawBuffer.new(size)
  local self = setmetatable({}, StreamDrawBuffer)

  local id = ffi.new('GLint[1]')
  gl.glGenBuffers(1, id)
  self.id = id[0]
  gl.glGenVertexArrays(1, id)
  self.vertexArrayId = id[0]

  self.size = size or 8 * bit.lshift(1, 20) -- 8 MB
  self.offset = 0
  self:reset()

  return self
end

function StreamDrawBuffer:del()
  local id = ffi.new('GLint[1]')
  id[0] = self.id
  gl.glDeleteBuffers(1, id)
  id[0] = self.vertexArrayId
  gl.glDeleteVertexArrays(1, id)
end

StreamDrawBuffer.__gc = StreamDrawBuffer.del

-- Orphan and re-create the buffer
function StreamDrawBuffer:reset()
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.id)
  gl.glBufferData(gl.GL_ARRAY_BUFFER, self.size, nil, gl.GL_STREAM_DRAW)
  self.offset = 0
end

-- Copy the buffer data to the CPU and issue a draw command. Note that this
-- requires the vertex format was set independently by a renderer.
function StreamDrawBuffer:draw(kind, buffer)
  local size = buffer.count * buffer.stride
  local free = self.size - self.offset
  assert(size <= self.size, "stream draw buffer is too small")
  if free < size then
    self:reset() -- calls gl.glBindBuffer
  else
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.id)
  end

  local flags = bit.bor(gl.GL_MAP_WRITE_BIT, gl.GL_MAP_UNSYNCHRONIZED_BIT, gl.GL_MAP_INVALIDATE_RANGE_BIT)
  local map = gl.glMapBufferRange(gl.GL_ARRAY_BUFFER, self.offset, size, flags)
  ffi.copy(map, buffer.element, size)
  gl.glUnmapBuffer(gl.GL_ARRAY_BUFFER)
  gl.glBindVertexArray(self.vertexArrayId)
  gl.glDrawArrays(kind, self.offset/buffer.stride, buffer.count)
  gl.glBindVertexArray(0)
  self.offset = self.offset + size 
end

return StreamDrawBuffer.new
