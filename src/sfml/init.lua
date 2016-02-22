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

local ffi = require('ffi')
local path = require('path')

local window = path.load('csfml-window')
local graphics = path.load('csfml-graphics')
local system = path.load('csfml-system')

ffi.cdef(path.open('sfml/sfml-window.h'):read('*all'))
ffi.cdef(path.open('sfml/sfml-graphics.h'):read('*all'))
ffi.cdef(path.open('sfml/sfml-system.h'):read('*all'))

local cache = {}

local function symbol(name)
  local ok, ret = pcall(function() return window[name] end)
  if ok then return ret end
  local ok, ret = pcall(function() return graphics[name] end)
  if ok then return ret end
  local ok, ret = pcall(function() return system[name] end)
  if ok then return ret end
  error('symbol not found: '..name)
end

local function index(t, k)
  local sym = cache[k]
  if not sym then
    sym = symbol(string.format('sf%s', k))
    cache[k] = sym
  end
  return sym
end

local function metatype(class, ctor)
  local mt = {}
  function mt.__index(t, k)
    return symbol(string.format('%s_%s', class, k))
  end

  local t = ffi.metatype(ffi.typeof(class), mt)
  return function(...)
    return ffi.gc(symbol(ctor)(...), t.destroy)
  end
end

local m = {}

m.Event = ffi.typeof('sfEvent')
m.VideoMode = ffi.typeof('sfVideoMode')
m.ContextSettings = ffi.typeof('sfContextSettings')
m.Clock = metatype('sfClock', 'sfClock_create')
m.Window = metatype('sfWindow', 'sfWindow_create')
m.Context = metatype('sfContext', 'sfContext_create')
m.Image = metatype('sfImage', 'sfImage_createFromFile')
m.Time = metatype('sfTime', nil)


return setmetatable(m, {__index = index})
