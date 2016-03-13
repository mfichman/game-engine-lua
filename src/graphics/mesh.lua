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

local ffi = require('ffi')
local vec = require('vec')
local types = require('types')
local gl = require('gl')
local struct = require('graphics.struct')

local Buffer = require('graphics.buffer')

local Mesh = {}; Mesh.__index = Mesh

-- Creates a new mesh object (VAO) consisting of an index vertex array with the
-- defined attributes and vertex format.
function Mesh.new(geom)
  local index = geom.index.id and geom.index or Buffer(gl.GL_ELEMENT_ARRAY_BUFFER, gl.GL_STATIC_DRAW, geom.index)
  local vertex = geom.vertex.id and geom.vertex or Buffer(gl.GL_ARRAY_BUFFER, gl.GL_STATIC_DRAW, geom.vertex)
  local handle = gl.Handle(gl.glGenVertexArrays, gl.glDeleteVertexArrays)
  local id = handle[0]

  gl.glBindVertexArray(id)
  gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, index.id)
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vertex.id)
  for i,attribute in ipairs(geom.attributes) do
    struct.defAttribute(geom.kind, i-1, attribute)
  end
  gl.glBindVertexArray(0)

  local self = {
    index = index,
    vertex = vertex,
    id = id,
    handle = handle,
  }
  return setmetatable(self, Mesh)
end

return Mesh.new
