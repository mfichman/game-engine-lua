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

local gl = require('gl')
local vec = require('vec')

local Context = {}; Context.__index = Context
local Transform = require('graphics.transform')
local RenderOp = require('graphics.renderop')
local Camera = require('graphics.camera')

-- Creates a rendering context, which tracks/caches graphics pipeline state.
function Context.new(width, height)
  assert(width, 'width is nil')
  assert(height, 'height is nil')
  local self = setmetatable({}, Context) 
  self.camera = Camera()
  self.camera.viewport = vec.Vec2(width, height)
  self.worldTransform = vec.Mat4.identity()
  self.program = 0
  self.op = {} -- array of objects submitted for rendering in this frame

  self.state = {enabled={}}
  self.committed = {enabled={}}
  return self
end

-- Submit a node to the rendering pipline using the given model transform. 
-- If a Transform object is submitted, then propagate its transform to all of
-- its children.
function Context:submit(node, worldTransform)
  local worldTransform = worldTransform or vec.Transform()
  if Transform == node.new then
    local tx = worldTransform * vec.Transform(node.origin, node.rotation)
    for _, c in ipairs(node.component) do
      self:submit(c, tx)
    end
  else
    local tx = worldTransform
    table.insert(self.op, RenderOp(node, vec.Mat4.transform(tx.rotation, tx.origin)))
  end
end

-- Reset the rendering context to prepare for the next frame.
function Context:finish()
  self.op = {}
end

-- Commit the OpenGL context changes
function Context:commit()
  if self.state.program ~= self.committed.program then
    gl.glUseProgram(self.state.program or 0)
  end
  if self.state.cullFace ~= self.committed.cullFace then
    gl.glCullFace(self.state.cullFace or gl.GL_BACK)
  end
  if self.state.depthFunc ~= self.committed.depthFunc then
    gl.glDepthFunc(self.state.depthFunc or gl.GL_LESS)
  end
  if self.state.depthMask ~= self.committed.depthMask then
    gl.glDepthMask(self.state.depthMask or gl.GL_TRUE)
  end

  if self.state.blendFuncSrc ~= self.committed.blendFuncSrc or
     self.state.blendFuncDst ~= self.committed.blendFuncDst then

    local bfs = self.state.blendFuncSrc or gl.GL_ONE
    local bfd = self.state.blendFuncDst or gl.GL_ZERO
    gl.glBlendFunc(bfs, bfd)
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

function Context:glDepthMask(val)
  self.state.depthMask = val
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
