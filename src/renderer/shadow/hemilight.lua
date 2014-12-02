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

local gl = require('gl')
local bit = require('bit')
local graphics = require('graphics')
local vec = require('vec')
local flat = require('renderer.flat.model')
local apply = require('renderer.apply')

-- Set up the virtual light camera. This is an orthographic camera that faces
-- in the direction the light points. The frustum for the camera is the
-- bounding box of the view frustum, in light space.
local function createLightCamera(g, light)
  -- Transform the view frusum into light space from clip space
  
  -- Transform to the center of the light, then point in the reverse of the
  -- light direction.
  local lightView = vec.Mat4x4.forward(-light.direction:unit())--:inverse()
  local lightViewInverse = lightView:inverse()

  local sceneCamera = g.camera
  local sceneFar = sceneCamera.far
  sceneCamera.far = sceneCamera.near+light.shadowViewDistance 
  sceneCamera:update()

  local transform = lightViewInverse * sceneCamera.transform:inverse()
  sceneCamera.far = sceneFar
  sceneCamera:update()
  
  local frustum = {
    transform * vec.Vec4(-1, 1, -1, 1), -- near top left
    transform * vec.Vec4(1, 1, -1, 1), -- near top right
    transform * vec.Vec4(1, -1, -1, 1), -- near bottom left
    transform * vec.Vec4(-1, -1, -1, 1), -- near bottom right
    transform * vec.Vec4(-1, 1, 1, 1), -- far top left
    transform * vec.Vec4(1, 1, 1, 1), -- far top right
    transform * vec.Vec4(1, -1, 1, 1), -- far bottom left
    transform * vec.Vec4(-1, -1, 1, 1), -- far bottom right
  } 

  -- Set up parameters for the virtual light camera
  local lightCamera = graphics.Camera()
  lightCamera.mode = 'ortho'
  lightCamera.viewTransform = lightView
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
  lightCamera.near = lightCamera.near - 100
  lightCamera.top = lightCamera.top + 2
  lightCamera.bottom = lightCamera.bottom - 2
  lightCamera.right = lightCamera.right + 2
  lightCamera.left = lightCamera.left - 2

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
  local lightMatrix = lightBias * lightCamera.transform
  light.transform = lightMatrix

  -- Set the viewport to be equal in dimensions to the shadow target.
  light.shadowMap:enable()
  gl.glViewport(0, 0, light.shadowMap.width, light.shadowMap.height)
  gl.glClear(gl.GL_DEPTH_BUFFER_BIT)
  g:glEnable(gl.GL_CULL_FACE, gl.GL_DEPTH_TEST)
  g:glCullFace(gl.GL_FRONT)
  g:commit()
  g.camera = lightCamera

  -- FIXME: Render flat here
  apply.apply(flat.render, g, graphics.Model)
  
  light.shadowMap:disable()
  gl.glViewport(0, 0, sceneCamera.viewport.width, sceneCamera.viewport.height)
  g.camera = sceneCamera
end

return {
  render=render,
}
