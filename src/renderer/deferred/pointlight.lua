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

local asset = require('asset')
local gl = require('gl')
local lightvolume = require('renderer.deferred.lightvolume')

local program

-- Set the light color and attenuation, direction, etc.
local function params(g, light)
  gl.glUniform1i(program.diffuseBuffer, 0)
  gl.glUniform1i(program.specularBuffer, 1)
  gl.glUniform1i(program.normalBuffer, 2)
  gl.glUniform1i(program.emissiveBuffer, 3)
  gl.glUniform1i(program.depthBuffer, 4)

  gl.glUniform3fv(program.diffuseColor, 1, light.diffuseColor.data)
  gl.glUniform3fv(program.specularColor, 1, light.specularColor.data)
  gl.glUniform1f(program.atten0, light.constantAttenuation)
  gl.glUniform1f(program.atten1, light.linearAttenuation)
  gl.glUniform1f(program.atten2, light.quadraticAttenuation)
end

local function render(g, light)
  assert(g, 'graphics context is nil')
  assert(light, 'light is nil')

  local radius = light:radiusOfEffect()
  if radius <= 0 then return end

  program = program or asset.open('shader/deferred/PointLight.prog')

  g:glUseProgram(program.id)
  g:glEnable(gl.GL_CULL_FACE, gl.GL_DEPTH_TEST, gl.GL_BLEND, gl.GL_DEPTH_CLAMP) 
  -- Blend lights together with alpha blending.
  -- Use GL_DEPTH_CLAMP to ensures that if the light volume fragment would be
  -- normally clipped by the positive Z, the fragment is still rendered anyway.
  -- Otherwise, you can get "holes" where the light volume intersects the far
  -- clipping plane.   
  g:glCullFace(gl.GL_FRONT)
  -- Render the face of the light volume that's farthest from the camera
  g:glDepthFunc(gl.GL_ALWAYS)
  -- Always render light volume fragments, regardless of depth fail/pass
  g:glDepthMask(gl.GL_FALSE) 
  -- Disable depth writes!
  g:glBlendFunc(gl.GL_ONE, gl.GL_ONE)
  g:commit()

  params(g, light)
  lightvolume.sphere(g, program, radius)  
end

return {
  render=render,
}
