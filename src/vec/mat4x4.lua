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
local math = require('math')

local Vec3 = require('vec.vec3')
local Vec4 = require('vec.vec4')
local Mat3 = require('vec.mat3')

local Mat4x4 = {}; Mat4x4.__index = Mat4x4
local Mat4x4Type = ffi.typeof('vec_Mat4x4')

Mat4x4.new = Mat4x4Type

function Mat4x4.frustum(left, right, bottom, top, near, far)
  local l, r, b, t, n, f = left, right, bottom, top, near, far
  return Mat4x4.new(
    2*n/(r-l),    0,            0,                0,
    0,            2*n/(t-b),    0,                0,
    (r+l)/(r-l),  (t+b)/(t-b),  -(far+n)/(far-n), -1,
    0,            0,            -2*far*n/(far-n), 0)

end

function Mat4x4.perspective(fov, aspect, near, far)
  local top = math.tan(fov*math.pi/360) * near;
  local bottom = -top;
  local right = aspect * top;
  local left = aspect * bottom;
  return Mat4x4.frustum(left, right, bottom, top, near, far)
end

function Mat4x4.ortho(left, right, bottom, top, near, far)
  local l, r, b, t, n, f = left, right, bottom, top, near, far
  return Mat4x4.new(
    2/(r-l),  0,        0,        0,
    0,        2/(t-b),  0,        0,
    0,        0,        -2/(f-n), 0,
    -(r+l)/(r-l), -(t+b)/(t-b), -(f+n)/(f-n), 1)
end

function Mat4x4.lookAt(eye, at, up)
  local zaxis = (eye - at):unit()
  local xaxis = up:cross(zaxis):unit()
  local yaxis = zaxis:cross(xaxis):unit()
  return Mat4x4.new(
      xaxis.x, yaxis.x, zaxis.x, 0,
      xaxis.y, yaxis.y, zaxis.y, 0,
      xaxis.z, yaxis.z, zaxis.z, 0,
      -xaxis:dot(eye), -yaxis:dot(eye), -zaxis:dot(eye), 1)
end

function Mat4x4.fromAxes(xaxis, yaxis, zaxis)
  return Mat4x4.new(
      xaxis.x, yaxis.x, zaxis.x, 0,
      xaxis.y, yaxis.y, zaxis.y, 0,
      xaxis.z, yaxis.z, zaxis.z, 0,
      0, 0, 0, 1)
end

function Mat4x4.identity()
  return Mat4x4.new(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1) 
end

function Mat4x4.translate(vec3)
  return Mat4x4.new(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    vec3.x, vec3.y, vec3.z, 1)
end

function Mat4x4.scale(x, y, z)
  return Mat4x4.new(
    x, 0, 0, 0,
    0, y, 0, 0,
    0, 0, z, 0,
    0, 0, 0, 1)
end

function Mat4x4.fromForwardVector(forward)
  local zaxis = forward:unit()
  local xaxis = forward:orthogonal():cross(zaxis):unit()
  local yaxis = zaxis:cross(xaxis):unit()

  return Mat4x4.new(
      xaxis.x, yaxis.x, zaxis.x, 0,
      xaxis.y, yaxis.y, zaxis.y, 0,
      xaxis.z, yaxis.z, zaxis.z, 0,
      0, 0, 0, 1)
end

function Mat4x4:zAxis()
  return Vec3(self.d02, self.d06, self.d10)
end

function Mat4x4.rotate(quat)
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

-- FIXME: transpose?
  return Mat4x4.new(
    1-(fTyy+fTzz), fTxy+fTwz, fTxz-fTwy, 0,
    fTxy-fTwz, 1-(fTxx+fTzz), fTyz+fTwx, 0,
    fTxz+fTwy, fTyz-fTwx, 1-(fTxx+fTyy), 0,
    0, 0, 0, 1)
end

function Mat4x4.transform(quat, origin)
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


-- FIXME: transpose?
  local self =  Mat4x4.new(
    1-(fTyy+fTzz), fTxy+fTwz, fTxz-fTwy, 0,
    fTxy-fTwz, 1-(fTxx+fTzz), fTyz+fTwx, 0,
    fTxz+fTwy, fTyz-fTwx, 1-(fTxx+fTyy), 0,
    origin.x, origin.y, origin.z, 1)

  return self
