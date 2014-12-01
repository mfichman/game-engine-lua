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

local vec = require('vec')
local gl = require('gl')

local Buffer = require('graphics.buffer')
local Particle = require('graphics.particle')

local Particles = {}; Particles.__index = Particles

function Particles.new(args)
  assert(args.texture, 'no texture set for particles')
  local self = {
    texture = args.texture,
    clearMode = args.clearMode or 'manual',
    blendMode = args.blendMode or 'additive',
    tint = args.tint or vec.Vec4(1, 1, 1, 1),
    particle = Buffer(nil, nil, 'graphics_Particle'),
  }
  return setmetatable(self, Particles)
end

function Particles:visible()
  return self.texture and self.particle.count > 0
end

return Particles.new
