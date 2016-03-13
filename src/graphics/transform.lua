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

local Transform = {}; Transform.__index = Transform

function Transform.new(args)
  local self = {
    component = {},
    origin = args and args.origin or vec.Vec3(),
    rotation = args and args.rotation or vec.Quat.identity(),
    shadowMode = args and args.shadowMode or 'shadowed',
    renderMode = args and args.renderMode or 'visible',
  }
  return setmetatable(self, Transform)
end

function Transform:componentIs(comp)
  assert(comp)
  table.insert(self.component, comp)
  return comp
end

function Transform:componentDel(comp)
  assert(comp)
  for i, v in ipairs(self.component) do
    if v == comp then
      table.remove(self.component, i)
      return
    end
  end
end

function Transform:clone()
  local clone = Transform.new(self)
  for i, component in ipairs(self.component) do
    clone:componentIs(component:clone())
  end
  return clone
end

return Transform.new
