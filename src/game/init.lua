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
local config = require('config')
local graphics = require('graphics')
local renderer = require('renderer')
local physics = require('physics')
local db = require('db')
local gl = require('gl')
local bit = require('bit')
local vec = require('vec')
local stats = require('stats')
local ffi = require('ffi')
local component = require('component')

local Game = {}; Game.__index = Game

-- Create a new window from the current config
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

-- Call 'event' on each row in the table. If the first row in the table does 
-- not have 'event' as a member, then skip all other components in the table as
-- an optimization, to avoid iterating through the entire table without 
-- actually updating anything.
local function processTable(table, event)
  for id, component in pairs(table.component) do
    if type(component) == 'cdata' then return end
    if not component[event] then return end
    component[event](component, id)
  end 
end

-- Call 'event' on each table in the database.
local function processDb(db, event)
  for kind, table in pairs(db.table) do
    processTable(table, event)
  end
end

-- Create a new game object
function Game.new()
  local self = setmetatable({}, Game)
  self.window = window()
  self.db = db.Database()
  self.config = config
  self.graphics = graphics.Context(config.display.width, config.display.height)
  self.renderer = renderer.Deferred(self.graphics)
  self.world = physics.World()
  self.world:setGravity(vec.Vec3())
  self.clock = sfml.Clock()
  return self
end

-- Call 'event' on each component in the game database.
function Game:apply(event)
  processDb(self.db, event)
end

-- Increment the game by one tick (send the 'tick' event to all components)
function Game:tick()
  self:apply('tick')
end

-- Render a single frame. 
function Game:render()
  self:apply('render')
  self.renderer:render() 
  self.graphics:finish()
  assert(gl.glGetError() == 0)
end

-- Handle input and step the simulation as necessary
function Game:poll()
  self.samples = self.samples or {}
  self.clock:restart()
  local event = sfml.Event()
  while self.window:pollEvent(event) == 1 do
    if event.type == sfml.EvtClosed then os.exit(0) end
  end
  self:render()
  self.window:display()

  collectgarbage('collect')
  table.insert(self.samples, self.clock:getElapsedTime():asSeconds())
  if #self.samples > 100 then
    print(stats.stats(self.samples))
    self.samples = {}
  end
end

-- Run the game
function Game:run()
  while self.window:isOpen() do
    self:poll()
  end
end

function Game:Table(kind)
  local kind = component[kind]
  return self.db:tableIs(kind)
end

function Game:Entity(id, data)
  local id = id or self.db:entityIs()
  for i, data in ipairs(data) do
    local kind = component[data[1]]
    self.db:componentIs(kind, id, kind(id, data))
  end
  return id
end

function Game:del()
  sfml.Window_destroy(self.window)  
  self.window = nil
end

Game.__gc = Game.del

return Game.new() -- singleton

