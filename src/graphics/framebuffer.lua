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

local FrameBuffer = {}; FrameBuffer.__index = FrameBuffer

local MAXDRAWBUFFER = 8

-- Manages an offscreen frame buffer
function FrameBuffer.new() 
  local self = {
    drawBuffer = {},
    drawBufferAttachment = ffi.new('GLint[?]', MAXDRAWBUFFER),
    drawBufferAttachmentCount = 0,
    handle = gl.Handle(gl.glGenFramebuffers, gl.glDeleteFramebuffers),
    id = 0,
  }
  self.id = self.handle[0]
  return setmetatable(self, FrameBuffer)
end

function FrameBuffer:drawBufferEnq(target) 
  assert((#self.drawBuffer+1) < MAXDRAWBUFFER)
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
  gl.glFramebufferTexture2D(gl.GL_FRAMEBUFFER, gl.GL_STENCIL_ATTACHMENT, gl.GL_TEXTURE_2D,  target.id, 0)
  gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0) 
end

function FrameBuffer:check() 
  self:enable()
  assert(gl.GL_FRAMEBUFFER_COMPLETE == gl.glCheckFramebufferStatus(gl.GL_FRAMEBUFFER))
  gl.glDrawBuffers(self.drawBufferAttachmentCount, self.drawBufferAttachment)
  self:disable()
end

function FrameBuffer:enable()
  gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, self.id) 
end

function FrameBuffer:disable()
  gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0)
end

return FrameBuffer.new
