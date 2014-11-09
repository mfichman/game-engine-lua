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

local RenderTarget = {}; RenderTarget.__index = RenderTarget

function RenderTarget.new(width, height, format)
  local self = setmetatable({}, RenderTarget)

  local id = ffi.new('GLint[1]')
  gl.glGenTextures(1, id)
  self.id = id[0]

  gl.glBindTexture(gl.GL_TEXTURE_2D, self.id)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP_TO_EDGE)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP_TO_EDGE)

  -- FIXME: Check for other depth component types
  if format == gl.GL_DEPTH_COMPONENT24 then
    gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, format, width, height, 0, gl.GL_DEPTH_COMPONENT, gl.GL_UNSIGNED_BYTE, nil)
  elseif format == gl.GL_DEPTH24_STENCIL8 then
    gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, format, width, height, 0, gl.GL_DEPTH_COMPONENT, gl.GL_UNSIGNED_BYTE, nil)
  else
    gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, format, width, height, 0, gl.GL_RGBA, gl.GL_UNSIGNED_BYTE, nil)
  end

  return self
end

function RenderTarget:del()
  local id = ffi.new('GLint[1]', self.id) 
  gl.glDeleteTextures(1, id)
  self.id = 0
end

RenderTarget.__gc = del

return RenderTarget.new
