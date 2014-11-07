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

local vec = require('vec')
local ffi = require('ffi')
local math = require('math')

ffi.cdef[[
  struct vec_Mat4x4 {
    vec_Scalar data[16];
  };
]]

local Mat4x4 = {}; Mat4x4.__index = Mat4x4;
local Mat4x4Type = ffi.typeof('struct vec_Mat4x4')

function Mat4x4.new(...)
  return Mat4x4Type({{...}})
end

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

function Mat4x4.look(eye, at, up)
  local zaxis = (eye - at):unit()
  local xaxis = up:cross(zaxis):unit()
  local yaxis = zaxis:cross(xaxis):unit()
  return Mat4x4.new(
      xaxis.x, yaxis.x, zaxis.x, 0,
      xaxis.y, yaxis.y, zaxis.y, 0,
      xaxis.z, yaxis.z, zaxis.z, 0,
      -xaxis:dot(eye), -yaxis:dot(eye), -zaxis:dot(eye), 1)
end

function Mat4x4.axes(xaxis, yaxis, zaxis)
  return Mat4x4.new(
      xaxis.x, yaxis.x, zaxis.x, 0,
      xaxis.y, yaxis.y, zaxis.y, 0,
      xaxis.z, yaxis.z, zaxis.z, 0,
      0, 0, 0, 1)
end

function Mat4x4.ortho(left, right, bottom, top, near, far)
  local l, r, b, t, n, f = left, right, bottom, top, near, far
  return Mat4x4.new(
    2/(r-l),  0,        0,        0,
    0,        2/(t-b),  0,        0,
    0,        0,        -2/(f-n), 0,
    -(r+l)/(r-l), -(t+b)/(t-b), -(f+n)/(f-n), 1)
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

function Mat4x4:transpose()
  return Mat4x4.new(
    self.data[0], self.data[4], self.data[8], self.data[12],
    self.data[1], self.data[5], self.data[9], self.data[13],
    self.data[2], self.data[6], self.data[10], self.data[14],
    self.data[3], self.data[7], self.data[11], self.data[15])
end

function Mat4x4:inverse()
  local out = Mat4x4.new()

  local m00, m01, m02, m03 = self.data[0], self.data[4], self.data[8], self.data[12]
  local m10, m11, m12, m13 = self.data[1], self.data[5], self.data[9], self.data[13]
  local m20, m21, m22, m23 = self.data[2], self.data[6], self.data[10], self.data[14]
  local m30, m31, m32, m33 = self.data[3], self.data[7], self.data[11], self.data[15]

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

  out.data[0] = t00 * invDet
  out.data[1] = t10 * invDet
  out.data[2] = t20 * invDet
  out.data[3] = t30 * invDet

  out.data[4] = - (v5 * m01 - v4 * m02 + v3 * m03) * invDet
  out.data[5] =   (v5 * m00 - v2 * m02 + v1 * m03) * invDet
  out.data[6] = - (v4 * m00 - v2 * m01 + v0 * m03) * invDet
  out.data[7] =   (v3 * m00 - v1 * m01 + v0 * m02) * invDet

  v0 = m10 * m31 - m11 * m30
  v1 = m10 * m32 - m12 * m30
  v2 = m10 * m33 - m13 * m30
  v3 = m11 * m32 - m12 * m31
  v4 = m11 * m33 - m13 * m31
  v5 = m12 * m33 - m13 * m32

  out.data[8] =   (v5 * m01 - v4 * m02 + v3 * m03) * invDet
  out.data[9] = - (v5 * m00 - v2 * m02 + v1 * m03) * invDet
  out.data[10] =   (v4 * m00 - v2 * m01 + v0 * m03) * invDet
  out.data[11] = - (v3 * m00 - v1 * m01 + v0 * m02) * invDet

  v0 = m21 * m10 - m20 * m11
  v1 = m22 * m10 - m20 * m12
  v2 = m23 * m10 - m20 * m13
  v3 = m22 * m11 - m21 * m12
  v4 = m23 * m11 - m21 * m13
  v5 = m23 * m12 - m22 * m13

  out.data[12] = - (v5 * m01 - v4 * m02 + v3 * m03) * invDet
  out.data[13] =   (v5 * m00 - v2 * m02 + v1 * m03) * invDet
  out.data[14] = - (v4 * m00 - v2 * m01 + v0 * m03) * invDet
  out.data[15] =   (v3 * m00 - v1 * m01 + v0 * m02) * invDet
  
  return out