end

function Mat4x4:transpose()
  return Mat4x4.new(
    self.d00, self.d04, self.d08, self.d12,
    self.d01, self.d05, self.d09, self.d13,
    self.d02, self.d06, self.d10, self.d14,
    self.d03, self.d07, self.d11, self.d15)
end

function Mat4x4:inverse()
  local out = Mat4x4.new()

  local m00, m01, m02, m03 = self.d00, self.d04, self.d08, self.d12
  local m10, m11, m12, m13 = self.d01, self.d05, self.d09, self.d13
  local m20, m21, m22, m23 = self.d02, self.d06, self.d10, self.d14
  local m30, m31, m32, m33 = self.d03, self.d07, self.d11, self.d15

  local v0 = m20 * m31 - m21 * m30
  local v1 = m20 * m32 - m22 * m30
  local v2 = m20 * m33 - m23 * m30
  local v3 = m21 * m32 - m22 * m31
  local v4 = m21 * m33 - m23 * m31
  local v5 = m22 * m33 - m23 * m32

  local t00 =   (v5 * m11 - v4 * m12 + v3 * m13)
  local t10 = - (v5 * m10 - v2 * m12 + v1 * m13)
  local t20 =   (v4 * m10 - v2 * m11 + v0 * m13)
  local t30 = - (v3 * m10 - v1 * m11 + v0 * m12)

  local invDet = 1 / (t00 * m00 + t10 * m01 + t20 * m02 + t30 * m03)

  out.d00 = t00 * invDet
  out.d01 = t10 * invDet
  out.d02 = t20 * invDet
  out.d03 = t30 * invDet

  out.d04 = - (v5 * m01 - v4 * m02 + v3 * m03) * invDet
  out.d05 =   (v5 * m00 - v2 * m02 + v1 * m03) * invDet
  out.d06 = - (v4 * m00 - v2 * m01 + v0 * m03) * invDet
  out.d07 =   (v3 * m00 - v1 * m01 + v0 * m02) * invDet

  v0 = m10 * m31 - m11 * m30
  v1 = m10 * m32 - m12 * m30
  v2 = m10 * m33 - m13 * m30
  v3 = m11 * m32 - m12 * m31
  v4 = m11 * m33 - m13 * m31
  v5 = m12 * m33 - m13 * m32

  out.d08 =   (v5 * m01 - v4 * m02 + v3 * m03) * invDet
  out.d09 = - (v5 * m00 - v2 * m02 + v1 * m03) * invDet
  out.d10 =   (v4 * m00 - v2 * m01 + v0 * m03) * invDet
  out.d11 = - (v3 * m00 - v1 * m01 + v0 * m02) * invDet

  v0 = m21 * m10 - m20 * m11
  v1 = m22 * m10 - m20 * m12
  v2 = m23 * m10 - m20 * m13
  v3 = m22 * m11 - m21 * m12
  v4 = m23 * m11 - m21 * m13
  v5 = m23 * m12 - m22 * m13

  out.d12 = - (v5 * m01 - v4 * m02 + v3 * m03) * invDet
  out.d13 =   (v5 * m00 - v2 * m02 + v1 * m03) * invDet
  out.d14 = - (v4 * m00 - v2 * m01 + v0 * m03) * invDet
  out.d15 =   (v3 * m00 - v1 * m01 + v0 * m02) * invDet
  
  return out
end

function Mat4x4:__tostring()
  local buf = {}
  table.insert(buf, string.format('%f, %f, %f, %f\n', self.d00, self.d04, self.d08, self.d12))
  table.insert(buf, string.format('%f, %f, %f, %f\n', self.d01, self.d05, self.d09, self.d13))
  table.insert(buf, string.format('%f, %f, %f, %f\n', self.d02, self.d06, self.d10, self.d14))
  table.insert(buf, string.format('%f, %f, %f, %f\n', self.d03, self.d07, self.d11, self.d15))
  return table.concat(buf)
end

