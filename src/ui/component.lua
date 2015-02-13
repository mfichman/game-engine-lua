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

local graphics = require('graphics')
local vec = require('vec')
local game = require('game')

local Component = {}; Component.__index = Component

-- Renders a UI component in the user interface
function Component.new(args)
  local parent = args.parent or {position = vec.Vec2(), size = vec.Vec2(1, 1)}
  local pivot = args.pivot or vec.Vec2()
  local size = parent.size * (args.size or vec.Vec2(1, 1))
  local position = args.position or vec.Vec2()
  local origin = parent.position+parent.size*position-pivot*size
  local transform = vec.Transform(vec.Vec3(origin.x, origin.y, -1))
  local component = {}

  local self = {
    transform = transform,
    parent = parent,
    pivot = pivot,
    size = size,
    position = origin,
    click = args.click,
  } 
  return self
end

return Component.new
