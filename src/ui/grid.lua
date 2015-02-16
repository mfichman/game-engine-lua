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

local Grid = {}; Grid.__index = Grid

-- Creates a grid, where each element is an item returned by the 'item' function
function Grid.new(args)
  for i = 0,args.rows*args.cols-1 do
    local row = math.floor(i/args.cols)
    local col = i%args.cols
    local x = row/args.rows
    local y = col/args.cols

    local item = args.item(i)
    item.position = vec.Vec2(x, y)
    item.size = vec.Vec2(1/args.rows, 1/args.cols)
    table.insert(args, item)
  end
  local self = Composite(args)
  return setmetatable(self, Grid)
end

return Grid.new
