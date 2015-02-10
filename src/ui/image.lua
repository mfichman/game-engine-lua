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
local asset = require('asset')

local Component = require('ui.Component')
local Image = {}; Image.__index = Image

-- Renders an image in the user interface.
function Image.new(args) 
  -- Calculate the pivot to render the image at the right location
  args.pivot = args.pivot or vec.Vec2()
  args.pivot = vec.Vec2(args.pivot.x, -args.pivot.y)+vec.Vec2(-.5, .5)
  args.size = args.size or vec.Vec2(1, 1)
  args.size = vec.Vec2(args.size.x, -args.size.y)

  local self = Component(args)

  self.node = graphics.Quad{
    mode = 'normal',
    width = self.size.x, 
    height = self.size.y,
    texture = asset.open(args.texture),
    tint = args.tint,
  }
  return setmetatable(self, Image)
end

return Image.new
