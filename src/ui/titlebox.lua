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
local asset = require('asset')
local Composite = require('ui.composite')

local TitleBox = {}; TitleBox.__index = TitleBox

-- Renders a title and a border around another component
function TitleBox.new(args)
  table.insert(args, {
    -- Render background image
    kind = 'Image', 
    texture = 'texture/White.png', 
    tint = vec.Color(1, 1, 1, .03),
    size = vec.Vec2(1, 1), 
    position = vec.Vec2(.5, .5), 
    pivot = vec.Vec2(.5, .5),
    padding = {top = .1, bottom = .02, left = .02, right = .02},
  })
  
  table.insert(args, {
    -- Render title  
    kind = 'Label',
    text = args.text,
    font = asset.open('font/Norwester.ttf', 64, 'fixed'),
    pivot = vec.Vec2(0, 1),
    position = vec.Vec2(.005, 0),
    height = .07,
    sizing = 'absolute',
  })

  local self = Composite(args)
  return setmetatable(self, TitleBox)
end

return TitleBox.new
