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
local vec = require('vec')
local loaded = require('asset.loaded')
local path = require('path')

local function color(rest)
  local r, g, b = rest:match('(-?%d+%.%d*)%s+(-?%d+%.%d*)%s+(-?%d+%.%d*)')
  return vec.Color(tonumber(r), tonumber(g), tonumber(b), 0)
end

-- Parses a single line from a MTL file
local function line(context, str)
  if str:match('^%s*#') then return
  elseif str:match('^%s*$') then return end

  local asset = require('asset')
  local cmd, rest = str:match('^%s*([_%w]+)%s+(.*)%s*')
  if cmd == nil then error('invalid str: '..str) end

  if 'newmtl' == cmd then
    if context.material then
      local path = path.join(context.path, context.material.name)
      loaded[path] = context.material
    end
    context.material = graphics.Material()
    context.material.name = rest
  elseif 'map_bump' == cmd or 'bump' == cmd then
    context.material.normalMap = asset.open(reset)
  elseif 'Ka' == cmd then
    context.material.ambientColor = color(rest)
  elseif 'Kd' == cmd then
    context.material.diffuseColor = color(rest)
  elseif 'Ke' == cmd then
    context.material.emissiveColor = color(rest)
  elseif 'Ks' == cmd then
    context.material.specularColor = color(rest)
  elseif 'Ns' == cmd then
    context.material.hardness = tonumber(rest)
  elseif 'map_Kd' == cmd then
    context.material.diffuseMap = asset.open(rest)
  elseif 'map_Ks' == cmd then 
    context.material.specularMap = asset.open(rest)
  elseif 'map_Ke' == cmd then
    context.material.emissiveMap = asset.open(rest)
  elseif 'd' == cmd then
    context.material.opacity = tonumber(rest)
  elseif 'shader' == cmd then
    context.material.program = asset.open(rest)
  else
    -- Unsupported command; skip
  end
end
   

-- Opens a .mtl material lib file and parses it into a Material obj
local function open(name)
  local fd = io.open(name)
  if not fd then error('file not found: '..name) end

  local context = { path = name }
  for str in fd:lines() do
    line(context, str) 
  end
  if context.material then
    local path = path.join(context.path, context.material.name)
    loaded[path] = context.material
  end
end

return {
  open = open,
}

