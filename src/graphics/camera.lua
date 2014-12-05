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

local vec = require('vec')

local Camera = {}; Camera.__index = Camera

-- Creates a new orthographic or perspective camera object
function Camera.new(args)
  local self = {
    projectionMatrix = vec.Mat4.identity(),
    projectionInvMatrix = vec.Mat4.identity(),
    viewMatrix = vec.Mat4.identity(),
    viewInvMatrix = vec.Mat4.identity(), 
    viewProjectionMatrix = vec.Mat4.identity(),
    far = 1000,
    near = .1,
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
    viewport = vec.Vec2(),
    fieldOfView = 45,
    mode = 'perspective',
  }
  return setmetatable(self, Camera)
end

-- Update the computed transforms from the view transform and projection 
-- transform values.
function Camera:update()
  if self.mode == 'ortho' then
    self.projectionMatrix = vec.Mat4.ortho(self.left, self.right, self.bottom, self.top, self.near, self.far)
  elseif self.mode == 'perspective' then
    local aspectRatio = self.viewport.width/self.viewport.height
    self.projectionMatrix = vec.Mat4.perspective(self.fieldOfView, aspectRatio, self.near, self.far)
  else
    error('invalid camera mode')
  end

  self.projectionInvMatrix = self.projectionMatrix:inverse()
  self.viewInvMatrix = self.viewMatrix:inverse()
  self.viewProjectionMatrix = self.projectionMatrix * self.viewMatrix
end

return Camera.new
