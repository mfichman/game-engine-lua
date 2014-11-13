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

local program, unitQuad, unitSphere

-- Set the light color and attenuation, direction, etc.
local function bindParams(g, light)
  g:glUniform3fv(program.diffuseColor, 1, light.diffuseColor.data)
  g:glUniform3fv(program.backDiffuseColor, 1, light.backDiffuseColor.data)
  g:glUniform3fv(program.specularColor, 1, light.specularColor.data)
  g:glUniform3fv(program.ambientColor, 1, light.ambientColor.data)
  g:glUniform1f(program.atten0, light.constantAttenuation)
  g:glUniform1f(program.atten1, light.linearAttenuation)
  g:glUniform1f(program.atten2, light.quadraticAttenuation)

  -- Transform the light direction from world space into view space
  local transform = g.camera.transform * g.worldTransform
  local direction = transform.mulnormal(light.direction):unit()
  g:glUniform3fv(program.direction, 1, direction.data)
end

-- Shadow mapping. Set the shadow map buffer and light matrix
local function bindShadowMap(g, light)
  if not light.shadowMap then
    g:glUniform1f(program.shadowMapSize, 0)
    return
  end

  gl.glBindTexture(gl.GL_TEXTURE_2D, light.shadowMap.depthBuffer)
  g:glUniform1f(program.shadowMapSize, light.shadowMap.width)

  -- Set the light matrix in the shader, which transforms from view => light
  -- space. This matrix is used for shadow mapping
  local viewToLightTransform = light.transform * g.camera.inverseViewTransform
  g:glUniformMatrix4fv(program.light, 1, 0, viewToLightTransform.data)
end

local function drawMesh(g, mesh)
  mesh:sync()
  gl.glBindVertexArray(mesh.id)
  gl.glDrawElements(gl.GL_TRIANGLES, mesh.index.count, gl.GL_UNSIGNED_INT, 0)
  gl.glBindVertexArray(0)
end

-- Set up the view, projection, and inverse projection transforms to render a
-- fullscreen quad. This covers the case where the light's sphere of influence
-- has infinite radius; thus, all objects are always in the light.
local function drawQuad(g, light)
  local identity = vec.Mat4.identity()
  local inverseProjection = camera.projectionTransform:inverse()
  g:glUniformMatrix4fv(program.transform, 1, 0, identity.data)
  g:glUniformMatrix4fv(program.modelView, 1, 0, identity.data)
  -- Use the identity transform for model/view, so that the specially-shaped
  -- unit quad maps to the whole screen as a fullscreen quad in clip-space, 
  -- that is, x=[-1,1] y=[-1,1]
  g:glUniformMatrix4fv(program.unproject, 1, 0, inverseProjection.data)
  
  drawMesh(g, unitQuad)
end

-- Renders the light's spherical bounding volume. This covers the case where 
-- the light's sphere of influence is finite, and attenuates with distance from 
-- the light's origin.
local function drawSphere(g, light)
  local scaleTransform = vec.Mat4.scale(radius, radius, radius)
  local worldTransform = g.worldTransform * scaleTransform
  local transform = g.camera.transform * worldTransform
  local inverseProjection = g.camera.projectionTransform:inverse()
  local modelView = g.camera.viewTransform * worldTransform
  g:glUniformMatrix4fv(program.transform, 1, 0, transform.data)
  g:glUniformMatrix4fv(program.modelView, 1, 0, modelView.data)
  g:glUniformMatrix4fv(program.unproject, 1, 0, inverseProjection.data)

  drawMesh(g, unitSphere)
end

-- Render a hemispherical light using the deferred lighting technique. This 
-- function renders a light bounding volume using alpha blending. The shader 
-- applies the lighting equation to input from the material G-buffers and 
-- outputs the result to the current back buffer.
local function render(g, light)
  assert(g, 'graphics context is nil')
  assert(light, 'light is nil')

  local radius = light.radiusOfEffect
  if not light:isVisible() or radius < 0 then return end
  
  if not program then
    local asset = require('asset')
    asset.open('shader/LightShapes.obj')
    unitQuad = asset.open('shader/LightShapes.obj/Quad')
    unitSphere = asset.open('shader/LightShapes.obj/Sphere')
    program = asset.open('shader/HemiLight.prog')
  end

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
  g:glBlendFunc(gl.GL_ONE, gl.GL_ONE)
  g:commit()

  bindParams(g, light)
  bindShadowMap(g, light)

  -- Calculate the model transform, and scale the model to cover the light's
  -- area of affect.
  if light.linearAttenuation == 0 and light.quadraticAttenuation == 0 then
    -- If attenuation is 0, then render a fullscreen quad instead of a 
    -- bounding sphere.  This renders a degenerate hemi-light, which is a simple
    -- full-scene directional light.
    drawQuad(g, light)
  else
    drawSphere(g, light)
  end
   
end

return {
  render=render
}
