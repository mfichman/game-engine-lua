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

local Table = {}; 

-- Creates a new table to hold structures of the given type.
function Table.new(kind)
  local self = {}
  self.component = {}
  self.kind = kind
  return setmetatable(self, Table)
end

-- Index into the component table
function Table:__newindex(id, data)
  if data then
    self.component[id] = self.kind(id, data)
  else
    local component = self.component[id]
    if type(component) == 'table' and component.del then
      component:del(id)
    end
    self.component[id] = nil
  end
end

-- Index into the component table
function Table:__index(id)
  return self.component[id]
end

return Table.new
