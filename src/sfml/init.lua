local ffi = require('ffi')
local sfml = ffi.load('csfml-window')

ffi.cdef(io.open('sfml/sfml.h'):read('*all'))

local function index(t, k)
  return sfml[string.format('sf%s', k)]
end

local function metatype(class)
  local mt = {}
  function mt.__index(t, k)
    return sfml[string.format('%s_%s', class, k)]
  end

  local t = ffi.metatype(ffi.typeof(class), mt)
  return function(...)
    return sfml[string.format('%s_create', class)](...)
  end
end

local m = {}

m.Event = ffi.typeof('sfEvent')
m.VideoMode = ffi.typeof('sfVideoMode')
m.ContextSettings = ffi.typeof('sfContextSettings')
m.Window = metatype('sfWindow')


return setmetatable(m, {__index=index})
