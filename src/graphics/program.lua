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
local gl = require('gl')

local Program = {}; Program.__index = Program

local function destroy(handle)
  gl.glDeleteProgram(handle[0]) 
end

-- Create a new OpenGL program from a vertex, fragment, and optional geometry
-- shader; link the program
function Program.new(fragment, vertex, geometry) 
  
  local self = {
    id = gl.glCreateProgram(),
    fragment = fragment,
    vertex = vertex,
    geometry = geometry,
    
    -- Uniform block bindings. 
    camera = 0, 
    transform = 1,
    material = 2,
    light = 3,
  }
  self.handle = ffi.gc(ffi.new('GLint[1]', self.id), destroy)
  if #{fragment, vertex, geometry} == 0 then
    error('no shaders attached to program')
  end
  setmetatable(self, Program)
  self:link()
  return self
end

-- Return the program linker log
function Program:log()
  local length = ffi.new('GLint[1]')
  gl.glGetProgramiv(self.id, gl.GL_INFO_LOG_LENGTH, length)
  if length[0] > 0 then
    local log = ffi.new('GLchar[?]', length[0])
    gl.glGetProgramInfoLog(self.id, length[0], length, log)
    return ffi.string(log)     
  end
end

-- Link the program
function Program:link()
  if self.fragment then 
    self.fragment:compile()
    gl.glAttachShader(self.id, self.fragment.id) 
  end
  if self.vertex then 
    self.vertex:compile()
    gl.glAttachShader(self.id, self.vertex.id) 
  end
  if self.geometry then 
    self.geometry:compile()
    gl.glAttachShader(self.id, self.geometry.id) 
  end
  gl.glLinkProgram(self.id)

  local status = ffi.new('GLint[1]')
  gl.glGetProgramiv(self.id, gl.GL_LINK_STATUS, status)

  if status[0] == 0 then
    if self.fragment then io.write(self.fragment:log()) end
    if self.vertex then io.write(self.vertex:log()) end
    if self.geometry then io.write(self.geometry:log()) end
    io.write(self:log())
    error("error: link failed")
  end

  local uniforms = ffi.new('GLint[1]')
  local maxlen = ffi.new('GLint[1]')
  gl.glGetProgramiv(self.id, gl.GL_ACTIVE_UNIFORMS, uniforms)
  gl.glGetProgramiv(self.id, gl.GL_ACTIVE_UNIFORM_MAX_LENGTH, maxlen)

  local size = ffi.new('GLint[1]')
  local kind = ffi.new('GLenum[1]')
  local buf = ffi.new('GLchar[?]', maxlen[0])
  for i = 0,uniforms[0]-1 do
    gl.glGetActiveUniform(self.id, i, maxlen[0], nil, size, kind, buf)
    local name = ffi.string(buf)
    self[name] = gl.glGetUniformLocation(self.id, buf)
  end

  local camera = gl.glGetUniformBlockIndex(self.id, 'camera')
  local transform = gl.glGetUniformBlockIndex(self.id, 'transform')
  local material = gl.glGetUniformBlockIndex(self.id, 'material')
  local light = gl.glGetUniformBlockIndex(self.id, 'light')

  if camera ~= gl.GL_INVALID_INDEX then
    gl.glUniformBlockBinding(self.id, camera, self.camera)
  end
  if transform ~= gl.GL_INVALID_INDEX then
    gl.glUniformBlockBinding(self.id, transform, self.transform)
  end
  if material ~= gl.GL_INVALID_INDEX then
    gl.glUniformBlockBinding(self.id, material, self.material)
  end
  if light ~= gl.GL_INVALID_INDEX then
    gl.glUniformBlockBinding(self.id, light, self.light)
  end
end

return Program.new
