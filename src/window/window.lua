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

local config = require('config')
local sfml = require('sfml')
local ffi = require('ffi')
local gl = require('gl')

local Window = {}; Window.__index = Window

-- Create a new window from the current config
function Window.new()
  local mode = sfml.VideoMode()
  mode.bitsPerPixel = 32
  mode.width = config.display.width
  mode.height = config.display.height
  
  local style = config.display.fullscreen and sfml.Fullscreen or sfml.DefaultStyle
  local settings = sfml.ContextSettings()
  settings.depthBits = 24
  settings.stencilBits = 0
  settings.majorVersion = 0
  settings.minorVersion = 0

  local window = sfml.Window(mode, "quadrant", style, settings)
  window:setVerticalSyncEnabled(config.display.vsync)
  local settings = window:getSettings()
  if settings.majorVersion < 3 
     or (settings.majorVersion == 3 and settings.minorVersion < 2) then
    error('this program requires OpenGL 3.2')
  end

  if ffi.os == 'Windows' then
    local glew = require('glew')
    glew.glewInit()
  end

  gl.glViewport(0, 0, mode.width, mode.height)
  --gl.glClearColor(.03, .03, .03, 1)
  gl.glClearColor(.0, .0, .0, 1)

  return window
end

return Window.new
