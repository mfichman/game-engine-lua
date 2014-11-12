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
local bit = require('bit')

local DeferredRenderer = {}; DeferredRenderer.__index = DeferredRenderer
local FrameBuffer = require('graphics.framebuffer')
local RenderTarget = require('graphics.rendertarget')
local Context = require('graphics.context')
local Model = require('graphics.model')

local model = require('graphics.renderer.deferred.model')
local hemilight = require('graphics.renderer.deferred.hemilight')
--[[
local spotlight = require('graphics.renderer.deferred.spotlight')
local pointlight = require('graphics.renderer.deferred.pointlight')
local decal = require('graphics.renderer.deferred.decal')
local shadow = require('graphics.renderer.shadow')

local skybox = require('graphics.renderer.forward.skybox')
local transparent = require('graphics.renderer.forward.transparent')
local particles = require('graphics.renderer.forward.particles')
local ribbon = require('graphics.renderer.forward.ribbon')
local billboards = require('graphics.renderer.forward.billboards')
local quad = require('graphics.renderer.forward.quad')
local text = require('graphics.renderer.forward.text')
local ui = require('graphics.renderer.forward.ui')
]]

function DeferredRenderer.new(camera)
  assert(camera, 'no camera set')
  local self = setmetatable({}, DeferredRenderer)

  local width, height = camera.viewportWidth, camera.viewportHeight
  self.diffuseBuffer = RenderTarget(width, height, gl.GL_RGB)
  self.specularBuffer = RenderTarget(width, height, gl.GL_RGBA)
  self.normalBuffer = RenderTarget(width, height, gl.GL_RGB16F)
  self.emissiveBuffer = RenderTarget(width, height, gl.GL_RGB)
  self.depthBuffer = RenderTarget(width, height, gl.GL_DEPTH24_STENCIL8)
  self.finalBuffer = RenderTarget(width, height, gl.GL_RGBA)

  -- Buffer order is important below! The 0th draw buffer corresponds to the
  -- 1st texture in the lighting pass, and to the 0th output of the pixel 
  -- shaders in the material pass. 
  self.frameBuffer = FrameBuffer()
  self.frameBuffer:drawBufferEnq(self.diffuseBuffer)
  self.frameBuffer:drawBufferEnq(self.specularBuffer)
  self.frameBuffer:drawBufferEnq(self.normalBuffer)
  self.frameBuffer:drawBufferEnq(self.emissiveBuffer)
  self.frameBuffer:depthBufferIs(self.depthBuffer)
  self.frameBuffer:stencilBufferIs(self.depthBuffer)
  self.frameBuffer:check() 

  self.decalFrameBuffer = FrameBuffer()
  self.decalFrameBuffer:drawBufferEnq(self.diffuseBuffer)
  self.decalFrameBuffer:depthBufferIs(self.depthBuffer)
  self.decalFrameBuffer:check()

  self.finalFrameBuffer = FrameBuffer()
  self.finalFrameBuffer:drawBufferEnq(self.finalBuffer)
  self.finalFrameBuffer:depthBufferIs(self.depthBuffer)
  self.finalFrameBuffer:stencilBufferIs(self.depthBuffer)
  self.finalFrameBuffer:check()

  self.context = Context(camera)
  
  return self
end

function DeferredRenderer:apply(render, kind, scene)
end

function DeferredRenderer:render(scene)
  -- Pass 0: Render shadow maps
