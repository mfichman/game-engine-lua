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

local Quad = {}; Quad.__index = Quad

-- Creates a new quad to render to the screen. A quad has a defined width and
-- height, and quad is centered on the origin so that its vertices are:
--   - -width/2, -height/2
--   - -width/2,  height/2
--   -  width/2,  height/2
--   -  width/2, -height/2
-- The quad's `mode` option can be either `normal`, to render the quad facing
-- in the direction of the parent transform node, or `particle` to render the
-- quad so that it always faces the camera, no matter what its orientation is.
function Quad.new(args)
  local self = {
    mode = args.mode or 'normal', 
    width = args.width or 1,
    height = args.height or 1,
    tint = args.tint or vec.Vec4(1, 1, 1, 1),
    texture = args.texture,
  }
  return setmetatable(self, Quad)
end

-- Returns a deep copy of the quad object.
function Quad:clone()
  return Quad.new{
    mode = self.model,
    width = self.width,
    height = self.height,
    tint = self.tint,
    texture = self.texture,
  }
end

return Quad.new
