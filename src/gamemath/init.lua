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

-- Commonly-used math functions for 3D games. These are functions that don't
-- necessarily belong in the vec package, but mostly deal with 3D math (i.e.,
-- plane intersects, clamping, view/device/world transforms, etc.)

local vec = require('vec')

-- Clamps a value to the range defined by [min max]
local function clamp(val, min, max)
  return math.min(math.max(val, min), max)
end

-- Given a line and a plane, compute the intersection.  The line is defined
-- by a point on the line (l0) and the vector in the direction of the line
-- (ln).  The plane is defined by a point on the plane (p0) and the plane's
-- normal (pn).
--
-- http://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection#Algebraic_form
local function rayPlaneIntersect(ray, p0, pn)
  local l0 = ray.origin
  local ln = ray.direction
  local d = (p0-l0):dot(pn) / ln:dot(pn)
  return ln * d + l0
end

-- Convert device coordinates (i.e., [-1 1] x [-1 1]) to world coordinates.
local function deviceToWorld(camera, device)
  local device = vec.Vec4(device.x, device.y, device.z, 1)

  -- World coordinates; do perspective divide
  local world = camera.transform:inverse() * device  
  return world/world.w
end

-- Convert screen coordinates (i.e., [0, width] x [0 height]) to world coordinates.
local function screenToWorld(camera, screen)
  local device = vec.Vec3()
  device.x = clamp(2*screen.x/camera.viewport.width-1, -1, 1)
  device.y = clamp(1-2*screen.y/camera.viewport.height, -1, 1)
  device.z = 0
  return deviceToWorld(camera, device)
end

-- Returns a world-space picking ray that passes from a point in screen space
-- through the camera. Returns {origin = ?, vector = ?}.
local function pickRay(camera, screen)
  -- Find a ray from the mouse to the camera in world space, and then intersect
  -- the ray with the z = 0 plane. Point the thruster in that direction.
  local cameraWorld = camera.viewTransform:inverse() * vec.Vec4(0, 0, 0, 1)
  local ray = {}
  ray.origin = screenToWorld(camera, screen)
  ray.direction = (ray.origin-cameraWorld):unit()
  ray.direction = vec.Vec3(ray.direction.x, ray.direction.y, ray.direction.z)
  return ray
end

return {
  clamp = clamp,
  rayPlaneIntersect = rayPlaneIntersect,
  screenToWorld = screenToWorld,
  deviceToWorld = derviceToWorld,
  pickRay = pickRay,
}
