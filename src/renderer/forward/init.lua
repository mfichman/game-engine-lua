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
