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

local Buffer = require('geom.buffer')
local MeshVertex = require('geom.meshvertex')

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

function Mesh.new(args)
  local self = {
    index = Buffer('GLuint', args and args.index),
    vertex = Buffer('geom_MeshVertex', args and args.vertex),
    attributes = {'position', 'normal', 'tangent', 'texcoord'},
    kind = 'geom_MeshVertex',
    id = id,
  }
  return setmetatable(self, Mesh)
end

function Mesh:process()
  updateTangents(self)
end

return Mesh.new
