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
local layout = require('ui.layout')
local vec = require('vec')
local game = require('game')

local Image = {}; Image.__index = Image

-- Renders an image in the user interface.
function Image.new(args) 
  local basis = args.basis or vec.Vec2()
  local basisOffset = vec.Vec2(basis.x, -basis.y)+vec.Vec2(-.5, .5)
  local size = vec.Vec2(args.size.x, -args.size.y)
  local position = layout.layout(args.parent, basisOffset, args.position, size)
  local self = {
    position = layout.layout(args.parent, basis, args.position, args.size),
    quad = graphics.Quad{
      mode = 'normal',
      width = size.x, 
      height = size.y,
      texture = args.texture,
      tint = args.tint,
    },
    size = args.size,
    z = args.z or -1,
  }
  local origin = vec.Vec3(position.x, position.y, self.z)
  local transform = vec.Transform(origin)
  game.graphics:submit(self.quad, game.uicamera, transform)
  return setmetatable(self, Image)
end

return Image.new
