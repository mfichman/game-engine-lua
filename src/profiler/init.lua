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
