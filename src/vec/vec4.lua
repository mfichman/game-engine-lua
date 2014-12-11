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

local Vec4 = {}; Vec4.__index = Vec4
local Vec4Type = ffi.typeof('vec_Vec4')

function Vec4.new(...)
  return Vec4Type(...)
end

function Vec4:dot(other)
  return self.x*other.x + self.y*other.y + self.z*other.z + self.w*other.w
end

function Vec4:__add(other)
  return Vec4.new(self.x+other.x, self.y+other.y, self.z+other.z, self.w+other.w)
end

function Vec4:__sub(other)
  return Vec4.new(self.x-other.x, self.y-other.y, self.z-other.z, self.w-other.w)
end

function Vec4:__mul(other)
  if type(self) == 'number' then
    other, self = self, other
  end
  return Vec4.new(self.x*other, self.y*other, self.z*other, self.w*other)
end

function Vec4:__div(other)
  return Vec4.new(self.x/other, self.y/other, self.z/other, self.w/other)
end

function Vec4:len(other)
  return math.sqrt(self:len2())
end

function Vec4:len2(other)
  return self:dot(self)
end

function Vec4:unit()
  local norm = self:len()
  return Vec4.new(self.x/norm, self.y/norm, self.z/norm, self.w/norm)
end

function Vec4:__tostring()
  return string.format('%f, %f, %f, %f', self.x, self.y, self.z, self.w)
end

function Vec4:__eq(other)
  return self.x == other.x and self.y == other.y and self.z == other.z and self.w == other.w
end

function Vec4:data()
  return ffi.cast('vec_Scalar*', self)
end

ffi.metatype(Vec4Type, Vec4)
return Vec4.new

