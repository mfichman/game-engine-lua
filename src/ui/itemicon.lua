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

local Image = require('ui.image')
local Label = require('ui.label')
local asset = require('asset')
local vec = require('vec')

local ItemIcon = {}; ItemIcon.__index = ItemIcon

function ItemIcon.new(args)
  local background = Image{
    parent = args.parent,
    position = args.position,
    texture = asset.open('texture/White.png'), 
    tint = vec.Color(1, 1, 1, .3),
    size = vec.Vec2(.09, .09),
    basis = vec.Vec2(.5, .5),
  }
  local text = Label{
    parent = background,
    position = vec.Vec2(.04, .04), 
    text = '64',
    font = asset.open('font/Norwester.ttf', 64, 'fixed'),
    height = .030,
  }
  local icon = Image{
    parent = background,
    texture = asset.open('icon/Gold.png'), 
    size = vec.Vec2(.09, .09),
  }
end

return ItemIcon.new
