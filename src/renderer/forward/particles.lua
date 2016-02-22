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
  struct.defAttribute('graphics_Particle', 0, 'position')
  struct.defAttribute('graphics_Particle', 1, 'color')
  struct.defAttribute('graphics_Particle', 2, 'size')
  struct.defAttribute('graphics_Particle', 3, 'rotation')
  gl.glBindVertexArray(0)
  return buffer
end

-- Render a set of particles to the screen using the streaming draw buffer
local function render(g, particles)
  if not particles:visible() then return end
  
  local camera = g.camera
  local texture = particles.texture

  program = program or asset.open('shader/forward/Particles.prog')
  buffer = buffer or createDrawBuffer()
  
  g:glUseProgram(program.id)
  g:glEnable(gl.GL_BLEND, gl.GL_DEPTH_TEST)
  g:glDepthMask(gl.GL_FALSE)
  if particles.blendMode == 'alpha' then
    g:glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  elseif particles.blendMode == 'additive' then
    g:glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE)
  else
    error('invalid particle blend mode')
  end
  g:commit()

  gl.glUniform1i(program.tex, 0)
  gl.glActiveTexture(gl.GL_TEXTURE0)
  gl.glBindTexture(gl.GL_TEXTURE_2D, texture.id)

  gl.glUniform1i(program.depthBuffer, 4)
  -- FIXME: Remove '4' magic number here

  gl.glUniform4fv(program.tint, 1, particles.tint:data()) 

  -- Pass matrices to the vertex shader
  local worldViewMatrix = camera.viewMatrix * g.worldMatrix 
  gl.glUniformMatrix4fv(program.worldViewMatrix, 1, 0, worldViewMatrix:data())

  -- Render the particles to the streaming draw buffer
  buffer:draw(gl.GL_POINTS, particles.particle)

  if particles.clearMode == 'auto' then
    particles.particle:clear()
  elseif particles.clearMode == 'manual' then
  else
    error('invalid particle clear mode')
  end
end

return {
  render = render
}
