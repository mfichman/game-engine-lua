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

local ffi = require('ffi')
local package = require('package')
local path = require('path')

ffi.cdef(path.open('gl/gl.h'):read('*all'))
ffi.cdef(path.open('gl/glenum.h'):read('*all'))

local glew

if ffi.os == 'Windows' then
  ffi.load('glew', true)
end

local function symbol(name)
  local ok, ret = pcall(function() return ffi.C[name] end)
  if ok then return ret end
  local name = k:gsub('^gl', '__glew')
  local ok, ret = pcall(function() return ffi.C[name] end)
  if ok then return ret end
  error('symbol not found: '..name)
end

-- Look up the OpenGL function in the current executable first. If it's not
-- found, then look in libglew instead for the glew binding.
local function index(t, k)
    local fn = symbol(k)
    rawset(t, k, fn)
    return fn
end

--local glew = ffi.load('glew')
--local m = {}
--m.glewInit = glew.glewInit()
--ffi.cdef[[
--  int glewInit(void);
--]]

return setmetatable({}, {__index=index})
