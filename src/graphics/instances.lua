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
local struct = require('graphics.struct')

local Buffer = require('graphics.buffer')
local Instance = require('graphics.instance')

local Instances = {}; Instances.__index = Instances

-- Creates a new set of mesh instances. Each instance is a mesh with its own
-- world transform.  All instances in an instance set use the same texture,
-- material, mesh, and shader, so that they can all be drawn in the same batch.
-- This increases efficiency by reducing the number of draw calls that the
-- renderer needs to issue.
function Instances.new(args)
  assert(args.model, 'no model set for instances')
  local self = {
    model = args.model,
    clearMode = args.clearMode or 'manual',
    instance = geom.Buffer('graphics_Instance'),
  }
  return setmetatable(self, Instances)
end

function Instances:visible()
  return self.instance.count > 0
end

return Instances.new
