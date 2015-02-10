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

local asset = require('asset')
local vec = require('vec')

local Composite = require('ui.composite')
local ItemIcon = {}; ItemIcon.__index = ItemIcon

function ItemIcon.new(args)
  local font = asset.open('font/Norwester.ttf', 64, 'fixed')

  local self = Composite{
      position = args.position,
      pivot = args.pivot,
      parent = args.parent,
      size = args.size,
      click = args.click,
      {'Image', texture = 'texture/White.png', tint = vec.Color(1, 1, 1, .3), size = vec.Vec2(.9, .9), position = vec.Vec2(.5, .5), pivot = vec.Vec2(.5, .5)},
      {'Image', texture = 'icon/Gold.png', size = vec.Vec2(.9, .9), position = vec.Vec2(.5, .5), pivot = vec.Vec2(.5, .5)},
      {'Label', position = vec.Vec2(.08, .08), text = '64', font = font, height = .3},
  }
  return setmetatable(self, ItemIcon)
end

return ItemIcon.new
