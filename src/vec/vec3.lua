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

ffi.cdef[[
  struct vec_Vec3 {
    union {
      struct {
        union { vec_Scalar x; vec_Scalar r; vec_Scalar red; };
        union { vec_Scalar y; vec_Scalar g; vec_Scalar green; };
        union { vec_Scalar z; vec_Scalar b; vec_Scalar blue; };
      };
      vec_Scalar data[3];
    };
  };
]]

local Vec3 = {}; Vec3.__index = Vec3
local Vec3Type = ffi.typeof('struct vec_Vec3')

function Vec3.new(...)
  return Vec3Type(...)
end

function Vec3:dot(other)
  return self.x*other.x + self.y*other.y + self.z*other.z
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

function Vec3:unit()
  local norm = self:len()
  return Vec3.new(self.x/norm, self.y/norm, self.z/norm)
end

ffi.metatype(Vec3Type, Vec3)
return Vec3.new

