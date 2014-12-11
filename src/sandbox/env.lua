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

local Env = {}

local global = {
  'assert', 'error', 'ipairs', 'pairs', 'next', 'pcall', 'print', 'select',
  'tonumber', 'tostring', 'type', 'xpcall',
}

local export = {
  'graphics', 'vec', 'rand', 'asset', 'db', 'math', 'string', 'table', 
}

-- Shallow copy of a table.
local function copy(table)
  local out = {}
  for k, v in pairs(table) do
    out[k] = v
  end
  return out
end

-- Replacement for the require() function that only allows packages to load if
-- they are in the 'package' array.
local function module(package, name) 
  if package[name] then
    return package[name]
  else
    error('package not found: '..name)
  end
end

-- Create a sandbox for mods that prevents a mod from clobbering either the 
-- game's environment or another mods' environment. Also, prevents the mod from 
-- accessing the user's computer (disk, network, etc.).
function Env.new()
  local self = {}
  local package = {}

  for _, name in ipairs(global) do
    self[name] = _G[name]
  end
  for _, name in ipairs(export) do
    package[name] = copy(require(name))
  end


  self.require = function(name) return module(package, name) end
  package.string.dump = nil  -- unsafe

  return self
end

return Env.new