end

function Mat4x4:__tostring()
  local buf = {}
  for i=0,3 do 
    for j=0,3 do
      if j ~= 0 then 
        table.insert(buf, ', ')
      end
      table.insert(buf, self.data[i+j*4]) 
    end
    table.insert(buf, '\n')
  end
  return table.concat(buf)
end

local function mulmat4x4(self, other)
  local out = Mat4x4.new()
  local data = out.data

  m1 = other.data
  m2 = self.data

  data[0] = m1[0]*m2[0] + m1[1]*m2[4] + m1[2]*m2[8] + m1[3]*m2[12];
  data[1] = m1[0]*m2[1] + m1[1]*m2[5] + m1[2]*m2[9] + m1[3]*m2[13];
  data[2] = m1[0]*m2[2] + m1[1]*m2[6] + m1[2]*m2[10] + m1[3]*m2[14];
  data[3] = m1[0]*m2[3] + m1[1]*m2[7] + m1[2]*m2[11] + m1[3]*m2[15];
  
  data[4] = m1[4]*m2[0] + m1[5]*m2[4] + m1[6]*m2[8] + m1[7]*m2[12];
  data[5] = m1[4]*m2[1] + m1[5]*m2[5] + m1[6]*m2[9] + m1[7]*m2[13];
  data[6] = m1[4]*m2[2] + m1[5]*m2[6] + m1[6]*m2[10] + m1[7]*m2[14];
  data[7] = m1[4]*m2[3] + m1[5]*m2[7] + m1[6]*m2[11] + m1[7]*m2[15];
  
  data[8] = m1[8]*m2[0] + m1[9]*m2[4] + m1[10]*m2[8] + m1[11]*m2[12];
  data[9] = m1[8]*m2[1] + m1[9]*m2[5] + m1[10]*m2[9] + m1[11]*m2[13];
  data[10] = m1[8]*m2[2] + m1[9]*m2[6] + m1[10]*m2[10] + m1[11]*m2[14];
  data[11] = m1[8]*m2[3] + m1[9]*m2[7] + m1[10]*m2[11] + m1[11]*m2[15];
  
  data[12] = m1[12]*m2[0] + m1[13]*m2[4] + m1[14]*m2[8] + m1[15]*m2[12];
  data[13] = m1[12]*m2[1] + m1[13]*m2[5] + m1[14]*m2[9] + m1[15]*m2[13];
  data[14] = m1[12]*m2[2] + m1[13]*m2[6] + m1[14]*m2[10] + m1[15]*m2[14];
  data[15] = m1[12]*m2[3] + m1[13]*m2[7] + m1[14]*m2[11] + m1[15]*m2[15];

  return out
end

local function mulvec4(self, v)
  local m = self.data
  return vec.Vec4(
    m[0]*v.x + m[4]*v.y + m[8]*v.z + m[12]*v.w,
    m[1]*v.x + m[5]*v.y + m[9]*v.z + m[13]*v.w,
    m[2]*v.x + m[6]*v.y + m[10]*v.z + m[14]*v.w,
    m[3]*v.x + m[7]*v.y + m[11]*v.z + m[15]*v.w)
end

local function mulvec3(self, v)
    local m = self.data
    local invw = 1 / (m[3]*v.x + m[7]*v.y + m[11]*v.z + m[15]);
    
    return vec.Vec3(
      (m[0]*v.x + m[4]*v.y + m[8]*v.z + m[12])*invw,
      (m[1]*v.x + m[5]*v.y + m[9]*v.z + m[13])*invw,
      (m[2]*v.x + m[6]*v.y + m[10]*v.z + m[14])*invw)
end

function Mat4x4:__mul(other)
  if other.new == Mat4x4.new then
    return mulmat4x4(self, other)
  elseif other.new == vec.Vec4 then
    return mulvec4(self, other)
  elseif other.new == vec.Vec3 then
    return mulvec3(self, other)
  end
end

ffi.metatype(Mat4x4Type, Mat4x4)
return Mat4x4
