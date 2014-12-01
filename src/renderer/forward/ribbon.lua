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

-- Renders ribbons as a series of point sprites.

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
  struct.defAttribute('graphics_RibbonVertex', 0, 'position')
  struct.defAttribute('graphics_RibbonVertex', 1, 'direction')
  struct.defAttribute('graphics_RibbonVertex', 2, 'index')
  gl.glBindVertexArray(0)
  return buffer
end

-- Render a ribbons to the screen using the streaming draw buffer
local function render(g, ribbon)
  if not ribbon:visible() then return end

  local camera = g.camera
  local texture = ribbon.texture

  program = program or asset.open('shader/forward/Ribbon.prog')
  buffer = buffer or createDrawBuffer()

  g:glUseProgram(program.id)
  g:glEnable(gl.GL_BLEND, gl.GL_DEPTH_TEST)
  g:glDepthMask(gl.GL_FALSE)
  g:glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE)
  g:commit()
  
  gl.glUniform1i(program.tex, 0)
  gl.glActiveTexture(gl.GL_TEXTURE0)
  gl.glBindTexture(gl.GL_TEXTURE_2D, texture.id)

  -- Pass matrices to the vertex shader
  local modelView = camera.viewTransform * g.worldTransform 
  gl.glUniformMatrix4fv(program.modelViewMatrix, 1, 0, modelView:data())
  gl.glUniformMatrix4fv(program.projectionMatrix, 1, 0, camera.projectionTransform:data())

  gl.glUniform1f(program.width, ribbon.width)
  gl.glUniform1f(program.minWidth, ribbon.minWidth)
  gl.glUniform1i(program.count, math.min(ribbon.tail, ribbon.quota))
  gl.glUniform1i(program.tail, ribbon.tail)

  local normalMatrix = modelView:inverse():transpose() 
  local temp = ffi.new('GLfloat[9]', {
    normalMatrix.d00, normalMatrix.d01, normalMatrix.d02, 
    normalMatrix.d04, normalMatrix.d05, normalMatrix.d06, 
    normalMatrix.d08, normalMatrix.d09, normalMatrix.d10, 
  })
  gl.glUniformMatrix3fv(program.normalMatrix, 1, 0, temp)

  -- Render the ribbon
  buffer:draw(gl.GL_TRIANGLES, ribbon.vertex)

end

return {
  render = render,
}
