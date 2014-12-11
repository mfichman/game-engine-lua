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
local string = require('string')
local path = require('path')
local shader = require('asset.shader')

local function open(name)
  local name = name:match('^(.+)%.prog$')
  local vert, frag, geom
  if path.find(name..'.vert') then vert = shader.open(name..'.vert') end
  if path.find(name..'.frag') then frag = shader.open(name..'.frag') end
  if path.find(name..'.geom') then geom = shader.open(name..'.geom') end
  return graphics.Program(vert, frag, geom)
end

return {
  open = open
}

