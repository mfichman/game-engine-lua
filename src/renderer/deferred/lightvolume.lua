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
local vec = require('vec')

local unitQuad, unitSphere, unitCone

local function mesh(g, program, mesh)
  mesh:sync()
  gl.glBindVertexArray(mesh.id)
  gl.glDrawElements(gl.GL_TRIANGLES, mesh.index.count, gl.GL_UNSIGNED_INT, nil)
  gl.glBindVertexArray(0)
end

-- Set up the view, projection, and inverse projection transforms to render a
-- fullscreen quad. This covers the case where the light's sphere of influence
-- has infinite radius; thus, all objects are always in the light.
local function quad(g, program)
  if not unitQuad then asset.open('mesh/LightShapes.obj') end
  unitQuad = unitQuad or asset.open('mesh/LightShapes.obj/Quad')

  local identity = vec.Mat4.identity()
  local inverseProjection = g.camera.inverseProjectionTransform
  gl.glUniformMatrix4fv(program.transform, 1, 0, identity:data())
  gl.glUniformMatrix4fv(program.modelViewMatrix, 1, 0, identity:data())
  -- Use the identity transform for model/view, so that the specially-shaped
  -- unit quad maps to the whole screen as a fullscreen quad in clip-space, 
  -- that is, x=[-1,1] y=[-1,1]
  gl.glUniformMatrix4fv(program.unprojectMatrix, 1, 0, inverseProjection:data())
  mesh(g, program, unitQuad)
end

-- Renders the light's spherical bounding volume. This covers the case where 
-- the light's sphere of influence is finite, and attenuates with distance from 
-- the light's origin.
local function sphere(g, program, radius)
  if not unitSphere then asset.open('mesh/LightShapes.obj') end
  unitSphere = unitSphere or asset.open('mesh/LightShapes.obj/Sphere')

  local scale = vec.Mat4.scale(radius, radius, radius)
  local worldTransform = g.worldTransform * scale
  local transform = g.camera.transform * worldTransform
  local modelView = g.camera.viewTransform * worldTransform
  local inverseProjection = g.camera.inverseProjectionTransform
  gl.glUniformMatrix4fv(program.transform, 1, 0, transform:data())
  gl.glUniformMatrix4fv(program.modelViewMatrix, 1, 0, modelView:data())
  gl.glUniformMatrix4fv(program.unprojectMatrix, 1, 0, inverseProjection:data())
  mesh(g, program, unitSphere)
end

-- Renders the light's conical bounding volume.
local function cone(g, program, radius, cutoff, direction)
  if not unitCone then asset.open('mesh/LightShapes.obj') end
  unitCone = unitCone or asset.open('mesh/LightShapes.obj/Cone')

  -- Scale the model to cover the light's area of effect
  local margin = 2
  local maxRadius = 500
  local radius = math.min(maxRadius, radius)
  local cutoff = cutoff+margin
  local width = math.tan(math.pi*cutoff/180)
  local sx = width*radius
  local sy = width*radius
  local sz = radius

  -- Transform the light to point in the correct direction
  local rotate = vec.Mat4.forward(-direction)
  local scale = vec.Mat4.scale(sx, sy, sz)
  local worldTransform = g.worldTransform * rotate * scale  
  local transform = g.camera.transform * worldTransform
  local modelView = g.camera.viewTransform * worldTransform
  local inverseProjection = g.camera.inverseProjectionTransform
  gl.glUniformMatrix4fv(program.transform, 1, 0, transform:data())
  gl.glUniformMatrix4fv(program.modelViewMatrix, 1, 0, modelView:data())
  gl.glUniformMatrix4fv(program.unprojectMatrix, 1, 0, inverseProjection:data())
  mesh(g, program, unitCone)
end

return {
  sphere=sphere,
  mesh=mesh,
  quad=quad,
  cone=cone,
}
