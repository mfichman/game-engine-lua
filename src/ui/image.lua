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

local graphics = require('graphics')
local vec = require('vec')
local asset = require('asset')

local Component = require('ui.component')
local Image = {}; Image.__index = Image

-- Renders an image in the user interface.
function Image.new(args) 
  -- Calculate the pivot to render the image at the right location
  args.pivot = args.pivot or vec.Vec2()
  args.pivot = vec.Vec2(args.pivot.x, -args.pivot.y)+vec.Vec2(-.5, .5)
  args.size = args.size or vec.Vec2(1, 1)
  args.size = vec.Vec2(args.size.x, -args.size.y)

  local self = Component(args)
  local padding = args.padding or {top = 0, bottom = 0, left = 0, right = 0}

  self.node = graphics.Quad{
    mode = 'normal',
    width = self.size.x+padding.left+padding.right, 
    height = self.size.y-padding.top-padding.bottom,
    texture = asset.open(args.texture),
    tint = args.tint,
  }
  self.transform.origin.x = self.transform.origin.x+(padding.right-padding.left)/2
  self.transform.origin.y = self.transform.origin.y+(padding.bottom-padding.top)/2

  return setmetatable(self, Image)
end

return Image.new
