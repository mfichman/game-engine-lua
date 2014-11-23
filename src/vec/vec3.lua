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

local Vec3 = {}; Vec3.__index = Vec3
local Vec3Type = ffi.typeof('vec_Vec3')

function Vec3.new(...)
  return Vec3Type(...)
end

function Vec3:dot(other)
  return self.x*other.x + self.y*other.y + self.z*other.z
end

function Vec3:cross(other)
  return Vec3.new(
    self.y*other.z - self.z*other.y,
    self.z*other.x - self.x*other.z,
    self.x*other.y - self.y*other.x)
end

function Vec3:lerp(other, alpha)
  return Vec3.new(
    self.x*(1-alpha)+other.x*alpha,
    self.y*(1-alpha)+other.y*alpha,
    self.z*(1-alpha)+other.z*alpha)
end

function Vec3:__add(other)
  return Vec3.new(self.x+other.x, self.y+other.y, self.z+other.z)
end

function Vec3:__sub(other)
  return Vec3.new(self.x-other.x, self.y-other.y, self.z-other.z)
end

function Vec3:__mul(other)
  if type(self) == 'number' then
    other, self = self, other
  end
  return Vec3.new(self.x*other, self.y*other, self.z*other)
end

function Vec3:len(other)
  return math.sqrt(self:len2())
end

function Vec3:len2(other)
  return self:dot(self)
end

function Vec3:orthogonal()
  local ortho = self:cross(Vec3.new(1, 0, 0))
  if ortho:len2() < 1e-8 then
      ortho = self:cross(Vec3.new(0, 1, 0))
  end
  return ortho:unit()
end

function Vec3:unit()
  local norm = self:len()
  return Vec3.new(self.x/norm, self.y/norm, self.z/norm)
end

function Vec3:__eq(other)
  return self.x == other.x and self.y == other.y and self.z == other.z
end

function Vec3:__tostring()
  return string.format('%f, %f, %f', self.x, self.y, self.z)
end

function Vec3:__unm()
  return Vec3.new(-self.x, -self.y, -self.z)
end

function Vec3:data()
  return ffi.cast('vec_Scalar*', self)
end

ffi.metatype(Vec3Type, Vec3)
return Vec3.new

