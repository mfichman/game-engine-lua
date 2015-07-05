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
--
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
