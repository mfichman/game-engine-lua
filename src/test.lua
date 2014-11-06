
package.path = package.path..';./?/init.lua'

local graphics = require('graphics')
local gl = require('gl')
local sfml = require('sfml')
local os = require('os')

local mode = sfml.VideoMode()
mode.bitsPerPixel = 32
mode.width = 100
mode.height = 100

local settings = sfml.ContextSettings()
settings.depthBits = 24
settings.stencilBits = 0
settings.majorVersion = 3
settings.minorVersion = 2

local window = sfml.Window(mode, "test", sfml.DefaultStyle, settings)

local p = graphics.Program.new('foo')
print(p:log())

--[[
while true do
  local event = sfml.Event()
  while window:pollEvent(event) do
    if event.type == sfml.EvtClosed then os.exit(0) end

  end
end
]]
