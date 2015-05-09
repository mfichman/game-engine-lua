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

local struct = require('graphics.struct')
local ffi = require('ffi')
local vec = require('vec')
local gl = require('gl')
local types = require('types')

local Buffer = require('graphics.buffer')
local MeshVertex = require('graphics.meshvertex')

local Mesh = {}; Mesh.__index = Mesh

-- Calculate the tangent vectors for face i
local function updateTangent(self, i)
  local i0 = self.index[i-2]
  local i1 = self.index[i-1]
  local i2 = self.index[i-0]

  local v0 = self.vertex[i0]
  local v1 = self.vertex[i1]
  local v2 = self.vertex[i2]

  local p0 = v0.position
  local p1 = v1.position
  local p2 = v2.position

  local d1 = p1 - p0
  local d2 = p2 - p1

  local tex0 = v0.texcoord
  local tex1 = v1.texcoord
  local tex2 = v2.texcoord

  local s1 = tex1.u - tex0.u
  local t1 = tex1.v - tex0.v
  local s2 = tex2.u - tex0.u
  local t2 = tex2.v - tex0.v
  local a = 1/(s1*t2 - s2*t1)

  v0.tangent = v0.tangent + ((d1*t2 - d2*t1)*a):unit()
  v1.tangent = v1.tangent + ((d1*t2 - d2*t1)*a):unit()
  v2.tangent = v2.tangent + ((d1*t2 - d2*t1)*a):unit()
end

-- Calculate and write tangent vectors for the mesh
local function updateTangents(self)
  if not self.index.element then return end
  for i = 2,self.index.count-1,3 do
    updateTangent(self, i)
  end
  for i = 0,self.vertex.count-1 do
    local vertex = self.vertex[i]
    vertex.tangent = vertex.tangent:unit()
  end
end

function Mesh.new()
  local self = {
    index = Buffer(gl.GL_ELEMENT_ARRAY_BUFFER, gl.GL_STATIC_DRAW, 'GLuint'),
    vertex = Buffer(gl.GL_ARRAY_BUFFER, gl.GL_STATIC_DRAW, 'graphics_MeshVertex'),
    status = 'dirty',
    id = 0,
    bounds = types.Box(), min = vec.Vec3(),
  }
  return setmetatable(self, Mesh)
end

-- Sync the mesh with the hardware
function Mesh:sync()
  if self.status == 'synced' then return end

  updateTangents(self)
  self.vertex:sync()
  self.index:sync() 

  if self.id == 0 then
    self.handle = gl.Handle(gl.glGenVertexArrays, gl.glDeleteVertexArrays)
    self.id = self.handle[0]
    gl.glBindVertexArray(self.id)
    gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, self.index.id)
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.vertex.id)
    struct.defAttribute('graphics_MeshVertex', 0, 'position')
    struct.defAttribute('graphics_MeshVertex', 1, 'normal')
    struct.defAttribute('graphics_MeshVertex', 2, 'tangent')
    struct.defAttribute('graphics_MeshVertex', 3, 'texcoord')
    gl.glBindVertexArray(0)
  end
  self.status = 'synced'
end

return Mesh.new
