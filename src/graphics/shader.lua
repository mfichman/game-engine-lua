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
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, APEXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

local ffi = require('ffi')
local gl = require('gl')
local io = require('io')

local Shader = {}; Shader.__index = Shader

-- Create a new OpenGL shader 
function Shader.new(name, kind)
  local self = setmetatable({}, Shader)
  self.name = name
  self.id = gl.glCreateShader(kind)
  self:compile()
  return self
end

-- Compile the shader
function Shader:compile()
  local fd = io.open(self.name)
  if not fd then error('file not found: '..self.name) end

  local source = fd:read('*all')
  fd:close()
  cstr = ffi.new('char[?]', source:len()+1)
  ffi.copy(cstr, source)

  local strings = ffi.new('GLchar*[1]', cstr) 
  local lengths = ffi.new('GLint[1]', source:len())
  gl.glShaderSource(self.id, 1, strings, lengths)
  gl.glCompileShader(self.id)
end

-- Return the shader log
function Shader:log()
  local length = ffi.new('int[1]')
  gl.glGetShaderiv(self.id, gl.GL_INFO_LOG_LENGTH, length)
  if length[0] > 0 then
    local log = ffi.new('char[?]', length[0])
    gl.glGetShaderInfoLog(self.id, length[0], length, log)
    return ffi.string(log)     
  end
end

return Shader.new
