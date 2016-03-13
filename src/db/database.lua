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

local Database = {}; Database.__index = Database
local Table = require('db.table')

-- Create a new database, which is a set of tables indexed by table type.
function Database.new()
  local self = {
    nextId = 0,
    table = {},
  }
  return setmetatable(self, Database)
end

-- Create a new table for the type, with the given kind constructor. If the
-- table already exists, the existing table is kept as-is, and this function
-- does nothing.
function Database:tableIs(kind)
  if not self.table[kind] then
    self.table[kind] = Table(kind)
  end
  return self.table[kind]
end

-- Create a new component ID
function Database:idIs()
  self.nextId = self.nextId+1
  return self.nextId
end

-- Delete all components associated with an ID
function Database:idDel(id)
  for i, table in pairs(self.table) do
    table[id] = nil
  end
end

return Database.new
