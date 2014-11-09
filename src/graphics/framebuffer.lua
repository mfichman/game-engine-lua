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

local FrameBuffer = {}; FrameBuffer.__index = FrameBuffer

local MAXDRAWBUFFER = 8

-- Manages an offscreen frame buffer
function FrameBuffer.new() 
  local self = setmetatable({}, FrameBuffer)
  self.status = 'disabled'
  self.drawBuffer = {}
  self.drawBufferAttachment = ffi.new('GLint[?]', MAXDRAWBUFFER)
  self.drawBufferAttachmentCount = 0

  local id = ffi.new('GLint[1]')
  gl.glGenTextures(1, id)
  self.id = id[0]
  
  return self
end

function FrameBuffer:drawBufferEnq(target) 
  local attachment = gl.GL_COLOR_ATTACHMENT0 + #self.drawBuffer
  table.insert(self.drawBuffer, target)
  self.drawBufferAttachment[self.drawBufferAttachmentCount] = attachment
  self.drawBufferAttachmentCount = self.drawBufferAttachmentCount + 1
  
  gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, self.id)
  gl.glFramebufferTexture2D(gl.GL_FRAMEBUFFER, attachment, gl.GL_TEXTURE_2D, target.id, 0)
  gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0)
end

function FrameBuffer:depthBufferIs(target)
  assert(not self.depthBuffer, 'depth buffer already attached')
  self.depthBuffer = target

  gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, self.id)
  gl.glFramebufferTexture2D(gl.GL_FRAMEBUFFER, gl.GL_DEPTH_ATTACHMENT, gl.GL_TEXTURE_2D, target.id, 0)
  gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0)
end

function FrameBuffer:stencilBufferIs(target)
  assert(not self.stencilBuffer, 'stencil buffer already attached')
  self.stencilBuffer = target

  gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, self.id)
  gl.glFramebufferTexture2D(gl.GL_FRAMEBUFFER, gl.GL_STENCIL_ATTACHMENT, gl.GL_TEXTURE_2D,  self.id)
  gl.glBindFramebuffer(gl.GL_FRAEMEBUFFER, 0) 
end

function FrameBuffer:check() 
  self:statusIs('enabled')
  assert(gl.GL_FRAMEBUFFER_COMPLETE ~= gl.glCheckFramebufferStatus(gl.GL_FRAMEBUFFER))
  self:statusIs('disabled')
end

function FrameBuffer:statusIs(status)
  if self.status == status then return end
  self.status = status
  if status == 'enabled' then
    gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, self.id) 
    gl.glDrawBuffers(self.drawBufferAttachmentCount, self.drawBufferAttachment)
  elseif status == 'disabled' then
    gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0)
  else
    assert(not 'invalid enum')    
  end
end

function FrameBuffer:del()
  local id = ffi.new('GLint[1]', self.id) 
  gl.glDeleteTextures(1, id)
  self.id = 0
end

FrameBuffer.__gc = del

return FrameBuffer.new
