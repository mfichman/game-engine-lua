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

local math = require('math')
local vec = require('vec')

local PointLight = {}; PointLight.__index = PointLight

function PointLight.new(args)
  local args = args or {}
  local self = {
    ambientColor = args.ambientColor or vec.Vec4(0, 0, 0, 1),
    diffuseColor = args.diffuseColor or vec.Vec4(1, 1, 1, 1),
    backDiffuseColor = args.backDiffuseColor or vec.Vec4(0, 0, 0, 1),
    specularColor = args.specularColor or vec.Vec4(1, 1, 1, 1),
    constantAttenuation = args.constantAttenuation or 1,
    linearAttenuation = args.linearAttenuation or 1,
    quadraticAttenuation = args.quadraticAttenuation or 0,
  }
  return setmetatable(self, PointLight)
end

function PointLight:radiusOfEffect()
  local a = self.quadraticAttenuation
  local b = self.linearAttenuation
  local c = self.constantAttenuation
  local minIntensity = 0.01
  if a ~= 0 then
    -- Quadratic equation to find distance at which intensity is below the
    -- threshold
    local d1 = -b + math.sqrt(b*b - 4*a*(c - 1/minIntensity))/2/a
    local d2 = -b - math.sqrt(b*b - 4*a*(c - 1/minIntensity))/2/a
    return math.max(d1, d2)
  else
    -- If a == 0, then we use the slope instead.
    return (1-minIntensity*c)/(minIntensity*b)
  end
end

return PointLight.new
