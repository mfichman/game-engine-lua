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

local vec = require('vec')
local geom = require('geom')
local ffi = require('ffi')

ffi.cdef[[
typedef struct graphics_LineVertex {
  vec_Vec3 position;
} graphics_LineVertex;
]]

local LineVertex = ffi.typeof('graphics_LineVertex')

local Line = {}; Line.__index = Line

function Line.new(args)
  local self = {
    point = geom.Buffer('graphics_LineVertex'),
    color = args.color or vec.Color(1, 1, 1, 1),
  }
  return setmetatable(self, Line)
end

function Line:visible()
  return self.point.count > 0
end

function Line:push(point)
  self.point:push(LineVertex(point))
end

return Line.new
