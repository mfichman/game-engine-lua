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

local struct = require('graphics.struct')
local ffi = require('ffi')
local vec = require('vec')
local gl = require('gl')

local Buffer = require('graphics.buffer')

local Mesh = {}; Mesh.__index = Mesh

ffi.cdef[[
  typedef struct graphics_MeshVertex {
    vec_Vec3 position;
    vec_Vec3 normal;
    vec_Vec3 tangent;
    vec_Vec2 texcoord;
  } graphics_MeshVertex;
]]

local MeshVertex = ffi.typeof('graphics_MeshVertex')

function Mesh.new()
  local self = setmetatable({}, Mesh)
  self.status = 'dirty'
  self.id = 0
  self.index = Buffer(gl.GL_ELEMENT_ARRAY_BUFFER, gl.GL_STATIC_DRAW, 'GLuint')
  self.vertex = Buffer(gl.GL_ARRAY_BUFFER, gl.GL_STATIC_DRAW, 'graphics_MeshVertex')
  self.format = MeshVertex
  return self
end

function Mesh:sync()
  if self.status == 'synced' then return end
  if self.id == 0 then
    local id = ffi.new('GLint[1]')
    gl.glGenVertexArrays(1, id)
    self.id = id[0]
  end
  self.vertex:sync()
  self.index:sync() 

  gl.glBindVertexArray(self.id)
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.vertex.id)

  struct.defAttribute('graphics_MeshVertex', 0, 'position')
  struct.defAttribute('graphics_MeshVertex', 1, 'normal')
  struct.defAttribute('graphics_MeshVertex', 2, 'tangent')
  struct.defAttribute('graphics_MeshVertex', 3, 'texcoord')

  gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, self.index.id)
  gl.glBindVertexArray(0)
  self.status = 'synced'
end

function Mesh:del()
  local id = ffi.new('GLint[1]', self.id) 
  gl.glDeleteVertexArrays(1, id)
  self.id = 0
end

Mesh.__gc = Mesh.del

return Mesh.new
