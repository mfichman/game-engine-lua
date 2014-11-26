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
local window = require('window')
local component = require('component')
local input = require('input')

local Game = {}; Game.__index = Game

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
local function processDb(db, event, process)
  for i, kind in ipairs(process) do
    local table = db.table[kind]
    if table then
      processTable(table, event)
    end
  end
end

-- Create a new game object
function Game.new()
  local self = setmetatable({}, Game)
  self.window = window.Window()
  self.db = db.Database()
  self.input = input.Map()
  self.config = config
  self.graphics = graphics.Context(config.display.width, config.display.height)
  self.renderer = renderer.Deferred(self.graphics)
  self.world = physics.World()
  self.world:setGravity(vec.Vec3())
  self.clock = sfml.Clock()
  self.accumulator = 0
  self.timestep = 1/60
  self.samples = {}
  self.process = {}
  self.ticks = 0
  return self
end

-- Call 'event' on each component in the game database.
function Game:apply(event)
  processDb(self.db, event, self.process)
end

-- Increment the game by one tick (send the 'tick' event to all components)
function Game:tick()
  self.world:stepSimulation(self.timestep, 0, self.timestep) 
  self:apply('tick')
  self.ticks = self.ticks+1
end

-- Render a single frame. 
function Game:render()
  self:apply('render')
  self.renderer:render() 
  self.graphics:finish()
  self.window:display()
  assert(gl.glGetError() == 0)
end

-- Handle physics update. Execute fixed-time ticks to bring the physics state
-- up as close to current time as possible. Then, interpolate positions of
-- objects using the remaining time.
function Game:update()
  self.delta = self.clock:getElapsedTime():asSeconds()
  self.accumulator = self.accumulator + self.delta
  self.clock:restart()

  local substeps, remainder = math.modf(self.accumulator/self.timestep)
  
  -- Clamp substeps to drop ticks if the physics engine gets too far behind.
  -- The game doesn't get stuck in the substep loop for a long time if the
  -- window is closed or the computer slows down.
  if substeps > 8 then
    print(string.format('warning: dropping %d frames', substeps-8))
    substeps = 8
  end
  self.accumulator = remainder*self.timestep

  -- Run Bullet with maxSubSteps=0, which causes Bullet to step by exactly do
  -- one substep of exactly timestep seconds. The code in this function handles
  -- framerate independence and interpolation by itself, so we don't need
  -- Bullet to do it. After each step, fire a 'tick' event, so that components
  -- that must update each frame are notified.
  for i=1,substeps do
    self:tick()
  end

  -- Call Bullet to do intepolation once per frame.
  self.world:synchronizeMotionStates(self.accumulator, self.timestep)
  self:apply('update')
end

-- Handle input and step the simulation as necessary
local event = sfml.Event() -- FIXME: Optimization to prevent JIT escape
function Game:poll()
  while self.window:pollEvent(event) == 1 do
    if event.type == sfml.EvtClosed then os.exit(0) end
  end
end

-- Sample performance data
function Game:sample()
  table.insert(self.samples, self.delta * 1000) -- convert to ms
  if #self.samples > 1000 then
    local min, max, median, mean, stdev = stats.stats(self.samples)
    print(string.format('min=%05.2f max=%05.2f median=%05.2f mean=%05.2f stdev=%05.2f', min, max, median, mean, stdev))
    self.samples = {}
  end
end

function Game:gc()
  if self.delta < self.timestep/4 then
    collectgarbage('step', 1)
  end
end

-- Run the game
function Game:run()
  collectgarbage('stop')
  for i, v in ipairs(config.process) do
    table.insert(self.process, component[v])
  end

  self.clock:restart()
  while self.window:isOpen() do
    self:poll()
    self:update()
    self:render()
    self:gc()
    --self:sample()
  end
  collectgarbage('restart')
end

function Game:Table(kind)
  local kind = component[kind]
  return self.db:tableIs(kind)
end

function Game:Entity(metatable)
  assert(metatable, 'metatable is nil')
  local id = self.db:newEntityId()
  local table = self.db:tableIs(component.Entity)
  table[id] = metatable
  return table[id]
end

function Game:del()
  sfml.Window_destroy(self.window)  
  self.window = nil
end

Game.__gc = Game.del

return Game.new() -- singleton

