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
  struct vec_Vec2 {
    union {
      struct {
        union { vec_Scalar x; vec_Scalar u; };
        union { vec_Scalar y; vec_Scalar v; };
      };
      vec_Scalar data[2];
    };
  };
]]

local Vec2 = {}; Vec2.__index = Vec2

Vec2.new = ffi.typeof('struct vec_Vec2')

function Vec2:dot(other)
  return self.x*other.x + self.y*other.y
end

function Vec2:__add(other)
  return Vec2.new(self.x+other.x, self.y+other.y)
end

function Vec2:__sub(other)
  return Vec2.new(self.x-other.x, self.y-other.y)
end

function Vec2:__mul(other)
  if type(self) == 'number' then
    other, self = self, other
  end
  return Vec2.new(self.x*other, self.y*other)
end

function Vec2:len()
  return math.sqrt(self:len2())
end

function Vec2:len2()
  return self:dot(self)
end

function Vec2:unit()
  local norm = self:len()
  return Vec2.new(self.x/norm, self.y/norm)
end

return ffi.metatype(Vec2.new, Vec2)

