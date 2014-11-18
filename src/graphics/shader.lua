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
local gl = require('gl')
local io = require('io')

local Shader = {}; Shader.__index = Shader

-- Create a new OpenGL shader 
function Shader.new(kind, source)
  local self = setmetatable({}, Shader)
  self.source = source
  self.kind = kind
  return self
end

-- Compile the shader
function Shader:compile()
  if self.id then return end
  self.id = gl.glCreateShader(self.kind)

  local cstr = ffi.new('GLchar[?]', self.source:len()+1)
  ffi.copy(cstr, self.source)

  local strings = ffi.new('GLchar*[1]', cstr) 
  local lengths = ffi.new('GLint[1]', self.source:len())
  gl.glShaderSource(self.id, 1, ffi.cast('GLchar const**', strings), lengths)
  gl.glCompileShader(self.id)

  local status = ffi.new('GLint[1]')
  gl.glGetShaderiv(self.id, gl.GL_COMPILE_STATUS, status)
  if status[0] == 0 then
    io.write(self:log())
  end
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

-- Free up the shader's resources
function Shader:del()
  gl.glDeleteShader(self.id)
  self.id = 0
end

Shader.__gc = Shader.del

return Shader.new
