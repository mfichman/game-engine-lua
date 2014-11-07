
package.path = package.path..';./?/init.lua'

local graphics = require('graphics')
local gl = require('gl')
local sfml = require('sfml')
local os = require('os')


graphics.window.create()
--local b = graphics.Buffer('int')
--local p = graphics.Program('foo')
--print(p:log())

--[[
while true do
  local event = sfml.Event()
  while window:pollEvent(event) do
    if event.type == sfml.EvtClosed then os.exit(0) end

  end
end
]]
