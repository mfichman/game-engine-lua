local ffi = require('ffi')
local window = ffi.load('csfml-window')
local graphics = ffi.load('csfml-graphics')

ffi.cdef(io.open('sfml/sfml-window.h'):read('*all'))
ffi.cdef(io.open('sfml/sfml-graphics.h'):read('*all'))

local function index(t, k)
  local n = string.format('sf%s', k)
  local ok, ret = pcall(function() return window[n] end)
  if ok then return ret end
  local ok, ret = pcall(function() return graphics[n] end)
  if ok then return ret end
end

local function metatype(class, ctor)
  local mt = {}
  function mt.__index(t, k)
    local n = string.format('%s_%s', class, k)
    local ok, ret = pcall(function() return window[n] end)
    if ok then return ret end
    local ok, ret = pcall(function() return graphics[n] end)
    if ok then return ret end
  end

  local t = ffi.metatype(ffi.typeof(class), mt)
  return function(...)
    local ok, ret = pcall(function() return window[ctor] end)
    if ok then return ret(...) end
    local ok, ret = pcall(function() return graphics[ctor] end)
    if ok then return ret(...) end
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
