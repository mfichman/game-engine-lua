local ffi = require('ffi')
local path = require('path')


local window = ffi.load('csfml-window', true)
local graphics = ffi.load('csfml-graphics', true)
local system = ffi.load('csfml-system', true)

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
  function mt.__gc(t)
    return t:destroy()
  end

  local t = ffi.metatype(ffi.typeof(class), mt)
  return function(...)
    return symbol(ctor)(...)
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


return setmetatable(m, {__index=index})
