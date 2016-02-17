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

local Vec3 = require('vec.vec3')
local Quat = require('vec.quat')

local Transform = {}; Transform.__index = Transform
local TransformType = ffi.typeof('vec_Transform')
  
function Transform.new(origin, rotation, scale)
  return TransformType{
    origin = origin or Vec3(), 
    rotation = rotation or Quat.identity(),
    scale = scale or 1,
  }
end

local function multransform(self, other)
  return Transform.new(
    self.rotation * other.origin + self.origin,
    self.rotation * other.rotation,
    self.scale * other.scale
  )
end

local function mulvec3(self, other)
  return (self.rotation * other) + self.origin
end

function Transform:__mul(other)
  if other.new == Transform.new then
    return multransform(self, other)
  elseif other.new == Vec3 then
    return mulvec3(self, other)
  else
    error('invalid multiplicand')
  end
end

ffi.metatype(TransformType, Transform)
return Transform.new
