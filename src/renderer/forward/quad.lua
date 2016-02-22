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

local asset = require('asset')
local gl = require('gl')
local vec = require('vec')

local program, mesh

-- Render a single quad to the screen.
local function render(g, quad)
  local camera = g.camera
  local texture = quad.texture

  if not mesh then asset.open('mesh/Quad.obj') end
  program = program or asset.open('shader/forward/Quad.prog')
  mesh = mesh or asset.open('mesh/Quad.obj/Quad')

  g:glUseProgram(program.id)
  g:glDepthMask(gl.GL_FALSE)
  g:glEnable(gl.GL_BLEND, gl.GL_DEPTH_TEST)
  g:glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  g:commit()

  gl.glUniform1i(program.tex, 0)
  gl.glActiveTexture(gl.GL_TEXTURE0)
  gl.glBindTexture(gl.GL_TEXTURE_2D, texture.id)
  gl.glUniform4fv(program.tint, 1, quad.tint:data())

  -- Pass matrices to the vertex shader
  local worldMatrix
  local scale = vec.Mat4.scale(quad.width, quad.height, 1)
  if quad.mode == 'particle' then
    error('not supported')
  elseif quad.mode == 'normal' then
    worldMatrix = g.worldMatrix * scale
  else
    error('invalid quad mode')
  end
  local worldViewProjectionMatrix = camera.viewProjectionMatrix * worldMatrix
  
  gl.glUniformMatrix4fv(program.worldViewProjectionMatrix, 1, 0, worldViewProjectionMatrix:data())

  -- Render quad
  gl.glBindVertexArray(mesh.id)
  gl.glDrawElements(gl.GL_TRIANGLES, mesh.index.count, gl.GL_UNSIGNED_INT, nil)
  gl.glBindVertexArray(0)
end

return {
  render = render,
}
