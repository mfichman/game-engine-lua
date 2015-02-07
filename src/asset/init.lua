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

local loaders = {
  ['%.png$'] = require('asset.texture'),
  ['%.jpg$'] = require('asset.texture'),
  ['%.gif$'] = require('asset.texture'),
  ['%.obj$'] = require('asset.model'),
  ['%.mtl$'] = require('asset.material'),
  ['%.prog$'] = require('asset.program'),
  ['%.vert$'] = require('asset.shader'),
  ['%.geom$'] = require('asset.shader'),
  ['%.frag$'] = require('asset.shader'),
  ['%.ttf$'] = require('asset.font'),
}

local loaded = require('asset.loaded')

local function open(name, ...)
  if loaded[name] then return loaded[name] end
  for pattern, loader in pairs(loaders) do
    if name:match(pattern) then
      local asset = loader.open(name, ...)
      loaded[name] = asset
      return asset
    end
  end
  error('no loader found for '..name)
end

return {
  open = open,
  texture = require('asset.texture'),
  model = require('asset.model'),
  material = require('asset.material'),
  program = require('asset.program'),
  shader = require('asset.shader'),
  loaded = loaded,
}

