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

local Shadow = {}; Shadow.__index = Shadow

local gl = require('gl')
local graphics = require('graphics')
local apply = require('renderer.apply')

local hemilight = require('renderer.shadow.hemilight')
--local spotlight = require('renderer.deferred.spotlight')
--local pointlight = require('renderer.deferred.pointlight')

function Shadow.new(context)
  assert(context, 'no context set')
  local self = setmetatable({}, Shadow)
  self.context = context
  return self
end

function Shadow:render()
  apply.apply(hemilight.render, self.context, graphics.HemiLight)
  --apply.apply(spotlight.render, self.context, graphics.SpotLight)
  --apply.apply(pointlight.render, self.context, graphics.PointLight)
end

return Shadow.new
