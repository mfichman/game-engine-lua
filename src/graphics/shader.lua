-- ========================================================================== --
--                                                                            --
-- Copyright (c) 2014 Matt Fichman <matt.fichman@gmail.com>                   --
--                                                                            --
-- This file is part of Quadrant.  It is subject to the license terms in the  --
-- LICENSE.md file found in the top-level directory of this software package  --
-- and at http://github.com/mfichman/quadrant/blob/master/LICENSE.md.         --
-- No person may use, copy, modify, publish, distribute, sublicense and/or    --
-- sell any part of Quadrant except according to the terms contained in the   --
-- LICENSE.md file.                                                           --
--                                                                            --
-- ========================================================================== --

local ffi = require('ffi')
local gl = require('gl')
local io = require('io')

local Shader = {}; Shader.__index = Shader

local function destroy(handle)
  gl.glDeleteShader(handle[0]) 
end

-- Create a new OpenGL shader 
function Shader.new(kind, source)
  local self = {
    source = source,
    kind = kind,
  }
  return setmetatable(self, Shader)
end

-- Compile the shader
function Shader:compile()
  if self.id then return end
  self.id = gl.glCreateShader(self.kind)
  self.handle = ffi.gc(ffi.new('GLint[1]', self.id), destroy)

  local cstr = ffi.new('GLchar[?]', self.source:len()+1)
  ffi.copy(cstr, self.source)

  local strings = ffi.new('GLchar const *[1]', cstr) 
  local lengths = ffi.new('GLint[1]', self.source:len())
  gl.glShaderSource(self.id, 1, strings, lengths)
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

return Shader.new
