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
local math = require('math')

ffi.cdef[[
  typedef struct vec_Quat {
    union {
      struct {
        union { vec_Scalar w; };
        union { vec_Scalar x; };
        union { vec_Scalar y; };
        union { vec_Scalar z; };
      };
      vec_Scalar data[4];
    };
  } vec_Quat;
]]

local Quat = {}; Quat.__index = Quat
local QuatType = ffi.typeof('vec_Quat')
local Vec3 = require('vec.vec3')

function Quat.new(w, x, y, z)
  if w or x or y or x then
    return QuatType(w, x, y, z)
  else
    return QuatType(1, 0, 0, 0)
  end
end

function Quat.look(xaxis, yaxis, zaxis)
  assert(false)
  
end

function Quat:len(other)
  return math.sqrt(self:len2())
end

function Quat:len2(other)
  return self:dot(self)
end

function Quat:unit()
  local norm = self:len()
  return Quat.new(self.x/norm, self.y/norm, self.z/norm, self.w/norm)
end

local function mulquat(self, q)
  local out = Quat.new()
  out.w = self.w*q.w - self.x*q.x - self.y*q.y - self.z*q.z
  out.x = self.w*q.x + self.x*q.w + self.y*q.z - self.z*q.y
  out.y = self.w*q.y + self.y*q.w + self.z*q.x - self.x*q.z
  out.z = self.w*q.z + self.z*q.w + self.x*q.y - self.y*q.x
  return out
end

local function mulvec3(self, v)
  local qv = Vec3(self.x, self.y, self.z)
  local uv = qv:cross(v)
  local uuv = qv:cross(uv)
  return v+((uv*self.w)+uuv)*2
end

function Quat:__mul(other)
  if other.new == Quat.new then
    return mulquat(self, other)
  elseif other.new == Vec3 then
    return mulvec3(self, other)
  else
    assert(false, 'invalid multiplicand')
  end
end

function Quat:__tostring()
  return string.format('%f, %f, %f, %f', self.w, self.x, self.y, self.z)
end

ffi.metatype(QuatType, Quat)
return Quat.new

--[[
  local kRot = ffi.new('vec_Scalar[3][3]', 
    {xaxis.x, yaxis.x, zaxis.x},
    {xaxis.y, yaxis.y, zaxis.y},
    {xaxis.z, yaxis.z, zaxis.z})
  local fTrace = kRot[0][0]+kRot[1][1]+kRot[2][2]
  local fRoot;
  local self = Quat.new()

  if fTrace > 0 then
    -- |w| > 1/2, may as well choose w > 1/2
    fRoot = math.sqrt(fTrace + 1) -- 2w
    self.w = 0.5*fRoot
    fRoot = 0.5/fRoot  -- 1/(4w)
    self.x = (kRot[2][1]-kRot[1][2])*fRoot
    self.y = (kRot[0][2]-kRot[2][0])*fRoot
    self.z = (kRot[1][0]-kRot[0][1])*fRoot
  else
    -- |w| <= 1/2
    local s_iNext = ffi.new('int[3]', 1, 2, 0)
    local i = 0
    if kRot[1][1] > kRot[0][0] then
      i = 1
    end
    if kRot[2][2] > kRot[i][i] then
      i = 2
    end
    local j = s_iNext[i];
    local k = s_iNext[j];

    fRoot = math.sqrt(kRot[i][i]-kRot[j][j]-kRot[k][k]+1)

    local apkQuat = {}
    apkQuat[i] = 0.5*fRoot
    fRoot = 0.5/fRoot
    self.w = (kRot[k][j]-kRot[j][k])*fRoot
    apkQuat[j] = (kRot[j][i]+kRot[i][j])*fRoot
    apkQuat[k] = (kRot[k][i]+kRot[i][k])*fRoot

    self.x = apkQuat[0]
    self.y = apkQuat[1]
    self.z = apkQuat[2]
  end
  return self
]]
