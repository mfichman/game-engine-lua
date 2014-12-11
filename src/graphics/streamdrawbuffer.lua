-- ========================================================================== --
--                                                                            --
-- Copyright (c) 2014 Matt Fichman <matt.fichman@gmail.com>                   --
--                                                                            --
-- This file is part of Quadrant.  It is subject to the license terms in the  --
-- LICENSE.md file found in the top-level directory of this software package  --
-- and at http://github.com/mfichman/quadrant/blob/master/LICENSE.md.         --
-- No person may use, copy, modify, publish, distribute, sublicense and/or    --
-- sell any part of Quadrant except according to the terms contained in the   --
-- LICENSE.md file.                                                           --
--                                                                            --
-- ========================================================================== --

local ffi = require('ffi')
local gl = require('gl')
local bit = require('bit')

local StreamDrawBuffer = {}; StreamDrawBuffer.__index = StreamDrawBuffer

-- Create a new buffer that streams data to the GPU using buffer orphaning.
function StreamDrawBuffer.new(size)
  local self = {
    size = size or 64 * bit.lshift(1, 10), -- 64K
    offset = 0,
    handle = gl.Handle(gl.glGenBuffers, gl.glDeleteBuffers),
    id = 0,
    vertexArrayHandle = gl.Handle(gl.glGenVertexArrays, gl.glDeleteVertexArrays),
    vertexArrayId = 0,
  }

  self.id = self.handle[0]
  self.vertexArrayId = self.vertexArrayHandle[0]

  setmetatable(self, StreamDrawBuffer)
  self:reset()

  return self
end

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
