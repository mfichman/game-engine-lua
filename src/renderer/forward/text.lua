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
local vec = require('vec')
local struct = require('graphics.struct')

local program
local buffer

local function createDrawBuffer()
  local buffer = graphics.StreamDrawBuffer()
  gl.glBindVertexArray(buffer.vertexArrayId)
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, buffer.id)
  struct.defAttribute('graphics_TextVertex', 0, 'position')
  struct.defAttribute('graphics_TextVertex', 1, 'texcoord')
  gl.glBindVertexArray(0) 
  return buffer
end

-- Render text objects
local function render(g, text)

  local camera = g.camera
  local font = text.font

  program = program or asset.open('shader/forward/Text.prog')
  buffer = buffer or createDrawBuffer()

  g:glUseProgram(program.id)
  g:glDepthMask(gl.GL_FALSE)
  g:glEnable(gl.GL_BLEND, gl.GL_DEPTH_TEST)
  g:glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  g:commit()

  gl.glUniform1i(program.tex, 0)
  gl.glActiveTexture(gl.GL_TEXTURE0)
  gl.glBindTexture(gl.GL_TEXTURE_2D, font.id)
  gl.glUniform4fv(program.color, 1, text.color:data())
  gl.glUniform1i(program.sdf, (font.kind == 'sdf') and 1 or 0)

  -- Pass matrices to the vertex shader
  local worldMatrix = g.worldMatrix * vec.Mat4.scale(text.size, text.size, text.size)
  local worldViewProjectionMatrix = camera.viewProjectionMatrix * worldMatrix

  gl.glUniformMatrix4fv(program.worldViewProjectionMatrix, 1, 0, worldViewProjectionMatrix:data())
  
  -- Render text
  buffer:draw(gl.GL_TRIANGLES, text.vertex)
  gl.glBindVertexArray(0)
end

return {
  render = render,
}
