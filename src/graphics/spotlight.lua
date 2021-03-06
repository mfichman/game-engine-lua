-- Copyright (c) 2016 Matt Fichman
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

local math = require('math')
local vec = require('vec')

local SpotLight = {}; SpotLight.__index = SpotLight

function SpotLight.new(args)
  local args = args or {}
  local self = {
    diffuseColor = args.diffuseColor or vec.Vec4(1, 1, 1, 1),
    specularColor = args.specularColor or vec.Vec4(1, 1, 1, 1),
    constantAttenuation = args.constantAttenuation or 1,
    linearAttenuation = args.linearAttenuation or 1,
    quadraticAttenuation = args.quadraticAttenuation or 0,
    cutoff = args.cutoff or 60,
    power = args.power or 20,
    direction = args.direction or vec.Vec3(0, -1, 0),
  }
  return setmetatable(self, SpotLight)
end

function SpotLight:radiusOfEffect()
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

return SpotLight.new
