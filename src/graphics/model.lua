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

local Model = {}; Model.__index = Model

-- Creates a new model. A model is a mesh that has an attached material that 
-- defines the color and texture of the mesh, as well as a GPU program that 
-- provides further optional customization of the mesh's appearance.
function Model.new(args)
  local args = args or {}
  local self = {
    material = args.material,
    mesh = args.mesh,
    program = args.program,
  }
  return setmetatable(self, Model)
end

-- Creates a copy of the model and returns it. The mesh object is not
-- deep-copied, because doing so is expensive.
function Model:clone()
  return Model.new{
    material = self.material:clone(),
    mesh = self.mesh,
    program = self.program,
  }
end

return Model.new
