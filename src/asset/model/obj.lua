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

local graphics = require('graphics')
local vec = require('vec')

-- Returns a vertex from the cache, if it exists in the cache. Otherwise, inserts
-- a new vertex into the vertex buffer and returns its index.
local function vertex(context, key)
  if context.cache[key] then return context.cache[key] end

  local i, j, k = key:match('(%d+)/(%d+)/(%d+)')
  local index = context.model.mesh.vertex.count

  local vertex = context.model.mesh.format()
  vertex.position = context.position[tonumber(i)]
  vertex.texcoord = context.texcoord[tonumber(j)]
  vertex.normal = context.normal[tonumber(k)]

  context.model.mesh.vertex:push(vertex)
  context.cache[key] = index
  return index
end

-- Parses a single line from a Wavefront OBJ file
local function line(context, str)
  if str:match('^%s*#') then return
  elseif str:match('^%s*$') then return end
 
  local cmd, rest = str:match('^%s*(%w+)%s+(.*)%s*')
  if cmd == nil then error('invalid str: '..str) end

  if 'usemtl' == cmd then
    if rest ~= 'None' then
      local asset = require('asset')
      context.model.material = asset.open(rest)
    end
  elseif 'o' == cmd then
    context.model = graphics.Model()
    context.model.mesh = graphics.Mesh()
    context.model.material = graphics.Material()
    context.transform:componentIs(context.model)
    context.position = {}
    context.texcoord = {}
    context.normal = {}
    context.cache = {}
  elseif 'v' == cmd then
    local x, y, z = rest:match('(-?%d+%.%d*)%s+(-?%d+%.%d*)%s+(-?%d+%.%d*)')
    table.insert(context.position, vec.Vec3(tonumber(x), tonumber(y), tonumber(z)))
  elseif 'vt' == cmd then
    local u, v = rest:match('(-?%d+%.%d*)%s+(-?%d+%.%d*)')
    table.insert(context.texcoord, vec.Vec2(tonumber(u), tonumber(v)))
  elseif 'vn' == cmd then
    local x, y, z = rest:match('(-?%d+%.%d*)%s+(-?%d+%.%d*)%s+(-?%d+%.%d*)')
    table.insert(context.normal, vec.Vec3(tonumber(x), tonumber(y), tonumber(z)))
  elseif 'f' == cmd then
    local i, j, k = rest:match('(.+)%s+(.+)%s+(.+)')

    context.model.mesh.index:push(vertex(context, i))
    context.model.mesh.index:push(vertex(context, j))
    context.model.mesh.index:push(vertex(context, k))
  elseif 'mttlib' == cmd then
    local asset = require('asset')
    asset.open(rest)
  else
    -- Unsupported command; skip
  end

end

local function open(path)
  local fd = io.open(path)
  if not fd then error('file not found: '..path) end

  local context = { transform=graphics.Transform() } 
  for str in fd:lines() do
    line(context, str)
  end
  return context.transform
end

return {
  open=open
}
