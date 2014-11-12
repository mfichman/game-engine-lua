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
local RenderOp = require('graphics.renderop')

-- Creates a rendering context, which tracks/caches graphics pipeline state.
function Context.new(camera)
  assert(camera, 'camera is missing from context')
  local self = setmetatable({}, Context) 
  self.camera = camera
  self.world = vec.Mat4.identity()
  self.program = 0
  self.op = {} -- array of objects submitted for rendering in this frame

  self.state = {enabled={}}
  self.committed = {enabled={}}
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
    table.insert(self.op, RenderOp(node, transform))
  end
end

-- Reset the rendering context to prepare for the next frame.
function Context:finish()
  self.op = {}
end

-- Commit the OpenGL context changes
function Context:commit()
  if self.state.cullFace ~= self.committed.cullFace then
    gl.glCullFace(self.state.cullFace)
  end
  if self.state.depthFunc ~= self.committed.depthFunc then
    gl.glDepthFunc(self.state.depthFunc)
  end
  if self.state.blendFuncSrc ~= self.committed.blendFuncSrc or
     self.state.blendFuncDst ~= self.committed.blendFuncDst then
    gl.glBlendFunc(self.state.blendFuncSrc, self.state.blendFuncDst)
  end
  for enum, _ in pairs(self.state.enabled) do
    if not self.committed.enabled[enum] then
      gl.glEnable(enum)
    end
  end
  for enum, _ in pairs(self.committed.enabled) do
    if not self.state.enabled[enum] then
      gl.glDisable(enum)
    end
  end

  self.committed = self.state
  self.state = {enabled={}}
end

function Context:glUseProgram(program)
  self.state.program = program
end

-- Update the enabled OpenGL context flags
function Context:glEnable(...)
  for i, enum in ipairs({...}) do
    self.state.enabled[enum] = true
  end  
end

function Context:glCullFace(val)
  self.state.cullFace = val
end

function Context:glDepthFunc(val)
  self.state.depthFunc = val
end

function Context:glBlendFunc(src, dst)
  self.state.blendFuncSrc = src
  self.state.blendFuncDst = dst
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
