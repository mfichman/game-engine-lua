-- ========================================================================== --
--                                                                            --
-- Copyright (c) 2015 Matt Fichman <matt.fichman@gmail.com>                   --
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

local Quad = {}; Quad.__index = Quad

-- Creates a new quad to render to the screen. A quad has a defined width and
-- height, and quad is centered on the origin so that its vertices are:
--   - -width/2, -height/2
--   - -width/2,  height/2
--   -  width/2,  height/2
--   -  width/2, -height/2
-- The quad's `mode` option can be either `normal`, to render the quad facing
-- in the direction of the parent transform node, or `particle` to render the
-- quad so that it always faces the camera, no matter what its orientation is.
function Quad.new(args)
  local self = {
    mode = args.mode or 'normal', 
    width = args.width or 1,
    height = args.height or 1,
    tint = args.tint or vec.Vec4(1, 1, 1, 1),
    texture = args.texture,
  }
  return setmetatable(self, Quad)
end

-- Returns a deep copy of the quad object.
function Quad:clone()
  return Quad.new{
    mode = self.model,
    width = self.width,
    height = self.height,
    tint = self.tint,
    texture = self.texture,
  }
end

return Quad.new