local function mulmat4x4(self, other)
  local out = Mat4x4.new()
  local m1, m2 = other, self

  out.d00 = m1.d00*m2.d00 + m1.d01*m2.d04 + m1.d02*m2.d08 + m1.d03*m2.d12;
  out.d01 = m1.d00*m2.d01 + m1.d01*m2.d05 + m1.d02*m2.d09 + m1.d03*m2.d13;
  out.d02 = m1.d00*m2.d02 + m1.d01*m2.d06 + m1.d02*m2.d10 + m1.d03*m2.d14;
  out.d03 = m1.d00*m2.d03 + m1.d01*m2.d07 + m1.d02*m2.d11 + m1.d03*m2.d15;
  
  out.d04 = m1.d04*m2.d00 + m1.d05*m2.d04 + m1.d06*m2.d08 + m1.d07*m2.d12;
  out.d05 = m1.d04*m2.d01 + m1.d05*m2.d05 + m1.d06*m2.d09 + m1.d07*m2.d13;
  out.d06 = m1.d04*m2.d02 + m1.d05*m2.d06 + m1.d06*m2.d10 + m1.d07*m2.d14;
  out.d07 = m1.d04*m2.d03 + m1.d05*m2.d07 + m1.d06*m2.d11 + m1.d07*m2.d15;
  
  out.d08 = m1.d08*m2.d00 + m1.d09*m2.d04 + m1.d10*m2.d08 + m1.d11*m2.d12;
  out.d09 = m1.d08*m2.d01 + m1.d09*m2.d05 + m1.d10*m2.d09 + m1.d11*m2.d13;
  out.d10 = m1.d08*m2.d02 + m1.d09*m2.d06 + m1.d10*m2.d10 + m1.d11*m2.d14;
  out.d11 = m1.d08*m2.d03 + m1.d09*m2.d07 + m1.d10*m2.d11 + m1.d11*m2.d15;
  
  out.d12 = m1.d12*m2.d00 + m1.d13*m2.d04 + m1.d14*m2.d08 + m1.d15*m2.d12;
  out.d13 = m1.d12*m2.d01 + m1.d13*m2.d05 + m1.d14*m2.d09 + m1.d15*m2.d13;
  out.d14 = m1.d12*m2.d02 + m1.d13*m2.d06 + m1.d14*m2.d10 + m1.d15*m2.d14;
  out.d15 = m1.d12*m2.d03 + m1.d13*m2.d07 + m1.d14*m2.d11 + m1.d15*m2.d15;

  return out
end

local function mulvec4(self, v)
  return Vec4(
    self.d00*v.x + self.d04*v.y + self.d08*v.z + self.d12*v.w,
    self.d01*v.x + self.d05*v.y + self.d09*v.z + self.d13*v.w,
    self.d02*v.x + self.d06*v.y + self.d10*v.z + self.d14*v.w,
    self.d03*v.x + self.d07*v.y + self.d11*v.z + self.d15*v.w)
end

-- Transform a vector & do the perspective divide
local function mulvec3(self, v)
  local invw = 1 / (self.d03*v.x + self.d07*v.y + self.d11*v.z + self.d15);
  
  return Vec3(
    (self.d00*v.x + self.d04*v.y + self.d08*v.z + self.d12)*invw,
    (self.d01*v.x + self.d05*v.y + self.d09*v.z + self.d13)*invw,
    (self.d02*v.x + self.d06*v.y + self.d10*v.z + self.d14)*invw)
end

-- Return 3x3 rotation matrix
function Mat4x4:rotation()
  return Mat3.new(
    self.d00, self.d01, self.d02, 
    self.d04, self.d05, self.d06,
    self.d08, self.d09, self.d10)
end

-- Return origin
function Mat4x4:origin()
  return Vec3(self.d13, self.d14, self.d15)
end

function Mat4x4:data()
  return ffi.cast('vec_Scalar*', self)
end

function Mat4x4:__mul(other)
  if other.new == Mat4x4.new then
    return mulmat4x4(self, other)
  elseif other.new == Vec4 then
    return mulvec4(self, other)
  else
    assert(false, 'invalid multiplicand')
  end
end

ffi.metatype(Mat4x4Type, Mat4x4)
return Mat4x4
