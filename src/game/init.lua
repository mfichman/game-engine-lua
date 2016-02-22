-- Copyright (c) 2016 Matt Fichman
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
local gamemath = require('gamemath')
local config = require('config')
local graphics = require('graphics')
local renderer = require('renderer')
local physics = require('physics')
local gl = require('gl')
local bit = require('bit')
local vec = require('vec')
local stats = require('stats')
local window = require('window')
local input = require('input')
local asset = require('asset')
local profiler = require('profiler')

local self = {}

-- Initialize game variables
local input = input.Map()
local clock = sfml.Clock()
local accumulator = 0
local remainder = 0
local timestep = 1/60
local samples = {}
local ticks = 0
local eventHandler
local world
local delta = 0

-- Send an event to the event handler
local function sendEvent(event)
  if eventHandler then
    eventHandler(event)
  end
end

-- Increment the game by one tick (send the 'tick' event to all components)
local function tick()
  world:stepSimulation(timestep, 0, timestep) 
  sendEvent('tick')
  ticks = ticks+1
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
  clock:restart()

  local substeps, remainder = math.modf((accumulator+delta)/timestep)
  
  -- Clamp substeps to drop ticks if the physics engine gets too far behind.
  -- The game doesn't get stuck in the substep loop for a long time if the
  -- window is closed or the computer slows down.
  if substeps > 8 then
    if config.log.warning then
      print(string.format('warning: dropping %d frames', substeps-8))
    end
    substeps = 8
  end

  accumulator = 0

  -- Run Bullet with maxSubSteps = 0, which causes Bullet to step by exactly do
  -- one substep of exactly timestep seconds. The code in this function handles
  -- framerate independence and interpolation by itself, so we don't need
  -- Bullet to do it. After each step, fire a 'tick' event, so that components
  -- that must update each frame are notified.
  for i = 1,substeps do
    tick()
  end

  accumulator = remainder*timestep

  if substeps > 3 then
    if config.log.warning then
      print('warning: > 3 substeps', substeps)
    end
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
  if config.log.cpu then
    table.insert(samples, delta * 1000) -- convert to ms
    if #samples > 100 then
      local min, max, median, mean, stdev = stats.stats(samples)
      print(string.format('min = %05.2f max = %05.2f median = %05.2f mean = %05.2f stdev = %05.2f', min, max, median, mean, stdev))
      samples = {}
    end
  end
  if config.log.mem and ticks % 500 == 0 then
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
    collectgarbage('step', 1)
  elseif config.log.warning then
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
  collectgarbage('stop')
  clock:restart()
  --profiler.start()
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
function self.init(handler)
  world = physics.World()
  window = window.Window()
  renderer = renderer.Deferred(graphics.context)

  eventHandler = handler
  self.world = world
  self.window = window
  self.renderer = renderer
  self.camera = graphics.Camera{viewport = graphics.viewport}
  self.camera:update()

  for i, name in ipairs(config.preload) do
    asset.open(name)
  end
  world:setGravity(vec.Vec3())
end

self.timestep = timestep
self.input = input
self.world = world
self.ticks = function() return ticks end
self.time = function() return ticks*timestep + accumulator end

return self
