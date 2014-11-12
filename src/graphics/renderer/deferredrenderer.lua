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

local gl = require('gl')
local bit = require('bit')

local DeferredRenderer = {}; DeferredRenderer.__index = DeferredRenderer
local FrameBuffer = require('graphics.framebuffer')
local RenderTarget = require('graphics.rendertarget')
local Context = require('graphics.context')
local Model = require('graphics.model')

local model = require('graphics.renderer.deferred.model')
--[[
local shadow = require('graphics.renderer.shadow')
local light = require('graphics.renderer.light')
local alpha = require('graphics.renderer.alpha')
local skybox = require('graphics.renderer.skybox')
local ui = require('graphics.renderer.ui')
local decal = require('graphics.renderer.decal')
]]

function DeferredRenderer.new(camera)
  assert(camera, 'no camera set')
  local self = setmetatable({}, DeferredRenderer)

  local width, height = camera.viewportWidth, camera.viewportHeight
  self.diffuseBuffer = RenderTarget(width, height, gl.GL_RGB)
  self.specularBuffer = RenderTarget(width, height, gl.GL_RGBA)
  self.normalBuffer = RenderTarget(width, height, gl.GL_RGB16F)
  self.emissiveBuffer = RenderTarget(width, height, gl.GL_RGB)
  self.depthBuffer = RenderTarget(width, height, gl.GL_DEPTH_COMPONENT24)

  -- Buffer order is important below! The 0th draw buffer corresponds to the
  -- 1st texture in the lighting pass, and to the 0th output of the pixel 
  -- shaders in the material pass. 
  self.frameBuffer = FrameBuffer()
  self.frameBuffer:drawBufferEnq(self.diffuseBuffer)
  self.frameBuffer:drawBufferEnq(self.specularBuffer)
  self.frameBuffer:drawBufferEnq(self.normalBuffer)
  self.frameBuffer:drawBufferEnq(self.emissiveBuffer)
  self.frameBuffer:depthBufferIs(self.depthBuffer)
  self.frameBuffer:check() 

  self.decalFrameBuffer = FrameBuffer()
  self.decalFrameBuffer:drawBufferEnq(self.diffuseBuffer)
  self.decalFrameBuffer:check()

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

  -- Enable writes to the stencil buffer. This writes a bit in the stencil
  -- buffer every time a fragment is output to the G-Buffers.
--[[
  gl.glEnable(gl.GL_STENCIL_TEST)
  gl.glStencilFunc(gl.GL_ALWAYS, 0, 0) -- ignore stencil test
  gl.glStencilOp(gl.GL_KEEP, gl.GL_KEEP, gl.GL_INCR) -- write to stencil
  gl.glStencilMask(0xff) -- enable all stencil bits
]]

  -- Pass 1a: Write material properties in to the material G-Buffers
  self.frameBuffer:enable()
  gl.glClear(bit.bor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT, gl.GL_STENCIL_BUFFER_BIT))
  self:apply(model.render, Model, scene)
  self.frameBuffer:disable()

  -- FIXME: Using the stencil to discard fragments not present in the G-buffer
  -- doesn't seem to make much of a performance difference. In most cases,
  -- the screen is almost entirely filled with pixels lit by the sun, so the
  -- stencil buffer is almost completely filled. Need to investigate further
  -- whether the stencil test is actually working as intended.
  --
  -- FIXME: Early stencil test only works if pixel shaders DO NOT write to the
  -- depth buffer. Thus, this code does nothing until the light fragment shaders
  -- are fixed to not write gl_FragDepth
  --
  -- FIXME FIXME: Render to a different color buffer, using this depth buffer,
  -- and disable depth writes in the final pass? Might be faster
  --
  -- Copy the stencil from the FBO to the back buffer so that we can use it
--[[
  local width = self.context.camera.viewportWidth
  local height = self.context.camera.viewportHeight
  gl.glBindFramebuffer(gl.GL_READ_FRAMEBUFFER, self.frameBuffer.id)
  gl.glBlitFramebuffer(0, 0, width, height, gl.GL_STENCIL_BUFFER, gl.GL_NEAREST)
  gl.glBindFramebuffer(gl.GL_READ_FRAMEBUFFER, 0)
]]

  -- Set up stencil buffer to skip any pixels not written to in the the
  -- material pass (Pass 1)
--[[
  gl.glStencilFunc(gl.GL_LEQUAL, 1, 0xff) -- pass if stencil is nonzero
  gl.glStencilOp(gl.GL_KEEP, gl.GL_KEEP, gl.GL_KEEP) -- do not update the stencil
  gl.StencilMask(0) -- do not update the stencil
]]

  -- Pass 1b: Project decals into diffuse buffer
--[[
  self.decalFrameBuffer:enable()
  gl.glActiveTexture(gl.GL_TEXTURE4) -- Must be same as used in shaders!
  gl.glBindTexture(gl.GL_TEXTURE_2D, self.depthBuffer.id)
  decal.render(context, scene)
  self.decalFrameBuffer:disable()
]]

  -- Pass 2: Render lighting using light shapes and data from G-Buffers
  gl.glActiveTexture(gl.GL_TEXTURE0)
  gl.glBindTexture(gl.GL_TEXTURE2D, self.diffuseBuffer.id)
  gl.glActiveTexture(gl.GL_TEXTURE1)
  gl.glBindTexture(gl.GL_TEXTURE2D, self.specularBuffer.id)
  gl.glActiveTexture(gl.GL_TEXTURE2)
  gl.glBindTexture(gl.GL_TEXTURE2D, self.normalBuffer.id)
  gl.glActiveTexture(gl.GL_TEXTURE3)
  gl.glBindTexture(gl.GL_TEXTURE2D, self.emissiveBuffer.id)
  gl.glActiveTexture(gl.GL_TEXTURE4)
  gl.glBindTexture(gl.GL_TEXTURE2D, self.depthBuffer.id)
  light.render(context, scene)

  -- Reverse test for skybox: Only pass pixels that WERE NOT written in the
  -- material pass (Pass 1a)
--[[
  gl.glStencilFunc(GL_EQUAL, 0, 0xff)
]]

  -- Pass 3: Skybox
--[[
  skybox.render(context, scene) 
]]

  -- Disable stencil for rendering transparent objects, so that we can write 
  -- to pixels that do not overlap the pixels written in the material pass.
--[[
  gl.glDisable(gl.GL_STENCIL_TEST)
]]

  -- Pass 4: Transparent objects 
--[[
  alpha.render(context, scene)
]]

  -- Pass 5: Ui
--[[
  ui.render(context, scene)
]]
end

return DeferredRenderer.new
