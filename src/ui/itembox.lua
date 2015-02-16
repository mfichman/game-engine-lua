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
local Composite = require('ui.composite')

local ItemBox = {}; ItemBox.__index = ItemBox

function ItemBox.new(args)
  args.size = vec.Vec2(args.box.rows*.1, args.box.cols*.1),

  table.insert(args, {
    kind = 'TitleBox',
    text = args.text,
  }) 

  -- Render a grid cell for each item in the gride
  table.insert(args, {
    kind = 'Grid',
    rows = args.box.rows,
    cols = args.box.cols,
    item = function(i)
      return {
        kind = 'ItemIcon',
        item = args.box.item[i+1],
        click = function()
          args.click(i+1)
        end
      }
    end
  })
  local self = Composite(args)
  return setmetatable(self, ItemBox)
end

return ItemBox.new
