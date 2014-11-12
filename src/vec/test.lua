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


package.path = package.path..';./?/init.lua'
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

assert(v3.data[0] == 2)
assert(v3.data[1] == 4)
assert(v3.data[2] == 6)
assert(v3.data[3] == 8)
assert(ffi.sizeof(v3) == ffi.sizeof('vec_Scalar')*4)


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

assert(v3.data[0] == 2)
assert(v3.data[1] == 4)
assert(v3.data[2] == 6)
assert(ffi.sizeof(v3) == ffi.sizeof('vec_Scalar')*3)


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

assert(v3.data[0] == 2)
assert(v3.data[1] == 4)
assert(ffi.sizeof(v3) == ffi.sizeof('vec_Scalar')*2)

-- Matrix
local m = vec.Mat4.frustum(-10, 10, -10, 10, -10, 10)
local m = vec.Mat4.perspective(90, 1, 1, 100)
local m = vec.Mat4.look(vec.Vec3(10, 9, 8), vec.Vec3(1, 2, 3), vec.Vec3(0, 1, 0))
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


