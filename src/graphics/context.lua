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
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, APEXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

local gl = require('gl')
local vec = require('vec')

local Context = {}; Context.__index = Context
local Transform = require('graphics.transform')

-- Creates a rendering context, which tracks/caches graphics pipeline state.
function Context.new(camera)
  assert(camera, 'camera is missing from context')
  local self = setmetatable({}, Context) 
  self.camera = camera
  self.world = vec.Mat4.identity()
  self.program = 0
  self.enabled = {}
  self.op = {} -- array of objects submitted for rendering in this frame
  self.gen = 0 -- generation; used to track rendering state changes
  return self
end

-- Submit a node to the rendering pipline using the given model transform. 
-- If a Transform object is submitted, then propagate its transform to all of
-- its children.
function Context:submit(node, transform)
  local transform = transform or vec.Transform.identity()
  if Transform == node.new then
    local tx = transform * vec.Transform.new(node.origin, node.rotation)
    for _, c in ipairs(node.component) do
      self:submit(c, tx)
    end
  else
    local op = { transform=transform, node=node }
    table.insert(self.op, op)
  end
end

-- Reset the rendering context to prepare for the next frame.
function Context:finish()
  self.op = {}
end

function Context:glUseProgram(program)
  if program ~= self.program then
    self.program = program
    gl.glUseProgram(program)
  end
end

-- Update the enabled OpenGL context flags
function Context:glEnable(...)
  for i, enum in ipairs({...}) do
    if not self.enabled[enum] then
      gl.glEnable(enum) 
    end
    self.enabled[enum] = self.gen
  end  
  for enum, gen in pairs(self.enabled) do
    if gen ~= self.gen then
      gl.glDisable(enum)
      self.enabled[enum] = nil
    end
  end
  self.gen = self.gen+1
end

function Context:glUniform3fv(index, count, data)
  if index then gl.glUniform3fv(index, count, data) end
end

function Context:glUniform1f(index, data)
  if index then gl.glUniform1f(index, data) end
end

function Context:glUniformMatrix3fv(index, count, transpose, data)
  if index then gl.glUniformMatrix3fv(index, count, transpose, data) end
end

function Context:glUniformMatrix4fv(index, count, transpose, data)
  if index then gl.glUniformMatrix4fv(index, count, transpose, data) end
end

return Context.new
