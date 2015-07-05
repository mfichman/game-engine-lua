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
local gl = require('gl')
local geom = require('geom')

local Buffer = require('graphics.buffer')
local TextVertex = require('graphics.textvertex')

local Text = {}; Text.__index = Text

local function updateTextBuffer(self)
  -- Update the text buffer to prepare it for rendering, using the font glyph
  -- metrics.  For each character, insert a vertex into the attribute buffer.
  local vertex = self.vertex
  vertex:clear()

  local cursorX = 0
  local cursorY = 0
  local prev = 0

  for i=1,self.text:len() do
    local ch = self.text:byte(i)
    if prev ~= 0 then
      local kerning = self.font:kerning(prev, ch)
      cursorX = cursorX + kerning.u
      cursorY = cursorY + kerning.v
    end

    local glyph = self.font.glyph[ch]
    local x = cursorX+glyph.x
    local y = cursorY+glyph.y

    -- Create a quad for the glyph
    local tg0 = TextVertex{
      position = vec.Vec2(x, y), 
      texcoord = vec.Vec2(glyph.texX, glyph.texY),
    }
    local tg1 = TextVertex{
      position = vec.Vec2(x, y+glyph.height),
      texcoord = vec.Vec2(glyph.texX, glyph.texY+glyph.texHeight),
    }
    local tg2 = TextVertex{
      position = vec.Vec2(x+glyph.width, y+glyph.height),
      texcoord = vec.Vec2(glyph.texX+glyph.texWidth, glyph.texY+glyph.texHeight),
    }
    local tg3 = TextVertex{
      position = vec.Vec2(x+glyph.width, y),
      texcoord = vec.Vec2(glyph.texX+glyph.texWidth, glyph.texY),
    }
    vertex:push(tg0) 
    vertex:push(tg1) 
    vertex:push(tg2) 

    vertex:push(tg0) 
    vertex:push(tg2) 
    vertex:push(tg3) 

    cursorX = cursorX+glyph.advanceX
    cursorY = cursorY+glyph.advanceY
    
    prev = ch
  end

  self.computedWidth = cursorX
end

-- Displays text on the screen. A text object is lightweight; it is cheap to use
-- many of them for rendering text on-screen.
function Text.new(args)
  local self = {
    text = args.text or '',
    font = args.font,
    status = 'dirty',
    computedWidth = 0,
    color = args.color or vec.Color(1, 1, 1, 1),
    size = args.size or 1,
    vertex = geom.Buffer('graphics_TextVertex'),
  }
  return setmetatable(self, Text)
end

-- Compute the width of the text
function Text:width()
  self:sync()
  return self.size*self.computedWidth
end

-- Synchronize the text with the graphics card
function Text:sync()
  if self.status == 'synced' then return end
  updateTextBuffer(self) 
  self.status = 'synced'
end

return Text.new
