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

local Vec2 = {}; Vec2.__index = Vec2
local Vec2Type = ffi.typeof('vec_Vec2')

function Vec2.new(...)
  return Vec2Type(...)
end

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

function Vec2:__eq(other)
  return self.x == other.x and self.y == other.y
end

function Vec2:__tostring()
  return string.format('%f, %f', self.x, self.y)
end

function Vec2:data()
  return ffi.cast('vec_Scalar*', self)
end

ffi.metatype(Vec2Type, Vec2)
return Vec2.new

