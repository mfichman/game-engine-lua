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
local math = require('math')

local Vec3 = require('vec.vec3')
local Vec4 = require('vec.vec4')

local Mat3x3 = {}; Mat3x3.__index = Mat3x3
local Mat3x3Type = ffi.typeof('vec_Mat3x3')

function Mat3x3.new(...)
  return Mat3x3Type(...)
end

function Mat3x3.identity()
  return Mat3x3.new(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1) 
end

function Mat3x3.rotate(quat, origin)
  -- This routine is borrowed from Ogre 3D
  local fTx  = 2*quat.x;
  local fTy  = 2*quat.y;
  local fTz  = 2*quat.z;
  local fTwx = fTx*quat.w;
  local fTwy = fTy*quat.w;
  local fTwz = fTz*quat.w;
  local fTxx = fTx*quat.x;
  local fTxy = fTy*quat.x;
  local fTxz = fTz*quat.x;
  local fTyy = fTy*quat.y;
  local fTyz = fTz*quat.y;
  local fTzz = fTz*quat.z;

  return Mat3x3.new(
    1-(fTyy+fTzz), fTxy+fTwz, fTxz-fTwy,
    fTxy-fTwz, 1-(fTxx+fTzz), fTyz+fTwx,
    fTxz+fTwy, fTyz-fTwx, 1-(fTxx+fTyy))
end

function Mat3x3:transpose()
  return Mat3x3.new(
    self.d00, self.d04, self.d08,
    self.d01, self.d05, self.d09,
    self.d02, self.d06, self.d10)
end

function Mat3x3:__tostring()
  local buf = {}
  for i=0,2 do 
    for j=0,2 do
      if j ~= 0 then 
        table.insert(buf, ', ')
      end
      table.insert(buf, self.data[i+j*4]) 
    end
    table.insert(buf, '\n')
  end
  return table.concat(buf)
end

-- Transform a vector & do the perspective divide
local function mulvec3(self, v)
  return Vec3(
    self.d00*v.x + self.d03*v.y + self.d06*v.z,
    self.d01*v.x + self.d04*v.y + self.d07*v.z,
    self.d02*v.x + self.d05*v.y + self.d08*v.z)
end

function Mat3x3:__mul(other)
  if other.new == Vec3 then
    return mulvec3(self, other)
  else
    assert(false, 'invalid multiplicand')
  end
end

ffi.metatype(Mat3x3Type, Mat3x3)
return Mat3x3
