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

local vec = require('vec')
local gl = require('gl')
local ffi = require('ffi')

local Camera = {}; Camera.__index = Camera

ffi.cdef[[
struct graphics_CameraBuffer {
  vec_Mat4x4 projectionMatrix;
  vec_Mat4x4 projectionInvMatrix;
  vec_Mat4x4 viewMatrix;
  vec_Mat4x4 viewInvMatrix;
  vec_Mat4x4 viewProjectionMatrix;
  vec_Mat4x4 viewProjectionInvMatrix;
} graphics_CameraBuffer;
]]

local CameraBuffer = ffi.typeof('struct graphics_CameraBuffer')


-- Creates a new orthographic or perspective camera object
function Camera.new(args)
  local handle = gl.Handle(gl.glGenBuffers, gl.glDeleteBuffers)
  local id = handle[0]
  local self = {
    projectionMatrix = vec.Mat4.identity(),
    projectionInvMatrix = vec.Mat4.identity(),
    viewMatrix = vec.Mat4.identity(),
    viewInvMatrix = vec.Mat4.identity(), 
    viewProjectionMatrix = vec.Mat4.identity(),
    viewProjectionInvMatrix = vec.Mat4.identity(),
    far = args and args.far or 1000,
    near = args and args.near or .1,
    left = args and args.left or 0,
    right = args and args.right or 0,
    top = args and args.top or 0,
    bottom = args and args.bottom or 0,
    viewport = args and args.viewport or vec.Vec2(),
    fieldOfView = args and args.fieldOfView or 45,
    mode = args and args.mode or 'perspective',
    handle = handle,
    id = handle[0],
  }

  local self = setmetatable(self, Camera)
  self:update()
  return self
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
  self.viewProjectionInvMatrix = self.viewProjectionMatrix:inverse()


  local buffer = CameraBuffer {
    projectionMatrix = self.projectionMatrix,
    projectionInvMatrix = self.projectionInvMatrix,
    viewMatrix = self.viewMatrix,
    viewInvMatrix = self.viewInvMatrix,
    viewProjectionMatrix = self.viewProjectionMatrix,
    viewProjectionInvMatrix = self.viewProjectionInvMatrix,
  }
  gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, self.id)
  gl.glBufferData(gl.GL_UNIFORM_BUFFER, ffi.sizeof(buffer), buffer, gl.GL_STATIC_DRAW)
end

return Camera.new
