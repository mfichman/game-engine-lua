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

local debug = require('debug')

local counter = {}
local name = {}

local function hook()
  local func = debug.getinfo(2, 'f').func
  if not counter[func] then
    counter[func] = 1
    name[func] = debug.getinfo(2, 'Sn')
  else
    counter[func] = counter[func] + 1
  end
end

local function start()
  debug.sethook(hook, '', 1000)
end

local function stop()
  debug.sethook()
end

local function funcname(func)
  local info = name[func]
  if info.what == 'C' then
    return info.name
  end
  local loc = string.format('[%s]:%s', info.short_src, info.linedefined)
  if info.namewhat ~= '' then
    return string.format('%s (%s)', loc, info.name)
  else
    return string.format('%s', loc)
  end
end

local function show()
  local item = {}
  for func, counter in pairs(counter) do
    table.insert(item, {func=func, counter=counter})
  end 
  table.sort(item, function(a, b) return a.counter < b.counter end)
  for i, item in ipairs(item) do
    print(funcname(item.func), item.counter)
  end
end

return {
  start = start,
  stop = stop,
  counter = counter,
  name = name,
  show = show,
}
