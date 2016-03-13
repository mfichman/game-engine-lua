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
local graphics = require('graphics')
local asset = require('asset')
local struct = require('graphics.struct')

local program, buffer

-- Define the vertex format for OpenGL, and bind it to a new draw buffer
local function createDrawBuffer()
  local buffer = graphics.StreamDrawBuffer()
  gl.glBindVertexArray(buffer.vertexArrayId)
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, buffer.id)
  struct.defAttribute('graphics_LineVertex', 0, 'position')
  gl.glBindVertexArray(0)
  return buffer
end

local function render(g, line)
  if not line:visible() then return end
  local camera = g.camera
  local texture = line.texture

  program = program or asset.open('shader/forward/Line.prog')
  buffer = buffer or createDrawBuffer()

  g:glUseProgram(program.id)
  g:glEnable(gl.GL_BLEND, gl.GL_DEPTH_TEST)
  g:glDepthMask(gl.GL_FALSE)
  g:glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE)
  g:commit()

  -- Pass matrices to the vertex shader
  local worldViewMatrix = camera.viewProjectionMatrix * g.worldMatrix 
  gl.glUniformMatrix4fv(program.worldViewProjectionMatrix, 1, 0, worldViewMatrix:data())
  gl.glUniform4fv(program.color, 1, line.color:data())

  buffer:draw(gl.GL_LINE_STRIP, line.point)
end

return {
  render = render
}
