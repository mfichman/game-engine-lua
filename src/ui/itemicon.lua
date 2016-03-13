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

local asset = require('asset')
local vec = require('vec')

local Composite = require('ui.composite')
local ItemIcon = {}; ItemIcon.__index = ItemIcon

-- Create an item icon; displays the item's image, along with the quantity as
-- a text label.
function ItemIcon.new(args)
  local font = asset.open('font/Norwester.ttf', 32, 'fixed')

  local self = {
    position = args.position,
    pivot = args.pivot,
    parent = args.parent,
    size = args.size,
    click = args.click,
  }

  table.insert(self, {
    kind = 'Image', 
    texture = 'texture/White.png', 
    tint = vec.Color(1, 1, 1, .2),
    size = vec.Vec2(.9, .9), 
    position = vec.Vec2(.5, .5), 
    pivot = vec.Vec2(.5, .5)
  })

  if args.item then
    table.insert(self, {
      kind = 'Image', 
      texture = args.item.kind.texture, 
      size = vec.Vec2(.9, .9), 
      position = vec.Vec2(.5, .5), 
      pivot = vec.Vec2(.5, .5)
    })
    table.insert(self, {
      kind = 'Label', 
      position = vec.Vec2(.08, .08),
      text = tostring(args.item.quantity),
      font = font, 
      height = .3
    })
  end

  local self = Composite(self)
  return setmetatable(self, ItemIcon)
end

return ItemIcon.new
