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
