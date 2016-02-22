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
local gl = require('gl')
local geom = require('geom')

local RibbonVertex = require('graphics.ribbonvertex')

local Ribbon = {}; Ribbon.__index = Ribbon

function Ribbon.new(args)
  assert(args.texture, 'no texture set for ribbon')
  local self = {
    texture = args.texture,
    tail = 0,
    width = args.width or 1,
    minWidth = args.minWidth or 1,
    quota = args.quota or 10,
    vertex = geom.Buffer('graphics_RibbonVertex'),
    prev0 = RibbonVertex(),
    prev1 = RibbonVertex(),
  }
  return setmetatable(self, Ribbon)
end

-- Tests if ribbon is visible
function Ribbon:visible()
  return self.texture and self.vertex.count > 0
end

-- Pushes a new point into the ribbon
function Ribbon:push(point)
  local index = 3 * ((self.tail % self.quota) + 1)
  self.vertex:reserve(3 * (self.quota + 1)) -- +1 is for the cap

  if self.tail == 0 then
    self.prev1.position = point
    self.prev1.index = self.tail-1
    self.prev0.position = point
    self.prev0.index = self.tail
  else
    local dir = point-self.prev0.position
    if self.tail == 1 then
      self.prev1.direction = dir
      self.prev0.direction = dir
    end

    local rv = RibbonVertex{
      position = point,
      direction = dir,
      index = self.tail,
    }
    self.vertex[index+0] = self.prev1
    self.vertex[index+1] = self.prev0
    self.vertex[index+2] = rv

    local cap = RibbonVertex{
      position = point,
      direction = dir,
      index = self.tail+1,
    }
    self.vertex[0] = self.prev0
    self.vertex[1] = rv
    self.vertex[2] = cap
    -- First 3 slots are reserved for the endcap
    
    self.prev1 = self.prev0
    self.prev0 = rv
    -- Rotate points: rv => prev0 => prev1
  end
  self.tail = self.tail + 1
end

return Ribbon.new
