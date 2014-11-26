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

local Color = {}; Color.__index = Color
local ColorType = ffi.typeof('vec_Color')

function Color.new(...)
  return ColorType(...)
end

function Color:__add(other)
  return Color.new(self.r+other.x, self.g+other.y, self.b+other.z, self.a+other.w)
end

function Color:__sub(other)
  return Color.new(self.r-other.x, self.g-other.y, self.b-other.z, self.a-other.w)
end

function Color:__mul(other)
  if type(self) == 'number' then
    other, self = self, other
  end
  return Color.new(self.r*other, self.g*other, self.b*other, self.a*other)
end

function Color:__div(other)
  if type(self) == 'number' then
    other, self = self, other
  end
  return Color.new(self.r/other, self.g/other, self.b/other, self.a/other)
end

function Color:__tostring()
  return string.format('%f, %f, %f, %f', self.r, self.g, self.b, self.a)
end

function Color:__eq(other)
  return self.r == other.x and self.g == other.y and self.b == other.z and self.a == other.w
end

function Color:data()
  return ffi.cast('vec_Scalar*', self)
end

ffi.metatype(ColorType, Color)
return Color.new
