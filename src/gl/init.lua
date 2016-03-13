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
local package = require('package')
local path = require('path')

local glew, opengl
ffi.cdef(path.open('gl/glenum.h'):read('*all'))

if ffi.os == 'Windows' then
  glew = require('glew')
  opengl = path.load('opengl32')
else
  ffi.cdef(path.open('gl/gl.h'):read('*all'))
end


local function symbol(name)
  local ok, ret = pcall(function() return ffi.C[name] end)
  if ok then return ret end
  local ok, ret = pcall(function() return opengl[name] end)
  if ok then return ret end
  local name = name:gsub('^gl', '__glew')
  local ok, ret = pcall(function() return glew[name] end)
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

-- Initialize a new handle using the given handle creation function.  Wrap the
-- handle in a gc object, so that it's GC'd when no longer referenced
local function Handle(gen, delete)
  local id = ffi.new('GLint[1]') 
  gen(1, id)
  return ffi.gc(id, function(id) delete(1, id) end)
end

local m = {
  Handle = Handle,
  GL_TIMEOUT_IGNORED = 0xffffffffffffffff,
}

return setmetatable(m, {__index = index})


