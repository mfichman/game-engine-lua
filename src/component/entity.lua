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

local component = require('component')
local game = require('game')

local Entity = {}; Entity.__index = Entity

-- The entity component is a special component that coordinates the other
-- components. It acts like a state machine, adding and removing other
-- components as the entity changes state. Additionally, the user specifies a
-- metatable to use for state change callbacks. In these callbacks, the user
-- can call stateIs to change the state of the entity.
function Entity.new(id, metatable)
  local self = {
    id = id, 
    metatable = metatable,
  }
  return setmetatable(self, Entity)
end

function Entity:__index(k)
  return Entity[k] or self.metatable[k]
end

-- Do a state change: delete any components that are not specified in the new
-- component list (data), and reinstantiate any components that have args.
-- Leave components without args as-is.
function Entity:stateIs(data)
  local keep = {[Entity.new]=true}
  for i, data in ipairs(data) do
    local kind = data[1]
    local kind = (type(kind) == 'function') and kind or component[kind]
    local table = game.database:tableIs(kind)
    if not table[self.id] then
      table[self.id] = data
    end
    keep[kind] = true
  end
  for kind, table in pairs(game.database.table) do
    if not keep[kind] then
      table[self.id] = nil
    end
  end
end

return Entity.new
