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

local game = require('game')
local graphics = require('graphics')
local vec = require('vec')

local Component = require('ui.Component')
local Label = {}; Label.__index = Label

-- Cache text objects for rendering
local cache = {}

-- Look up a cached text object. This avoids creating a bunch of text objects
-- that are duplicates of existing text objects.
local function cachedText(font, text, color, size)
  local fontcache = cache[font] 
  if not fontcache then 
    fontcache = {}
    cache[font] = fontcache
  end

  local textcache = fontcache[text]
  if not textcache then
    textcache = {}
    fontcache[text] = textcache
  end

  local sizecache = textcache[size]
  if not sizecache then
    sizecache = graphics.Text{font = font, text = text, size = size, color = color}
    textcache[size] = sizecache
  end
  return sizecache
end

-- Render a text object relative to the parent
function Label.new(args)
  local parent = args.parent.size or vec.Vec2(1, 1)
  local height = args.height or 1
  if not args.sizing or args.sizing == 'relative' then
    height = parent.height * height
  elseif args.sizing == 'absolute' then
    -- Do not scale by parent size
  else
    error('invalid sizing mode')
  end

  local color = args.color or vec.Vec4(1, 1, 1, 1)
  local text = cachedText(args.font, args.text, color, height)
  args.size = vec.Vec2(args.height*text:width(), args.height)

  local self = Component(args)
  self.node = text

  return setmetatable(self, Label)
end

return Label.new
