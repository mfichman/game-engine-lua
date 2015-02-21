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

local gl = require('gl')
local bit = require('bit')
local graphics = require('graphics')
local vec = require('vec')
local model = require('renderer.flat.model')
local instances = require('renderer.flat.instances')
local apply = require('renderer.apply')

-- Set up the virtual light camera. This is an orthographic camera that faces
-- in the direction the light points. The frustum for the camera is the
-- bounding box of the view frustum, in light space.
local function createLightCamera(g, light)
  -- Transform the view frusum into light space from clip space
  
  -- Transform to the center of the light, then point in the reverse of the
  -- light direction.
  local lightView = vec.Mat4x4.fromForwardVector(-light.direction:unit())--:inverse()
  local lightViewInverse = lightView:transpose()
  -- Since lightView is orthogonal, we can use tranpose instead. Minv =
  -- Mtranspose for an orthogonal matrix M.

  local sceneCamera = g.camera
  local sceneFar = sceneCamera.far
  sceneCamera.far = sceneCamera.near+light.shadowViewDistance 
  sceneCamera:update()

  -- Transform for frustum: device space => world space => light space
  local transform = lightViewInverse * sceneCamera.viewProjectionInvMatrix

  sceneCamera.far = sceneFar
  sceneCamera:update()
  
  local frustum = {
    transform * vec.Vec4(1, 1, 1, 1),
    transform * vec.Vec4(1, 1, -1, 1),
    transform * vec.Vec4(1, -1, 1, 1), 
    transform * vec.Vec4(1, -1, -1, 1),
    transform * vec.Vec4(-1, 1, 1, 1),
    transform * vec.Vec4(-1, 1, -1, 1), 
    transform * vec.Vec4(-1, -1, 1, 1),
    transform * vec.Vec4(-1, -1, -1, 1),
  } 

  -- Set up parameters for the virtual light camera
  local lightCamera = graphics.Camera{}
  lightCamera.mode = 'ortho'
  lightCamera.viewMatrix = lightView
  lightCamera.near = nil
  lightCamera.far = nil
  lightCamera.left = nil 
  lightCamera.right = nil
  lightCamera.top = nil
  lightCamera.bottom = nil

  for i, point in ipairs(frustum) do
    local point = point/point.w -- Perspective divide
    lightCamera.near = math.min(lightCamera.near or point.z, point.z)
    lightCamera.far = math.max(lightCamera.far or point.z, point.z)
    lightCamera.left = math.min(lightCamera.left or point.x, point.x)
    lightCamera.right = math.max(lightCamera.right or point.x, point.x)
    lightCamera.bottom = math.min(lightCamera.bottom or point.y, point.y)
    lightCamera.top = math.max(lightCamera.top or point.y, point.y)
  end 

  -- Include objects behind/off to the side of the camera...note that this
  -- will not work for all scenes. FIXME: Make this margin configurable
  assert(lightCamera.near < lightCamera.far) 
  assert(lightCamera.bottom < lightCamera.top) 
  assert(lightCamera.left < lightCamera.right) 
  lightCamera.near = lightCamera.near - 100
  lightCamera.far = lightCamera.far + 100
  lightCamera.bottom = lightCamera.bottom - 2
  lightCamera.top = lightCamera.top + 2
  lightCamera.left = lightCamera.left - 2
  lightCamera.right = lightCamera.right + 2

  lightCamera.viewport.width = light.shadowMap.width
  lightCamera.viewport.height = light.shadowMap.height
  lightCamera:update()

  return lightCamera
end

-- Render the scene into the shadow map from light perspective
local function render(g, light)
  if not light.shadowMap then return end

  -- Calculate the orthographic bounds for the light. The bounds should include
  -- the entire view frustum, up to the shadow light view distance.
  local sceneCamera = g.camera

  local lightCamera = createLightCamera(g, light)
  local lightBias = vec.Mat4.new(
    .5, 0., 0., 0.,
    0., .5, 0., 0.,
    0., 0., .5, 0.,
    .5, .5, .5, 1.)
  -- Transfrom from clip space to texture space (0, 1) x (0, 1)
  local lightMatrix = lightBias * lightCamera.viewProjectionMatrix
  light.transform = lightMatrix

  -- Set the viewport to be equal in dimensions to the shadow target.
  light.shadowMap:enable()
  gl.glViewport(0, 0, light.shadowMap.width, light.shadowMap.height)
  gl.glClear(gl.GL_DEPTH_BUFFER_BIT)
  g:glEnable(gl.GL_CULL_FACE, gl.GL_DEPTH_TEST)
  g:glCullFace(gl.GL_FRONT)
  g:commit()

  -- FIXME: Render flat here
  apply.apply(model.render, g, graphics.Model, lightCamera)
  apply.apply(instances.render, g, graphics.Instances, lightCamera)
  
  light.shadowMap:disable()
  gl.glViewport(0, 0, sceneCamera.viewport.width, sceneCamera.viewport.height)
end

return {
  render=render,
}
