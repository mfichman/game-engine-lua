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

local graphics = require('graphics')
local sfml = require('sfml')
local ffi = require('ffi')
local path = require('path')

local function open(name)
  local loc = path.find(name)
  if not loc then error('file not found: '..name) end

  local image = sfml.Image_createFromFile(loc)
  if not image then error('bad image file: '..loc) end

  local size = image:getSize()
  local texture = graphics.Texture(size.x, size.y, image:getPixelsPtr())
  image:destroy()
  return texture 
end

return {
  open = open
}
