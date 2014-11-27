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
package.path = './src/?.lua;./src/?/init.lua;'..package.path

local physics = require('physics')
local vec = require('vec')

local world = physics.World()
local shape = physics.SphereShape(1)
local t1 = vec.Transform(vec.Vec3(0, 0, 0), vec.Quat())
local t2 = vec.Transform(vec.Vec3(9, 0, 0), vec.Quat())
local body1 = physics.RigidBody(physics.RigidBodyDesc{mass = 1, shape = shape, transform = t1})
local body2 = physics.RigidBody(physics.RigidBodyDesc{mass = 1, shape = shape, transform = t2})
local constraint = physics.HingeConstraint(body1, body2, t1.origin, t2.origin, vec.Vec3(1), vec.Vec3(1))

world:setGravity(vec.Vec3())
world:addRigidBody(body1)
world:addRigidBody(body2)
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
body1:del()
body2:del()
shape:del()
world:del()


