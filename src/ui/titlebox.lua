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

local vec = require('vec')
local asset = require('asset')
local config = require('config')

local Composite = require('ui.composite')

local TitleBox = {}; TitleBox.__index = TitleBox

-- Renders a title and a border around another component
function TitleBox.new(args)
  local fontHeight = .05
  local fontPt = config.display.height * fontHeight

--[[
  table.insert(args, {
    -- Render background image
    kind = 'Image', 
    texture = 'texture/White.png', 
    tint = vec.Color(1, 1, 1, .03),
    size = vec.Vec2(1, 1), 
    position = vec.Vec2(.5, .5), 
    pivot = vec.Vec2(.5, .5),
    padding = {top = fontHeight+.02, bottom = .02, left = .02, right = .02},
  })
]]

  table.insert(args, {
    -- Render title  
    kind = 'Label',
    text = args.text,
    font = asset.open('font/Norwester.ttf', fontPt, 'fixed'),
    tint = vec.Color(0, 0, 0, 1),
    pivot = vec.Vec2(0, 1),
    position = vec.Vec2(.005, 0),
    height = fontHeight,
    sizing = 'absolute',
  })

  local self = Composite(args)
  return setmetatable(self, TitleBox)
end

return TitleBox.new
