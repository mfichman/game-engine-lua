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
