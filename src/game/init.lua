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
local gamemath = require('gamemath')
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

local self = {}

-- Initialize game variables
local db = db.Database()
local input = input.Map()
local clock = sfml.Clock()
local accumulator = 0
local timestep = 1/60
local samples = {}
local process = {}
local ticks = 0
local tickHandler = {}

-- Call 'event' on each row in the table. If the first row in the table does 
-- not have 'event' as a member, then skip all other components in the table as
-- an optimization, to avoid iterating through the entire table without 
-- actually updating anything.
local function processTable(table, event)
  local count = 0
  for id, component in pairs(table.component) do
    if type(component) == 'cdata' then return end
    local handler = component[event]
    if not handler then return end
    handler(component, id)
    count = count +1
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

-- Call 'event' on each component in the game database.
local function sendEvent(event)
  processDb(db, event, process)
end

-- Increment the game by one tick (send the 'tick' event to all components)
local function tick()
  world:stepSimulation(timestep, 0, timestep) 
  sendEvent('tick')
  ticks = ticks+1
  for i, handler in ipairs(tickHandler) do
    handler()
  end
end

-- Render a single frame. 
local function render()
  sendEvent('render')
  renderer:render() 
  graphics.finish()
end

-- Handle physics update. Execute fixed-time ticks to bring the physics state
-- up as close to current time as possible. Then, interpolate positions of
-- objects using the remaining time.
local function update()
  delta = clock:getElapsedTime():asSeconds()
  accumulator = accumulator + delta
  clock:restart()

  local substeps, remainder = math.modf(accumulator/timestep)
  
  -- Clamp substeps to drop ticks if the physics engine gets too far behind.
  -- The game doesn't get stuck in the substep loop for a long time if the
  -- window is closed or the computer slows down.
  if substeps > 8 then
    print(string.format('warning: dropping %d frames', substeps-8))
    substeps = 8
  end
  accumulator = remainder*timestep

  -- Run Bullet with maxSubSteps = 0, which causes Bullet to step by exactly do
  -- one substep of exactly timestep seconds. The code in this function handles
  -- framerate independence and interpolation by itself, so we don't need
  -- Bullet to do it. After each step, fire a 'tick' event, so that components
  -- that must update each frame are notified.
  for i = 1,substeps do
    tick()
  end

  if substeps > 3 then
    print('warning: > 3 substeps', substeps)
  end

  -- Call Bullet to do intepolation once per frame.
  world:synchronizeMotionStates(accumulator, timestep)
  sendEvent('update')
end

-- Handle input and step the simulation as necessary
local function poll()
  local event = sfml.Event()
  while window:pollEvent(event) == 1 do
    if event.type == sfml.EvtClosed then 
      os.exit(0) 
    elseif event.type == sfml.EvtMouseButtonPressed then
      sendEvent('mouseDown')
    elseif event.type == sfml.EvtMouseButtonReleased then
      sendEvent('mouseUp')
    elseif event.type == sfml.EvtKeyPressed then
      sendEvent('keyDown')
    elseif event.type == sfml.EvtKeyReleased then
      sendEvent('keyUp')
    end
  end
end

-- Sample performance data
local function sample()
  table.insert(samples, delta * 1000) -- convert to ms
  if #samples > 100 then
    local min, max, median, mean, stdev = stats.stats(samples)
    print(string.format('min = %05.2f max = %05.2f median = %05.2f mean = %05.2f stdev = %05.2f', min, max, median, mean, stdev))
    samples = {}
  end
  if ticks % 500 == 0 then
    local luaMem = math.floor(collectgarbage('count'))
    local physicsMem = math.floor(world:getMemUsage()/1024)
    print(('luaMem = %.0fK physicsMem = %.0fK'):format(luaMem, physicsMem))
  end
end

local function gc()
  -- Allocate 5 ms for GC; skip GC if there aren't 5 ms left in the frame
  local elapsed = clock:getElapsedTime():asSeconds()
  local remaining = timestep - elapsed
  local budget = .002

  if remaining > budget then
    --collectgarbage('step', 1)
  else
    print('warning: skipped gc', budget, elapsed)
  end
end

local function sleep()
  -- Sleep to use remaining frame time
  local elapsed = clock:getElapsedTime():asSeconds()
  local remaining = sfml.Seconds(timestep - elapsed - .001)
  sfml.Sleep(remaining)
end

-- Run the game
function self.run()
  --collectgarbage('stop')
  for i, name in ipairs(config.process) do -- FIXME
    table.insert(process, component[name])
  end

  clock:restart()
  profiler.start()
  --for i=1,1000 do
  while window:isOpen() do
    -- The order of the operations here is very sensitive for performance
    -- reasons, especially with vsync enabled.  Poll is done immediately before
    -- update to reduce input lag. 
    poll()
    update()
    -- Render is done after update, to reduce output lag following a physics
    -- world update. 
    render()
    -- GC and other low-priority tasks are executed after render, so that they
    -- only run if there is time left in the frame.
    gc() 
    sample()
    -- The backbuffer swap is ALWAYS last, because if vsync is enabled, then
    -- the process will go to sleep.
    window:display()
    -- glGetError stalls the pipeline until prior commands are finished; it
    -- should be delayed until last.
    --assert(gl.glGetError() == 0)
    sleep()
  end
  --profiler.stop()
  --profiler.show()
  collectgarbage('restart')
end

-- Initialize the game
function self.init()
  world = physics.World()
  window = window.Window()
  renderer = renderer.Deferred(graphics.context)

  self.world = world
  self.window = window
  self.renderer = renderer

  for i, name in ipairs(config.preload) do
    asset.open(name)
  end
  world:setGravity(vec.Vec3())
end

function self.Table(kind)
  local kind = component[kind]
  return db:tableIs(kind)
end

function self.Entity(metatable)
  assert(metatable, 'metatable is nil')
  local id = db:newEntityId()
  local table = db:tableIs(component.Entity)
  table[id] = metatable
  return table[id]
end

self.timestep = timestep
self.db = db
self.input = input
self.world = world
self.ticks = function() return ticks end
self.tickHandler = tickHandler


return self
