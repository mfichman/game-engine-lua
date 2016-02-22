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
