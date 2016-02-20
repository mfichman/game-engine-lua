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

-- Convert a hue, saturation, lightness tuple (where each component is in the
-- range [0,1) to red-green-blue.
function Color.hsl(hue, saturation, lightness)
    if hue < 0 or hue > 1 then
        return Color.new(0, 0, 0, 1)
    end
    if saturation < 0 or saturation > 1 then
        return Color.new(0, 0, 0, 1)
    end
    if lightness < 0 or lightness > 1 then
        return 0, 0, 0, alpha
    end
    local chroma = (1 - math.abs(2 * lightness - 1)) * saturation
    local h = hue*360/60 --360/60
    local x =(1 - math.abs(h % 2 - 1)) * chroma
    local r, g, b = 0, 0, 0
    if h < 1 then
        r,g,b=chroma,x,0
    elseif h < 2 then
        r,b,g=x,chroma,0
    elseif h < 3 then
        r,g,b=0,chroma,x
    elseif h < 4 then
        r,g,b=0,x,chroma
    elseif h < 5 then
        r,g,b=x,0,chroma
    else
        r,g,b=chroma,0,x
    end
    local m = lightness - chroma/2
    return Color.new(r+m,g+m,b+m,1)
end

setmetatable(Color, {
  __call = function(t, ...) return Color.new(...) end
})

ffi.metatype(ColorType, Color)
return Color
