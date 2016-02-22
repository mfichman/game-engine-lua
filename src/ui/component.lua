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

local Component = {}; Component.__index = Component

-- Renders a UI component in the user interface. Most other UI items derive from
-- Component by calling this constructor to generate the transform, size, 
-- position, parent and pivot attributes.
function Component.new(args)
  local parent = args.parent or {position = vec.Vec2(0, 0), size = vec.Vec2(1, 1)}
  local pivot = args.pivot or vec.Vec2(0, 0)
  local size = args.size or vec.Vec2(1, 1)
  if not args.sizing or args.sizing == 'relative' then
    size = parent.size * size
  elseif args.sizing == 'absolute' then
    -- Do not scale by parent size
  else
    error('invalid sizing mode')
  end
  local position = args.position or vec.Vec2()
  local origin = parent.position+parent.size*position-pivot*size
  local transform = vec.Transform(vec.Vec3(origin.x, origin.y, -1))
  local component = {}

  local self = {
    transform = transform,
    parent = parent,
    pivot = pivot,
    size = size,
    position = origin,
    click = args.click,
  } 
  return setmetatable(self, Component)
end

return Component.new
