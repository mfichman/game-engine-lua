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
local asset = require('asset')
local profiler = require('profiler')

local Game = {}; Game.__index = Game

-- Call 'event' on each row in the table. If the first row in the table does 
-- not have 'event' as a member, then skip all other components in the table as
-- an optimization, to avoid iterating through the entire table without 
-- actually updating anything.
local function processTable(table, event)
  for id, component in pairs(table.component) do
    if type(component) == 'cdata' then return end
    local handler = component[event]
    if not handler then return end
    handler(component, id)
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
  local viewport = vec.Vec2(config.display.width, config.display.height)
  local context = graphics.Context(config.display.width, config.display.height)
  local self = {
    window = window.Window(),
    camera = graphics.Camera{viewport = viewport},
    uicamera = graphics.Camera{
      viewport = viewport,
      mode = 'ortho',
      top = 0,
      bottom = 1,
      left = 0,
      right = viewport.width/viewport.height,
      far = 0,
      near = 1,
    },
    db = db.Database(),
    input = input.Map(),
    config = config,
    graphics = context,
    renderer = renderer.Deferred(context),
    world = physics.World(),
    clock = sfml.Clock(),
    accumulator = 0,
    timestep = 1/60,
    samples = {},
    process = {},
    ticks = 0,
    tickHandler = {},
  }
  self.uicamera:update()

  for i, name in ipairs(self.config.preload) do
    asset.open(name)
  end
  self.world:setGravity(vec.Vec3())

  return setmetatable(self, Game)
end

-- Call 'event' on each component in the game database.
function Game:sendEvent(event)
  processDb(self.db, event, self.process)
end

-- Increment the game by one tick (send the 'tick' event to all components)
function Game:tick()
  self.world:stepSimulation(self.timestep, 0, self.timestep) 
  self:sendEvent('tick')
  self.ticks = self.ticks+1
  for i, handler in ipairs(self.tickHandler) do
    handler()
  end
end

-- Render a single frame. 
function Game:render()
  self:sendEvent('render')
  self.renderer:render() 
  self.graphics:finish()
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

  -- Run Bullet with maxSubSteps = 0, which causes Bullet to step by exactly do
  -- one substep of exactly timestep seconds. The code in this function handles
  -- framerate independence and interpolation by itself, so we don't need
  -- Bullet to do it. After each step, fire a 'tick' event, so that components
  -- that must update each frame are notified.
  for i = 1,substeps do
    self:tick()
  end

  if substeps > 2 then
    print('warning: > 1 substeps')
  end

  -- Call Bullet to do intepolation once per frame.
  self.world:synchronizeMotionStates(self.accumulator, self.timestep)
  self:sendEvent('update')
end

-- Handle input and step the simulation as necessary
function Game:poll()
  local event = sfml.Event()
  while self.window:pollEvent(event) == 1 do
    if event.type == sfml.EvtClosed then 
      os.exit(0) 
    elseif event.type == sfml.EvtMouseButtonPressed then
      self:sendEvent('mouseDown')
    elseif event.type == sfml.EvtMouseButtonReleased then
      self:sendEvent('mouseUp')
    end
  end
end

-- Sample performance data
function Game:sample()
  table.insert(self.samples, self.delta * 1000) -- convert to ms
  if #self.samples > 100 then
    local min, max, median, mean, stdev = stats.stats(self.samples)
    print(string.format('min = %05.2f max = %05.2f median = %05.2f mean = %05.2f stdev = %05.2f', min, max, median, mean, stdev))
    self.samples = {}
  end
  if self.ticks % 500 == 0 then
    local luaMem = math.floor(collectgarbage('count'))
    local physicsMem = math.floor(self.world:getMemUsage()/1024)
    print(('luaMem = %.0fK physicsMem = %.0fK'):format(luaMem, physicsMem))
  end
end

function Game:gc()
  -- Allocate 5 ms for GC; skip GC if there aren't 5 ms left in the frame
  local start = self.clock:getElapsedTime():asSeconds()
  local remaining = self.timestep - start 
  local budget = .005
  if remaining > budget then
    collectgarbage('step', 2)
  else
    print('warning: skipped gc')
  end
end

-- Run the game
function Game:run()
  collectgarbage('stop')
  for i, name in ipairs(config.process) do -- FIXME
    table.insert(self.process, component[name])
  end

  self.clock:restart()
  --profiler.start()
  --for i=1,1000 do
  while self.window:isOpen() do
    -- The order of the operations here is very sensitive for performance
    -- reasons, especially with vsync enabled.  Poll is done immediately before
    -- update to reduce input lag. 
    self:poll()
    self:update()
    -- Render is done after update, to reduce output lag following a physics
    -- world update. 
    self:render()
    -- GC and other low-priority tasks are executed after render, so that they
    -- only run if there is time left in the frame.
    self:gc() 
    self:sample()
    -- The backbuffer swap is ALWAYS last, because if vsync is enabled, then
    -- the process will go to sleep.
    self.window:display()
    -- glGetError stalls the pipeline until prior commands are finished; it
    -- should be delayed until last.
    assert(gl.glGetError() == 0)
  end
  --profiler.stop()
  --profiler.show()
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

return Game.new() -- singleton

