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
