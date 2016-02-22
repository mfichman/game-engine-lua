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
local Composite = require('ui.composite')

local Grid = {}; Grid.__index = Grid

-- Creates a grid, where each element is an item returned by the 'item' function
function Grid.new(args)
  for i = 0,args.rows*args.cols-1 do
    local row = math.floor(i/args.cols)
    local col = i%args.cols
    local x = col/args.rows
    local y = row/args.cols

    local item = args.item(i)
    item.position = vec.Vec2(x, y)
    item.size = vec.Vec2(1/args.cols, 1/args.rows)
    table.insert(args, item)
  end
  local self = Composite(args)
  return setmetatable(self, Grid)
end

return Grid.new
