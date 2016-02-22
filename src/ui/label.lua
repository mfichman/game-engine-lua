-- Copyright (c) 2016 Matt Fichman
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

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
