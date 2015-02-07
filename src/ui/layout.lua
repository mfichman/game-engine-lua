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
local game = require('game')

--ui.Panel{x = 0, y = 0, width = 100, height = 100}
-- Square centered; uses whole screen

--ui.Text{origin = vec.Vec2(-1, 1), x = 0, y = 0, text='foo'}

-- 0, 0: top left
-- 1, 1: top right

--[[

  +------+
 ++  ++ ++ 
 ++  ++ ++
  |
  |
    

]]

-- parentcord + parentspan*coord - (origin*width)

-- parentcoord = 2 (absolute)
-- parentspan = 8 (absolute)
-- origin = 1 (right side snap)
-- coord = 0
-- width = 2
-- 2+(8*0) - (1*width)

-- parentcoord = 2 (absolute)
-- parentspan = 8 (absolute)
-- origin = .5 (center)
-- coord = .5 (center)
-- width = 2
-- 2 + 8*.5 - (.5*2) = 2+4-1 = 6-1 = 5

-- parentcoord = 2 (absolute)
-- parentspan = 8 (absolute)
-- origin = 1 (right side snap)
-- coord = 1 (end)
-- width = 2
-- 2 + 8*1 - (1*2) = 10-2 = 8


-- Computes the layout of a widget relative to its parent.
local function layout(parent, basis, position, size)
  --local aspectRatio = game.uicamera.viewport.width/game.uicamera.viewport.height
  local position = position or vec.Vec2(0, 0)
  local parentpos = parent and parent.position or vec.Vec2(0, 0)
  local parentsize = parent and parent.size or vec.Vec2(1, 1)
  local basis = basis or vec.Vec2(0, 0)
  return parentpos + parentsize*position - basis*size
end


return {
  layout=layout,
}


