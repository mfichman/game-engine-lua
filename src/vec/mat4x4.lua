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
  typedef struct vec_Mat4x4 {
  vec_Scalar data[16];
  };
]]

local Mat4x4 = {}; Mat4x4.__index = Mat4x4;
local Mat4x4Type = ffi.typeof('struct vec_Mat4x4')

function Mat4x4.new(...)
  return Mat4x4Type(...)
end

function Mat4x4.frustum(left, right, bottom, top, near, far)
-- FIXME: Transpose this
  return Mat4x4.new(
    2*near/(right-left),  0,  (right+left)/(right-left),  0,
    0, 2*near/(top-b), (top+b)/(top-b), 0,
    0, 0, -(far+near)/(far-near), -2*far*near/(far-near),
    0, 0, -1, 0)
end

function Mat4x4.perspective(fov, aspect, near, far)
  local top = tan(fov*math.pi/360) * n;
  local bottom = -top;
  local right = aspect * top;
  local left = aspect * bottom;
  return Mat4x4.frustum(left, right, bottom, top, near, far)
end

function Mat4x4.look(eye, at, up)
  local zaxis = (eye - at):unit()
  local xaxis = up:cross(zaxis)
  local yaxis = zaxis:cross(xaxis)
  return Mat4x4.new(
      xaxis.x, yaxis.x, zaxis.x, 0,
      xaxis.y, yaxis.y, zaxis.y, 0,
      xaxis.z, yaxis.z, zaxis.z, 0,
      -xaxis:dot(eye), -yaxis:dot(eye), -zaxis:dot(eye), 1)

--[[

    xx xy xz 0   1 0 0 x
    yx yy yz 0   0 1 0 y
    zx zy zz 0   0 0 1 z
    0  0  0  1   0 0 0 1

    xx yx zx dot(x)
]]
    
    

end

function Mat4x4.axes(xaxis, yaxis, zaxis)
  return Mat4x4.new(
      xaxis.x, yaxis.x, zaxis.x, 0,
      xaxis.y, yaxis.y, zaxis.y, 0,
      xaxis.z, yaxis.z, zaxis.z, 0,
      0, 0, 0, 1)
end

function Mat4x4.ortho()
-- FIXME: Transpose!
  return Mat4x4.new(
    2/(right-left), 0, 0, -(right+left)/(right-left),
    0, 2/(top-bottom), 0, -(top+bottom)/(top-bottom),
    0, 0, -2/(far-near), -(far+near)/(far-near),
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
    vec.x, vec.y, vec.z, 1)
end

function Mat4x4.scale(x, y, z)
  return Mat4x4.new(
    x, 0, 0, 0,
    0, y, 0, 0,
    0, 0, z, 0,
    0, 0, 0, 1)
end

function Mat4x4.rotate(quat4)
  -- This routine is borrowed from Ogre 3D
  local fTx  = 2.0f*quat4.x;
  local fTy  = 2.0f*quat4.y;
  local fTz  = 2.0f*quat4.z;
  local fTwx = fTx*quat4.w;
  local fTwy = fTy*quat4.w;
  local fTwz = fTz*quat4.w;
  local fTxx = fTx*quat4.x;
  local fTxy = fTy*quat4.x;
  local fTxz = fTz*quat4.x;
  local fTyy = fTy*quat4.y;
  local fTyz = fTz*quat4.y;
  local fTzz = fTz*quat4.z;

-- FIXME: transpose?
  return Mat4x4.new(
    1-(fTyy+fTzz), fTxy+fTwz, fTxz-fTwy, 0,
    fTxy-fTwz, 1-(fTxx+fTzz), fTyz+fTwx, 0,
    fTxz+fTwy, fTyz-fTwx, 1-(fTxx+fTyy), 0,
    0, 0, 0, 0)
end

function Mat4x4:transpose()
  return Mat4x4Type(
    self.data[0], self.data[1], self.data[2], self.data[3],
    self.data[4], self.data[5], self.data[6], self.data[7],
    self.data[8], self.data[9], self.data[10], self.data[11],
    self.data[12], self.data[14], self.data[14], self.data[15])
end

function Mat4x4:__mul(other)
end

ffi.metatype(Mat4x4Type, Mat4x4)
return Mat4x4
