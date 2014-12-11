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
local string = require('string')
local io = require('io')
local gl = require('gl')
local path = require('path')

local include, open

function include(path)
  return open(path).source
end

function open(name)
  local ext = string.match(name, '([^%.]+)$')
  local kind 
  if ext == 'frag' then
    kind = gl.GL_FRAGMENT_SHADER 
  elseif ext == 'vert' then
    kind = gl.GL_VERTEX_SHADER 
  elseif ext == 'geom' then
    kind = gl.GL_GEOMETRY_SHADER 
  else
    error('bad shader filetype: '..name) 
  end

  local fd = path.open(name)
  local source = fd:read('*all')
  source = source:gsub('#pragma%s+include%s+"(.-)"', include)
  fd:close()
  return graphics.Shader(kind, source)
end

return {
  open = open
}
