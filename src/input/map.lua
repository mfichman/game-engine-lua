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
local key = require('input.key')
local mouse = require('input.mouse')

local Map = {}; Map.__index = Map
local Binding = require('input.binding')

local action = {
  'accel','brake','mine','click','alt','attack','inspect','inventory',
  'zoomin','zoomout'
}

-- Convert semantic actions (see above) into SFML keycodes/mousebutton codes
-- using the lookup tables in mouse.lua and key.lua.
function Map.new()
  local self = setmetatable({}, Map)
  for i, action in ipairs(action) do
    local kkey = config.key[action]
    local kmouse = config.mouse[action]
    local args = {}
    if kkey then
      args.key = key[kkey:lower()] 
      print(key, args.key)
    end
    if kmouse then
      args.mouse = mouse[kmouse:lower()]
    end
    self[action] = Binding(args)
  end
  return self
end

return Map.new
