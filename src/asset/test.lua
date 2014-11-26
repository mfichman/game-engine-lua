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
local sfml = require('sfml')
local asset = require('asset')
local ffi = require('ffi')

local settings = sfml.ContextSettings()
settings.depthBits = 24
settings.stencilBits = 0
settings.majorVersion = 3
settings.minorVersion = 2

local context = sfml.Context()
if ffi.os == 'Windows' then
  local glew = require('glew')
  glew.glewInit()
end

assert(asset.open('texture/White.png'))
assert(asset.open('shader/Flat.frag'))

local m = asset.open('mesh/Quad.obj')
assert(m)
assert(m.new == graphics.Transform)

local m = m.component[1]
assert(m)
assert(m.new == graphics.Model)
assert(m.material)
assert(m.mesh)
assert(m.mesh.vertex)
assert(m.mesh.index)


local m = asset.open('mesh/Quad.obj')
assert(m)
assert(m.new == graphics.Transform)

local m = m.component[1]
assert(m)
assert(m.new == graphics.Model)
assert(m.material)
assert(m.mesh)
assert(m.mesh.vertex)
assert(m.mesh.index)


local m = asset.open('mesh/Rock0.obj')
assert(m)
assert(m.new == graphics.Transform)

local m = m.component[1]
assert(m)
assert(m.new == graphics.Model)
assert(m.material.hardness > 96)
assert(m.material.ambientColor.r == 0)
assert(m.material.diffuseColor.r > .32)
assert(m.material.specularColor.r == 0)
assert(m.material.opacity == 1)

local m = asset.open('mesh/Rock0.shape')
assert(m)

local m = asset.open('mesh/Rock0.shape/Cube')
assert(m)

