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

-- Create an item icon; displays the item's image, along with the quantity as
-- a text label.
function ItemIcon.new(args)
  local font = asset.open('font/Norwester.ttf', 64, 'fixed')

  local self = {
      position = args.position,
      pivot = args.pivot,
      parent = args.parent,
      size = args.size,
      click = args.click,

      {'Image', 
        texture = 'texture/White.png', 
        tint = vec.Color(1, 1, 1, .3),
        size = vec.Vec2(.9, .9), 
        position = vec.Vec2(.5, .5), 
        pivot = vec.Vec2(.5, .5)
      },
  }

  if args.item then
    table.insert(self, {'Image', 
      texture = args.item.kind.texture, 
      size = vec.Vec2(.9, .9), 
      position = vec.Vec2(.5, .5), 
      pivot = vec.Vec2(.5, .5)
    })
    table.insert(self, {'Label', 
      position = vec.Vec2(.08, .08),
      text = tostring(args.item.quantity),
      font = font, 
      height = .3
    })
  end

  local self = Composite(self)
  return setmetatable(self, ItemIcon)
end

return ItemIcon.new
