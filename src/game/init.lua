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

local sfml = require('sfml')
local config = require('game.config')
local graphics = require('graphics')
local db = require('db')
local gl = require('gl')
local bit = require('bit')
local vec = require('vec')

local Game = {}; Game.__index = Game

local function window()
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
  if settings.majorVersion < 3 or (settings.majorVersion == 3 and settings.minorVersion < 2) then
    error('this program requires OpenGL 3.2')
  end

  gl.glViewport(0, 0, mode.width, mode.height)
  gl.glClearColor(0, 0, 0, 1)

  return window
end

function Game.new()
  local self = setmetatable({}, Game)
  self.window = window()
  self.db = db.Database()
  self.config = config

  self.graphics = graphics.Context(config.display.width, config.display.height)
--[[
  self.graphics.camera.mode = 'ortho' -- FIXME

  self.graphics.camera.left = -2
  self.graphics.camera.right = 2

  self.graphics.camera.bottom = 2 -- ???
  self.graphics.camera.top = -2 -- ???

  self.graphics.camera.near = -2
  self.graphics.camera.far = 2

  self.graphics.camera:update()

--]]
  self.renderer = graphics.DeferredRenderer(self.graphics)

  return self
end

local function processTable(table, event)
  for id, component in pairs(table.component) do
    if not component[event] then return end
    component[event](component, id)
  end 
end

local function processDb(db, event)
  for kind, table in pairs(db.table) do
    processTable(table, event)
  end
end

function Game:apply(event)
  processDb(self.db, event)
end

function Game:tick()
  self:apply('tick')
end

function Game:render()
  local eye = vec.Vec3(0, 0, -10) -- FIXME
  local at = vec.Vec3(0, 0, 0)
  local up = vec.Vec3(0, 1, 0)
  self.graphics.camera.worldTransform = vec.Mat4.look(eye, at, up)
  self.graphics.camera:update()
  self:apply('render')
  self.renderer:render() 
  self.graphics:finish()
  assert(gl.glGetError() == 0)
end

function Game:poll()
  -- step simulation a few times
  local event = sfml.Event()
  while self.window:pollEvent(event) == 1 do
    if event.type == sfml.EvtClosed then os.exit(0) end
  end
  self:render()
  self.window:display()
end

function Game:run()
  while self.window:isOpen() do
    self:poll()
  end
end

function Game:del()
  sfml.Window_destroy(self.window)  
  self.window = nil
end

return Game.new() -- singleton

