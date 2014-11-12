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

local graphics = require('graphics')
local string = require('string')
local io = require('io')
local gl = require('gl')
local path = require('path')

local include, open

function include(path)
  return open(path).source
end

function open(name)
  local ext = string.match(name, '([^%.]+)$')
  local kind 
  if ext == 'frag' then
    kind = gl.GL_FRAGMENT_SHADER 
  elseif ext == 'vert' then
    kind = gl.GL_VERTEX_SHADER 
  elseif ext == 'geom' then
    kind = gl.GL_GEOMETRY_SHADER 
  else
    error('bad shader filetype: '..name) 
  end

  local fd = path.open(name)
  local source = fd:read('*all')
  source = source:gsub('#pragma%s+include%s+"(.*)"', include)
  fd:close()
  return graphics.Shader(kind, source)
end

return {
  open=open
}
