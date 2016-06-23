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

local function kind(data)
  -- Get the kind of a component from a component data spec
  local spec = data[1]
  return (type(spec) == 'function') and spec or component[spec]
end

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
    self:componentIs(data)
    keep[kind(data)] = true
  end
  for kind, table in pairs(game.database.table) do
    if not keep[kind] then
      table[self.id] = nil
    end
  end
end

-- Add a component to the entity by making an entry in the relevant table for
-- the specified kind of component.
function Entity:componentIs(data)
  local kind = kind(data)
  local table = game.database:tableIs(kind)
  if not table[self.id] then
    table[self.id] = data
  end
end

return Entity.new
