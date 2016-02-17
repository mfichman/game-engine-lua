-- ========================================================================== --
--                                                                            --
-- Copyright (c) 2014 Matt Fichman <matt.fichman@gmail.com>                   --
--                                                                            --
-- This file is part of Quadrant.  It is subject to the license terms in the  --
-- LICENSE.md file found in the top-level directory of this software package  --
-- and at http://github.com/mfichman/quadrant/blob/master/LICENSE.md.         --
-- No person may use, copy, modify, publish, distribute, sublicense and/or    --
-- sell any part of Quadrant except according to the terms contained in the   --
-- LICENSE.md file.                                                           --
--                                                                            --
-- ========================================================================== --

local gl = require('gl')
local vec = require('vec')

local Context = {}; Context.__index = Context
local Transform = require('graphics.transform')
local RenderOp = require('graphics.renderop')

-- Creates a rendering context, which tracks/caches graphics pipeline state.
function Context.new(width, height)
  assert(width, 'width is nil')
  assert(height, 'height is nil')
  local self = {
    viewport = vec.Vec2(width, height),
    worldMatrix = vec.Mat4.identity(),
    program = 0,
    op = {}, -- array of objects submitted for rendering in this frame
    state = {enabled = {}},
    committed = {enabled = {}},
  }
  return setmetatable(self, Context) 
end

-- Submit a node to the rendering pipline using the given model transform. 
-- If a Transform object is submitted, then propagate its transform to all of
-- its children.
function Context:submit(node, camera, worldTransform)
  assert(camera, "missing camera")
  if Transform == node.new then
    local tx
    if worldTransform then
      tx = worldTransform * vec.Transform(node.origin, node.rotation)
    else
      tx = vec.Transform(node.origin, node.rotation)
    end
    for _, c in ipairs(node.component) do
      self:submit(c, camera, tx)
    end
  else
    local worldMatrix
    if worldTransform then
      worldMatrix = vec.Mat4.transform(worldTransform.rotation, worldTransform.origin)
      if worldTransform.scale ~= 1 and worldTransform.scale ~= 0 then
        local scale = worldTransform.scale
        worldMatrix = worldMatrix * vec.Mat4.scale(scale, scale, scale)
      end
    else
      worldMatrix = vec.Mat4.identity()
    end
    table.insert(self.op, RenderOp(node, camera, worldMatrix))
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
  self.state = {enabled = {}}
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

function Context:glUniform1i(index, value)
  if index then gl.glUniform1i(index, value) end
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
