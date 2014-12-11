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
local Billboard = require('graphics.billboard')

local Billboards = {}; Billboards.__index = Billboards

-- Creates a new set of billboards. Each billboard is a quad that faces in the
-- direction of its normal vector. All billboards use the same texture, blend
-- modes, etc. so that they can all be drawn in the same batch.
function Billboards.new(args)
  assert(args.texture, 'no texture set for billboards')
  local self = {
    width = args.width or 1,
    height = args.height or 1,
    texture = args.texture,
    clearMode = args.clearMode or 'manual',
    blendMode = args.blendMore or 'additive',
    tint = args.tint or vec.Color(1, 1, 1, 1),
    billboard = Buffer(nil, nil, 'graphics_Billboard')
  }
  return setmetatable(self, Billboards)
end

function Billboards:visible()
  return self.texture and self.billboard.count > 0
end

return Billboards.new
