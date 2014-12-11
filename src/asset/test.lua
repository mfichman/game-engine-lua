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

local graphics = require('graphics')
local sfml = require('sfml')
local asset = require('asset')
local ffi = require('ffi')

local settings = sfml.ContextSettings()
settings.depthBits = 24
settings.stencilBits = 0
settings.majorVersion = 3
settings.minorVersion = 3

local context = sfml.Context()
if ffi.os == 'Windows' then
  local glew = require('glew')
  glew.glewInit()
end

assert(asset.open('texture/White.png'))
assert(asset.open('shader/flat/Model.frag'))

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


local m = asset.open('mesh/LargeRock0.obj')
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

local m = asset.open('mesh/LargeRock0.shape')
assert(m)

local m = asset.open('mesh/LargeRock0.shape/Cube')
assert(m)

