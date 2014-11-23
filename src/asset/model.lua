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

local graphics = require('graphics')
local vec = require('vec')
local path = require('path')
local loaded = require('asset.loaded')
local physics = require('physics')
local ffi = require('ffi')

-- Returns a vertex from the cache, if it exists in the cache. Otherwise, inserts
-- a new vertex into the vertex buffer and returns its index.
local function vertex(context, key)
  if context.cache[key] then return context.cache[key] end

  local i, j, k = key:match('(%d+)/(%d+)/(%d+)')
  local index = context.model.mesh.vertex.count

  local vertex = graphics.MeshVertex {
    position=context.position[tonumber(i)],
    texcoord=context.texcoord[tonumber(j)],
    normal=context.normal[tonumber(k)],
  }

  context.model.mesh.vertex:push(vertex)
  context.cache[key] = index
  return index
end

-- Create a convext hull shape from a mesh's vertices and indices. Load the
-- resulting shape into the loaded asset table.
local function shape(context)
  local mesh = context.model.mesh
  local shape = physics.ConvexHullShape(
    mesh.index.element, 
    mesh.index.count, 
    ffi.cast('vec_Vec3*', mesh.vertex.element), 
    mesh.vertex.count, 
    ffi.sizeof(mesh.vertex.element[0]))

  local name = context.model.name:gsub('[.]obj', '.shape')
  loaded[name] = shape
  context.shape:addChildShape(vec.Transform(), shape) 
end

-- Parses a single line from a Wavefront OBJ file, and updates the context
-- accordingly.
local function line(context, str)
  if str:match('^%s*#') then return
  elseif str:match('^%s*$') then return end
 
  local cmd, rest = str:match('^%s*(%w+)%s+(.*)%s*')
  if cmd == nil then error('invalid str: '..str) end

  if 'usemtl' == cmd then
    if rest ~= 'None' then
      local path = path.join('material', context.mtllib, rest)
  
      context.model.material = loaded[path]
      assert(context.model.material, 'material not found: '..path)
    end
  elseif 'o' == cmd then
    if context.model then
      shape(context)
    end
    context.model = graphics.Model()
    context.model.mesh = graphics.Mesh()
    context.model.name = path.join(context.path, rest)
    context.model.material = graphics.Material()
    context.transform:componentIs(context.model)
    context.cache = {}
    loaded[context.model.name] = context.model.mesh

    if rest:match('^%.') then
      context.model.renderMode = 'invisible'
    end
  elseif 'v' == cmd then
    local x, y, z = rest:match('(-?%d+%.?%d*)%s+(-?%d+%.?%d*)%s+(-?%d+%.?%d*)')
    table.insert(context.position, vec.Vec3(tonumber(x), tonumber(y), tonumber(z)))
  elseif 'vt' == cmd then
    local u, v = rest:match('(-?%d+%.?%d*)%s+(-?%d+%.?%d*)')
    table.insert(context.texcoord, vec.Vec2(tonumber(u), tonumber(v)))
  elseif 'vn' == cmd then
    local x, y, z = rest:match('(-?%d+%.?%d*)%s+(-?%d+%.?%d*)%s+(-?%d+%.?%d*)')
    table.insert(context.normal, vec.Vec3(tonumber(x), tonumber(y), tonumber(z)))
  elseif 'f' == cmd then
    local i, j, k = rest:match('(.+)%s+(.+)%s+(.+)')
    context.model.mesh.index:push(vertex(context, i))
    context.model.mesh.index:push(vertex(context, j))
    context.model.mesh.index:push(vertex(context, k))
  elseif 'mtllib' == cmd then
    local asset = require('asset')
    asset.open(path.join('material', rest))
    context.mtllib = rest
  else
    -- Unsupported command; skip
  end

end

-- Load a mesh, and its attached materials. Also, create a physics shape and
-- load that into memory too. Currently, this method creates a convex hull
-- shape for each sub-mesh, and then combines those convex hull shapes into a
-- single compound shape.
local function open(path)
  local fd = io.open(path)
  if not fd then error('file not found: '..path) end

  local context = { 
    transform=graphics.Transform(), 
    shape=physics.CompoundShape(),
    path=path,
    position={},
    texcoord={},
    normal={},
  } 
  context.transform.name = path

  for str in fd:lines() do
    line(context, str)
  end

  if context.model then
    shape(context)
  end

  loaded[path:gsub('[.]obj', '.shape')] = context.shape
  return context.transform
end

return {
  open=open,
}
