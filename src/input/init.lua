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

local sfml = require('sfml')
local vec = require('vec')

return {
  Binding = require('input.binding'),
  Map = require('input.map'),
  mouse = {
    position = function() 
      local game = require('game')
      local pos = sfml.Mouse_getPosition(game.window)
      return vec.Vec2(pos.x, pos.y)
    end,
  }
}
