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

local gl = require('gl')
local ffi = require('ffi')

local DepthRenderTarget = {}; DepthRenderTarget.__index = DepthRenderTarget

function DepthRenderTarget.new(width, height)
  local self = {
    width = width,
    height = height,
    id = 0,
    depthBuffer = 0,
  }
  setmetatable(self, DepthRenderTarget)

  local id = ffi.new('GLint[1]')
  
  -- Initialize texture, including filtering options
  gl.glGenTextures(1, id)
  self.depthBuffer = id[0]
  gl.glBindTexture(gl.GL_TEXTURE_2D, self.depthBuffer)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP_TO_EDGE)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP_TO_EDGE)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)

  -- Recommended by opengl.org -- Allows one to use sampler2DShadow, and thus
  -- get automatic depth comparison and PCF filtering.
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_COMPARE_MODE, gl.GL_COMPARE_REF_TO_TEXTURE)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_COMPARE_FUNC, gl.GL_LEQUAL)

  -- Establish texture size
  gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_DEPTH_COMPONENT24, width, height, 0, gl.GL_DEPTH_COMPONENT, gl.GL_FLOAT, nil);

  -- Generate and attach framebuffer
  gl.glGenFramebuffers(1, id)
  self.id = id[0]
  gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, self.id);
  gl.glFramebufferTexture2D(gl.GL_FRAMEBUFFER, gl.GL_DEPTH_ATTACHMENT, gl.GL_TEXTURE_2D, self.depthBuffer, 0)

  -- Check the status of the FBO
  self:enable()
  local status = gl.glCheckFramebufferStatus(gl.GL_FRAMEBUFFER)
  if gl.GL_FRAMEBUFFER_COMPLETE ~= status then
    error('couldn\'t create depth render target')
  end
  self:disable()

  return self
end

function DepthRenderTarget:del()
  local id = ffi.new('GLint[1]')
  id[0] = self.id
  gl.glDeleteFramebuffers(1, id)
  id[0] = self.depthBuffer
  gl.glDeleteTextures(1, id)
end

DepthRenderTarget.__gc = DepthRenderTarget.del

function DepthRenderTarget:enable()
  gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, self.id)
  gl.glDrawBuffer(gl.GL_NONE)
  gl.glReadBuffer(gl.GL_NONE)
end

function DepthRenderTarget:disable()
  gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0)
  gl.glDrawBuffer(gl.GL_BACK)
  gl.glReadBuffer(gl.GL_BACK)
end

return DepthRenderTarget.new
