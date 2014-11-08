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

local Program = {}; Program.__index = Program

-- Create a new OpenGL program from a vertex, fragment, and optional geometry
-- shader; link the program
function Program.new(fragment, vertex, geometry) 
  local self = setmetatable({}, Program)
  self.id = gl.glCreateProgram()
  self.fragment = fragment
  self.vertex = vertex
  self.geometry = geometry
  self:link()
  return self
end

-- Return the program linker log
function Program:log()
  local length = ffi.new('int[1]')
  gl.glGetProgramiv(self.id, gl.GL_INFO_LOG_LENGTH, length)
  if length[0] > 0 then
    local log = ffi.new('char[?]', length[0])
    gl.glGetProgramInfoLog(self.id, length[0], length, log)
    return ffi.string(log)     
  end
end

-- Link the program
function Program:link()
  if self.fragment then gl.glAttachShader(self.id, self.fragment.id) end
  if self.vertex then gl.glAttachShader(self.id, self.vertex.id) end
  if self.geometry then gl.glAttachShader(self.id, self.geometry.id) end
  gl.glLinkProgram(self.id)

  local status = ffi.new('int[1]')
  gl.glGetProgramiv(self.id, gl.GL_LINK_STATUS, status)

  if status[0] == 0 then
    if self.fragment then io.write(self.fragment:log()) end
    if self.vertex then io.write(self.vertex:log()) end
    if self.geometry then io.write(self.geometry:log()) end
    io.write(self:log())
    error("error: link failed")
  end
end

-- Free up the program's resources
function Program:del()
  gl.glDeleteProgram(self.id)
  self.id = 0
end

-- Free up the program's resources
Program.__gc = Program.del

return Program.new
