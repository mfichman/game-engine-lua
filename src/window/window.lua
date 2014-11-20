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
  
  local settings = sfml.ContextSettings()
  settings.depthBits = 24
  settings.stencilBits = 0
  settings.majorVersion = 3
  settings.minorVersion = 2
  
  local style
  if config.display.fullscreen then
    style = sfml.Fullscreen
  else
    style = sfml.DefaultStyle
  end
  
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
  gl.glClearColor(0, 0, 0, 1)

  return window
end

return Window.new
