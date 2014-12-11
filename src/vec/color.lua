-- ========================================================================== --
--                                                                            --
-- Copyright (c) 2014 Matt Fichman <matt.fichman@gmail.com>                   --
--                                                                            --
-- This file is part of Quadrant.  It is subject to the license terms in the  --
-- LICENSE.md file found in the top-level directory of this software package  --
-- and at http://github.com/mfichman/quadrant/blob/master/LICENSE.md.         --
-- No person may use, copy, modify, publish, distribute, sublicense and/or    --
-- sell any part of Quadrant except according to the terms contained in the   --
-- LICENSE.md file.                                                           --
--                                                                            --
-- ========================================================================== --

local ffi = require('ffi')
local math = require('math')

local Color = {}; Color.__index = Color
local ColorType = ffi.typeof('vec_Color')

function Color.new(...)
  return ColorType(...)
end

function Color:__add(other)
  return Color.new(self.r+other.r, self.g+other.g, self.b+other.b, self.a+other.a)
end

function Color:__sub(other)
  return Color.new(self.r-other.r, self.g-other.g, self.b-other.b, self.a-other.a)
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
  return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a
end

function Color:data()
  return ffi.cast('vec_Scalar*', self)
end

ffi.metatype(ColorType, Color)
return Color.new
