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
local vec = require('vec')
local path = require('path')

local physics = ffi.load('src/physics/physics')

ffi.cdef(path.open('physics/physics.h'):read('*all'))

local function metatype(class, ctor, attr)
  local mt = {}
  local cache = {}

  function mt.__index(t, k)
    if not cache[k] then 
      cache[k] = physics[string.format('%s_%s', class, k)]
    end
    return cache[k] 
  end

  function mt.__gc(t)
    return t:del()
  end

  local t = ffi.metatype(ffi.typeof(class), mt)
  return function(...)
    return physics[ctor](...)
  end
end

metatype('physics_Shape')
metatype('physics_Constraint')

return {
  World = metatype('physics_World', 'physics_World_new'),
  SphereShape = physics['physics_SphereShape_new'],
  CompoundShape = physics['physics_CompoundShape_new'],
  ConvexHullShape = physics['physics_ConvexHullShape_new'],
  HingeConstraint = physics['physics_HingeConstraint_new'],
  RigidBody = metatype('physics_RigidBody', 'physics_RigidBody_new'),
  RigidBodyDesc = ffi.typeof('physics_RigidBodyDesc'),
}
