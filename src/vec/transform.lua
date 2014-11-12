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
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, APEXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

local ffi = require('ffi')

local Vec3 = require('vec.vec3')
local Quat = require('vec.quat')

ffi.cdef[[
  typedef struct vec_Transform {
    vec_Vec3 origin;
    vec_Quat rotation;
  } vec_Transform;
]]

local Transform = {}; Transform.__index = Transform
local TransformType = ffi.typeof('vec_Transform')
  
function Transform.new(...)
  return TransformType(...)
end

function Transform.identity()
  return Transform.new(Vec3(), Quat(1, 0, 0, 0))
end

function Transform:__mul(other)
  return Transform.new(
    self.rotation * other.origin + self.origin,
    self.rotation * other.rotation)
end

ffi.metatype(TransformType, Transform)
return Transform