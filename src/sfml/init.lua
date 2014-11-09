local ffi = require('ffi')
local path = require('path')
local window = ffi.load('csfml-window')
local graphics = ffi.load('csfml-graphics')

ffi.cdef(path.open('sfml/sfml-window.h'):read('*all'))
ffi.cdef(path.open('sfml/sfml-graphics.h'):read('*all'))

local function symbol(name)
  local ok, ret = pcall(function() return window[name] end)
  if ok then return ret end
  local ok, ret = pcall(function() return graphics[name] end)
  if ok then return ret end
  error('symbol not found: '..name)
end

local function index(t, k)
  return symbol(string.format('sf%s', k))
end

local function metatype(class, ctor)
  local mt = {}
  function mt.__index(t, k)
    return symbol(string.format('%s_%s', class, k))
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
m.Window = metatype('sfWindow', 'sfWindow_create')
m.Context = metatype('sfContext', 'sfContext_create')
m.Image = metatype('sfImage', 'sfImage_createFromFile')


return setmetatable(m, {__index=index})
