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

local ffi = require('ffi')
local vec = require('vec')
local path = require('path')

local physics = path.load('physics')
ffi.cdef(path.open('physics/physics.h'):read('*all'))

local function metatype(class)
  local mt = {}
  local cache = {}

  function mt.__index(t, k)
    if not cache[k] then 
      cache[k] = physics[string.format('%s_%s', class, k)]
    end
    return cache[k] 
  end

  return ffi.metatype(ffi.typeof(class), mt)
end

local function ctor(mt, ctor)
  return function(...)
    return ffi.gc(physics[ctor](...), mt.del)
  end
end

local Shape = metatype('physics_Shape')
local Constraint = metatype('physics_Constraint')
local World = metatype('physics_World')
local Manifold = metatype('physics_Manifold')
local RigidBody = metatype('physics_RigidBody')

return {
  World = ctor(World, 'physics_World_new'),
  SphereShape = ctor(Shape, 'physics_SphereShape_new'),
  CylinderShape = ctor(Shape, 'physics_CylinderShape_new'),
  CompoundShape = ctor(Shape, 'physics_CompoundShape_new'),
  ConvexHullShape = ctor(Shape, 'physics_ConvexHullShape_new'),
  BvhTriangleMeshShape = ctor(Shape, 'physics_BvhTriangleMeshShape_new'),
  HingeConstraint = ctor(Constraint, 'physics_HingeConstraint_new'),
  RigidBody = ctor(RigidBody, 'physics_RigidBody_new'),
  RigidBodyDesc = ffi.typeof('physics_RigidBodyDesc'),
  Manifold = Manifold,

  NONE = 0,
  BULLET = 1,
  SOLID = 2,
  SHIELD = 4,

  STATIC_OBJECT = physics.physics_STATIC_OBJECT,
  KINEMATIC_OBJECT = physics.physics_KINEMATIC_OBJECT,
  NO_CONTACT_RESPONSE = physics.physics_NO_CONTACT_RESPONSE,
  CUSTOM_MATERIAL_CALLBACK = physics.physics_CUSTOM_MATERIAL_CALLBACK,
  CHARACTER_OBJECT = physics.physics_CHARACTER_OBJECT,
  DISABLE_VISUALIZE_OBJECT = physics.physics_DISABLE_VISUALIZE_OBJECT,
  DISABLE_SPU_COLLISION_PROCESSING = physics.physics_DISABLE_SPU_COLLISION_PROCESSING,

  ACTIVE_TAG = physics.physics_ACTIVE_TAG,
  ISLAND_SLEEPING = physics.physics_ISLAND_SLEEPING,
  WANTS_DEACTIVATION = physics.physics_WANTS_DEACTIVATION,
  DISABLE_DEACTIVATION = physics.physics_DISABLE_DEACTIVATION,
  DISABLE_SIMULATION = physics.physics_DISABLE_SIMULATION,

}
