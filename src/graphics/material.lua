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

local Material = {}; Material.__index = Material

function Material.new(args)
  local args = args or {}
  local self = {
    diffuseMap = args.diffuseMap,
    specularMap = args.specularMap,
    normalMap = args.normalMap,
    emissiveMap = args.emissiveMap,
    ambientColor = args.ambientColor or vec.Vec4(0, 0, 0, 1),
    diffuseColor = args.diffuseColor or vec.Vec4(1, 1, 1, 1),
    specularColor = args.specularColor or vec.Vec4(1, 1, 1, 1),
    emissiveColor = args.emissiveColor or vec.Vec4(0, 0, 0, 1),
    hardness = args.hardnesss or 40,
    opacity = args.opacity or 1,
    blendMode = args.blendMode or 'alpha',
    name = args.name,
  }
  return setmetatable(self, Material)
end

function Material:clone()
  return Material.new(self)
end

return Material.new
