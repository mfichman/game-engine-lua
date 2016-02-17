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

local vec = require('vec')
local ffi = require('ffi')
local gl = require('gl')

local Material = {}; Material.__index = Material

ffi.cdef[[
struct graphics_MaterialBuffer {
  vec_Color ambientColor;
  vec_Color diffuseColor;
  vec_Color specularColor;
  vec_Color emissiveColor;
  vec_Scalar hardness; 
} graphics_MaterialBuffer;
]]

local MaterialBuffer = ffi.typeof('struct graphics_MaterialBuffer')

function Material.new(args)
  local handle = gl.Handle(gl.glGenBuffers, gl.glDeleteBuffers)
  local id = handle[0]
  local args = args or {}
  local self = {
    id = handle[0],
    diffuseMap = args.diffuseMap,
    specularMap = args.specularMap,
    normalMap = args.normalMap,
    emissiveMap = args.emissiveMap,
    ambientColor = args.ambientColor or vec.Color(0, 0, 0, 1),
    diffuseColor = args.diffuseColor or vec.Color(1, 1, 1, 1),
    specularColor = args.specularColor or vec.Color(1, 1, 1, 1),
    emissiveColor = args.emissiveColor or vec.Color(0, 0, 0, 1),
    hardness = args.hardnesss or 40,
    opacity = args.opacity or 1,
    blendMode = args.blendMode or 'alpha',
    name = args.name,
    handle = handle,
  }

  local buffer = MaterialBuffer {
    ambientColor = self.ambientColor,
    diffuseColor = self.diffuseColor,
    specularColor = self.specularColor,
    emissiveColor = self.emissiveColor,
    hardness = self.hardness,
  }

  gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, self.id)
  gl.glBufferData(gl.GL_UNIFORM_BUFFER, ffi.sizeof(buffer), buffer, gl.GL_STATIC_DRAW)

  return setmetatable(self, Material)
end

function Material:clone()
  return self
end

return Material.new
