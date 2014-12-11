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

package.path = './src/?.lua;./src/?/init.lua;'..package.path

local physics = require('physics')
local vec = require('vec')

local world = physics.World()
local shape = physics.SphereShape(1)
local t1 = vec.Transform(vec.Vec3(0, 0, 0), vec.Quat.identity())
local t2 = vec.Transform(vec.Vec3(9, 0, 0), vec.Quat.identity())
local body1 = physics.RigidBody(physics.RigidBodyDesc{mass = 1, shape = shape, transform = t1})
local body2 = physics.RigidBody(physics.RigidBodyDesc{mass = 1, shape = shape, transform = t2})
local constraint = physics.HingeConstraint(body1, body2, t1.origin, t2.origin, vec.Vec3(1), vec.Vec3(1))


world:setGravity(vec.Vec3())

world:addRigidBody(body1, 0, 0)
world:addRigidBody(body2, 0, 0)
world:addConstraint(constraint)

body1:setLinearVelocity(vec.Vec3(1, 0, 0))

for i = 1,10 do
  world:stepSimulation(1/60, 1, 1/60)
end

assert(body1:getPosition().x > 1)
assert(body2:getPosition().x > 1)

world:removeConstraint(constraint)
world:removeRigidBody(body1)
world:removeRigidBody(body2)

