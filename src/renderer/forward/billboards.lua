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
local graphics = require('graphics')
local asset = require('asset')
local struct = require('graphics.struct')

local program, buffer

-- Define the vertex format for OpenGL, and bind it to a new draw buffer
local function createDrawBuffer()
  local buffer = graphics.StreamDrawBuffer()
  gl.glBindVertexArray(buffer.vertexArrayId)
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, buffer.id)
  struct.defAttribute('graphics_Billboard', 0, 'position')
  struct.defAttribute('graphics_Billboard', 1, 'forward')
  struct.defAttribute('graphics_Billboard', 2, 'right')
  struct.defAttribute('graphics_Billboard', 3, 'color')
  struct.defAttribute('graphics_Billboard', 4, 'width')
  struct.defAttribute('graphics_Billboard', 5, 'height')
  gl.glBindVertexArray(0)
  return buffer
end

-- Render billboards using the streaming draw buffer
local function render(g, billboards)
  if not billboards:visible() then return end

  local camera = g.camera
  local texture = billboards.texture

  program = program or asset.open('shader/forward/Billboards.prog')
  buffer = buffer or createDrawBuffer()

  g:glUseProgram(program.id)
  g:glEnable(gl.GL_BLEND, gl.GL_DEPTH_TEST)
  g:glDepthMask(gl.GL_FALSE)
  if billboards.blendMode == 'alpha' then
    g:glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  elseif billboards.blendMode == 'additive' then
    g:glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE)
  else
    error('invalid particle blend mode')
  end
  g:commit()

  gl.glUniform1i(program.tex, 0)
  gl.glActiveTexture(gl.GL_TEXTURE0)
  gl.glBindTexture(gl.GL_TEXTURE_2D, texture.id)
  gl.glUniform4fv(program.tint, 1, billboards.tint:data())
  
  -- Pass matrices to the shader
  local worldViewProjectionMatrix = camera.viewProjectionMatrix * g.worldMatrix
  gl.glUniformMatrix4fv(program.worldViewProjectionMatrix, 1, 0, worldViewProjectionMatrix:data())

  -- Render the billboards
  buffer:draw(gl.GL_POINTS, billboards.billboard)
  
  if billboards.clearMode == 'auto' then
    billboards.billboard:clear()
  elseif billboards.clearMode == 'manual' then
  else
    error('invalid billboard clear mode')
  end
end

return {
  render = render,
}
