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

local ffi = require('ffi')
local package = require('package')
local path = require('path')

local glew, opengl32
ffi.cdef(path.open('gl/glenum.h'):read('*all'))

if ffi.os == 'Windows' then
  glew = require('glew')
  opengl = ffi.load('opengl32')
else
  ffi.cdef(path.open('gl/gl.h'):read('*all'))
end


local function symbol(name)
  local ok, ret = pcall(function() return ffi.C[name] end)
  if ok then return ret end
  local ok, ret = pcall(function() return opengl[name] end)
  if ok then return ret end
  local name = name:gsub('^gl', '__glew')
  local ok, ret = pcall(function() return glew[name] end)
  if ok then return ret end
  error('symbol not found: '..name)
end

-- Look up the OpenGL function in the current executable first. If it's not
-- found, then look in libglew instead for the glew binding.
local function index(t, k)
    local fn = symbol(k)
    rawset(t, k, fn)
    return fn
end

-- Initialize a new handle using the given handle creation function.  Wrap the
-- handle in a gc object, so that it's GC'd when no longer referenced
local function Handle(gen, delete)
  local id = ffi.new('GLint[1]') 
  gen(1, id)
  return ffi.gc(id, function(id) delete(1, id) end)
end

return setmetatable({Handle=Handle}, {__index = index})
