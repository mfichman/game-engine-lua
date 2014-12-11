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
    end
    if kmouse then
      args.mouse = mouse[kmouse:lower()]
    end
    self[action] = Binding(args)
  end
  return self
end

return Map.new
