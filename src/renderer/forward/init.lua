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

local apply = require('renderer.apply')

local Forward = {}; Forward.__index = Forward
local Shadow = require('renderer.shadow')
local hemilight = require('renderer.forward.hemilight')
--[[
local pointlight = require('renderer.forward.pointlight')
local spotlight = require('renderer.forward.spotlight')
]]

function Forward.new(context)
  local self = {
    context = context,
    shadow = Shadow(context)
  }
  return setmetatable(self, Forward)
end

function Forward:render()
  -- Pass 0: Render shadow maps
  self.shadow:render()

  -- Pass 1: Render lights
  apply.apply(hemilight.render, self.context, graphics.HemiLight)

  -- Pass 2: Transparent objects
  --self:apply(transparent.render, graphics.Model) FIXME
  apply.apply(particles.render, self.context, graphics.Particles)
  apply.apply(billboards.render, self.context, graphics.Billboards)
  apply.apply(ribbon.render, self.context, graphics.Ribbon)
  --self:apply(quad.render, graphics.Quad)
  --self:apply(text.render, graphics.Text)
  --self:apply(ui.render, graphics.Ui) FIXME
end

return Forward.new