--[[
  shadow.render(scene)
]]

  -- Pass 1: Write material properties into the material G-Buffers

  -- Mark a bit in the stencil buffer whenever a pixel is written during the
  -- material pass, so that we can use the stencil mask later.
  gl.glEnable(gl.GL_STENCIL_TEST)
  gl.glStencilFunc(gl.GL_ALWAYS, 1, 0xff) -- disable stencil masking: pass all pixels
  gl.glStencilOp(gl.GL_KEEP, gl.GL_KEEP, gl.GL_INCR) -- increment bit
  gl.glStencilMask(0xff) -- disable stencil masking: pass all pixels

  -- Pass 1a: Write material properties in to the material G-Buffers
  self.frameBuffer:enable()
  gl.glClear(bit.bor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT, gl.GL_STENCIL_BUFFER_BIT))
  self:apply(model.render, scene, Model)
  self.frameBuffer:disable()

  -- In passes 1b/2, only write to pixels that were previously written to in
  -- pass 1.  Skip/discard all other fragments early.
  gl.glStencilFunc(gl.GL_LEQUAL, 1, 0xff) -- pass fragments that have a bit in the stenci
  gl.glStencilOp(gl.GL_KEEP, gl.GL_KEEP, gl.GL_KEEP) -- do not update stencil
  gl.glStencilMask(0) -- do not update the stencil

  -- Pass 1b: Project decals into diffuse buffer
--[[ FIXME
  self.decalFrameBuffer:enable()
  gl.glActiveTexture(gl.GL_TEXTURE4)
  gl.glBindTexture(gl.GL_TEXTURE_2D, self.depthBuffer.id)
  self:apply(decal.render, scene, Decals)
  self.decalFrameBuffer:disable()
]]

  self.finalFrameBuffer:enable()
  gl.glClear(gl.GL_COLOR_BUFFER_BIT)
  gl.glDepthMask(gl.GL_FALSE) -- disable depth writes for alpha passes below
  
  -- Pass 2: Render lighting using light bounding boxes
  gl.glActiveTexture(gl.GL_TEXTURE0)
  gl.glBindTexture(gl.GL_TEXTURE_2D, self.diffuseBuffer.id)
  gl.glActiveTexture(gl.GL_TEXTURE1)
  gl.glBindTexture(gl.GL_TEXTURE_2D, self.specularBuffer.id)
  gl.glActiveTexture(gl.GL_TEXTURE2)
  gl.glBindTexture(gl.GL_TEXTURE_2D, self.normalBuffer.id)
  gl.glActiveTexture(gl.GL_TEXTURE3)
  gl.glBindTexture(gl.GL_TEXTURE_2D, self.emissiveBuffer.id)
  gl.glActiveTexture(gl.GL_TEXTURE4)
  gl.glBindTexture(gl.GL_TEXTURE_2D, self.depthBuffer.id)
  self:apply(hemilight.render, scene, HemiLight)
  --self:apply(spotlight.render, scene, SpotLight) FIXME
  --self:apply(pointlight.render, scene, PointLight) FIXME

  -- Pass 3: Skybox
  gl.glStencilFunc(gl.GL_EQUAL, 0, 0xff) -- pass fragments with zero stencil value
  --self:apply(skybox.render, scene, Skybox) FIXME

  gl.glDisable(gl.GL_STENCIL_TEST) -- ignore stencil for UI/particles

  -- Pass 4: Render transparent objects
  --self:apply(transparent.render, scene, Model) FIXME
  --self:apply(particles.render, scene, Particles)
  --self:apply(ribbon.render, scene, Ribbon)
  --self:apply(billboards.render, scene, Billboards)
  --self:apply(quad.render, scene, Quad)
  --self:apply(text.render, scene, Text)
  --alphaPass_->operator()(scene)

  -- Pass 5: Text/UI rendering...?
  --self:apply(ui.render, scene, Ui) FIXME

  self.finalFrameBuffer:disable()
  gl.glDepthMask(gl.GL_TRUE)

  -- Blit final framebuf to screen
  local width = self.context.camera.viewportWidth
  local height = self.context.camera.viewportHeight
  gl.glBindFramebuffer(gl.GL_READ_FRAMEBUFFER, self.finalFrameBuffer.id)
  gl.glBlitFramebuffer(0, 0, width, height, 0, 0, width, height, gl.GL_COLOR_BUFFER_BIT, gl.GL_NEAREST)
  gl.glBindFramebuffer(gl.GL_READ_FRAMEBUFFER, 0)
end

return DeferredRenderer.new
