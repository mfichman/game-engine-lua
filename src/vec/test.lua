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
local ffi = require('ffi')

-- Vec4
local v1 = vec.Vec4(1, 2, 3, 4)
local v2 = vec.Vec4(2, 2, 2, 2)
assert(v1:dot(v2) == 20)

local v3 = v1 - v2
assert(v3.x == -1)
assert(v3.y == 0)
assert(v3.z == 1)
assert(v3.w == 2)

local v3 = v1 + v2
assert(v3.x == 3)
assert(v3.y == 4)
assert(v3.z == 5)
assert(v3.w == 6)

local v3 = 2 * v1
assert(v3.x == 2)
assert(v3.y == 4)
assert(v3.z == 6)
assert(v3.w == 8)

assert(v3:data()[0] == 2)
assert(v3:data()[1] == 4)
assert(v3:data()[2] == 6)
assert(v3:data()[3] == 8)
assert(ffi.sizeof(v3) == ffi.sizeof('vec_Scalar')*4)
assert(v3 == vec.Vec4(2, 4, 6, 8))


-- Vec3
local v1 = vec.Vec3(1, 2, 3)
local v2 = vec.Vec3(2, 2, 2)
assert(v1:dot(v2) == 12)

local v3 = v1 - v2
assert(v3.x == -1)
assert(v3.y == 0)
assert(v3.z == 1)

local v3 = v1 + v2
assert(v3.x == 3)
assert(v3.y == 4)
assert(v3.z == 5)

local v3 = 2 * v1
assert(v3.x == 2)
assert(v3.y == 4)
assert(v3.z == 6)

assert(v3:data()[0] == 2)
assert(v3:data()[1] == 4)
assert(v3:data()[2] == 6)
assert(ffi.sizeof(v3) == ffi.sizeof('vec_Scalar')*3)
assert(v3 == vec.Vec3(2, 4, 6))


-- Vec2
local v1 = vec.Vec2(1, 2)
local v2 = vec.Vec2(2, 2)
assert(v1:dot(v2) == 6)

local v3 = v1 - v2
assert(v3.x == -1)
assert(v3.y == 0)

local v3 = v1 + v2
assert(v3.x == 3)
assert(v3.y == 4)

local v3 = 2 * v1
assert(v3.x == 2)
assert(v3.y == 4)

assert(v3:data()[0] == 2)
assert(v3:data()[1] == 4)
assert(ffi.sizeof(v3) == ffi.sizeof('vec_Scalar')*2)

assert(v3 == vec.Vec2(2, 4))

-- Matrix
local m = vec.Mat4.frustum(-10, 10, -10, 10, -10, 10)
local m = vec.Mat4.perspective(90, 1, 1, 100)
local m = vec.Mat4.lookAt(vec.Vec3(10, 9, 8), vec.Vec3(1, 2, 3), vec.Vec3(0, 1, 0))
local m = vec.Mat4.ortho(-10, 100, -10, 10, -10, 10)
local m = vec.Mat4.identity()
local m = vec.Mat4.translate(vec.Vec3(1, 2, 3))
local m = vec.Mat4.scale(1, 2, 3)
local m = vec.Mat4.rotate(vec.Quat.new(1, 2, 3, 8))
local m = vec.Mat4.perspective(90, 1, 1, 100):inverse()

local a = vec.Mat4.translate(vec.Vec3(1, 2, 3))
local b = vec.Mat4.perspective(90, 1, 1, 100)
local m = a * b

local v3 = m * vec.Vec4(1, 2, 3, 4)

local m = vec.Mat4.lookAt(vec.Vec3(0, -15, 30), vec.Vec3(0, 0, 0), vec.Vec3(0, 1, 0))
local v4 = m * vec.Vec4(0, 0, 0, 1)
assert(v4.x == 0)
assert(v4.y == 0)
assert((v4.z - (-33.541019)) < 0.00001)
local v4 = m:inverse() * vec.Vec4(0, 0, 0, 1)
assert(v4.x == 0)
assert(v4.y == -15)
assert(v4.z == 30)

-- Quaternion
local q = vec.Quat.new(1, 2, 3, 4)
local v = q * vec.Vec3(1, 2, 3)
assert(v.x == 25)
assert(v.y == 2)
assert(v.z == -9)
local p = vec.Quat.new(2, 2, 0, 0)
local d = p * q
assert(d.w == -2)
assert(d.x == 6)
assert(d.y == -2)
assert(d.z == 14)


-- Transform
local t = vec.Transform(v, vec.Quat.identity())
local r = vec.Transform(vec.Vec3(), vec.Quat.identity())

local result = t * r
assert(result.origin.x == 25)
assert(result.origin.y == 2)
assert(result.origin.z == -9)
assert(result.rotation.w == 1)
assert(result.rotation.x == 0)
assert(result.rotation.y == 0)
assert(result.rotation.z == 0)


