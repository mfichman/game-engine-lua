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
  struct vec_Quat {
    union {
      struct {
        union { vec_Scalar w; };
        union { vec_Scalar x; };
        union { vec_Scalar y; };
        union { vec_Scalar z; };
      };
      vec_Scalar data[4];
    };
  };
]]

local Quat = {}; Quat.__index = Quat
local QuatType = ffi.typeof('struct vec_Quat')

function Quat.new(...)
  return QuatType(...)
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

ffi.metatype(QuatType, Quat)
return Quat.new

