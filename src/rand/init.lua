-- Copyright (c) 2014 Matt Fichman
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

local math = require('math')
local vec = require('vec')

-- Returns a random number in the range [min, max)
local function float(min, max)
  return min+(max-min)*math.random()
end

local function int(min, max)
  return math.random(min, max)
end

local function sphere(radius)
  local r = float(0, radius)
  local phi = float(0, 2 * math.pi)
  local theta = float(0, math.pi)

  return vec.Vec3{
    x = r * math.sin(theta) * math.cos(phi),
    y = r * math.sin(theta) * math.sin(phi),
    z = r * math.cos(theta),
  }
end

return {
  float = float,
  int = int,
  sphere = sphere,
}
