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

local gl = require('gl')
local bit = require('bit')
local graphics = require('graphics')
local apply = require('renderer.apply')

local Deferred = {}; Deferred.__index = Deferred
local Shadow = require('renderer.shadow')

local model = require('renderer.deferred.model')
local instances = require('renderer.deferred.instances')
local hemilight = require('renderer.deferred.hemilight')
local pointlight = require('renderer.deferred.pointlight')
local spotlight = require('renderer.deferred.spotlight')
local particles = require('renderer.forward.particles')
local billboards = require('renderer.forward.billboards')
local ribbon = require('renderer.forward.ribbon')
local text = require('renderer.forward.text')
local quad = require('renderer.forward.quad')
--[[
local decal = require('renderer.deferred.decal')
local skybox = require('renderer.forward.skybox')
local transparent = require('renderer.forward.transparent')
]]

function Deferred.new(context)
  local width, height = context.viewport.width, context.viewport.height
  local self = {
    context = context,
    diffuseBuffer = graphics.RenderTarget(width, height, gl.GL_RGB),
    specularBuffer = graphics.RenderTarget(width, height, gl.GL_RGBA),
    normalBuffer = graphics.RenderTarget(width, height, gl.GL_RGB16F),
    emissiveBuffer = graphics.RenderTarget(width, height, gl.GL_RGB),
    depthBuffer = graphics.RenderTarget(width, height, gl.GL_DEPTH24_STENCIL8),
    finalBuffer = graphics.RenderTarget(width, height, gl.GL_RGBA),
    frameBuffer = graphics.FrameBuffer(),
    decalFrameBuffer = graphics.FrameBuffer(),
    finalFrameBuffer = graphics.FrameBuffer(),
    shadow = Shadow(context),
  }

  -- Buffer order is important below! The 0th draw buffer corresponds to the
  -- 1st texture in the lighting pass, and to the 0th output of the pixel 
  -- shaders in the material pass. 
  self.frameBuffer:drawBufferEnq(self.diffuseBuffer)
  self.frameBuffer:drawBufferEnq(self.specularBuffer)
  self.frameBuffer:drawBufferEnq(self.normalBuffer)
  self.frameBuffer:drawBufferEnq(self.emissiveBuffer)
  self.frameBuffer:depthBufferIs(self.depthBuffer)
  self.frameBuffer:stencilBufferIs(self.depthBuffer)
  self.frameBuffer:check() 

  self.decalFrameBuffer:drawBufferEnq(self.diffuseBuffer)
  self.decalFrameBuffer:depthBufferIs(self.depthBuffer)
  self.decalFrameBuffer:check()

  self.finalFrameBuffer:drawBufferEnq(self.finalBuffer)
  self.finalFrameBuffer:depthBufferIs(self.depthBuffer)
  self.finalFrameBuffer:stencilBufferIs(self.depthBuffer)
  self.finalFrameBuffer:check()

  return setmetatable(self, Deferred)
end

function Deferred:render()
  -- Pass 0: Render shadow maps
  self.shadow:render()

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
  apply.apply(model.render, self.context, graphics.Model)
  apply.apply(instances.render, self.context, graphics.Instances)
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
  apply.apply(decal.render, self.context, Decals)
  self.decalFrameBuffer:disable()
]]

  self.finalFrameBuffer:enable()
  gl.glClear(gl.GL_COLOR_BUFFER_BIT)
  gl.glDisable(gl.GL_STENCIL_TEST) -- ignore stencil for UI/particles

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
  apply.apply(hemilight.render, self.context, graphics.HemiLight)
  apply.apply(spotlight.render, self.context, graphics.SpotLight)
  apply.apply(pointlight.render, self.context, graphics.PointLight)

  -- Pass 3: Skybox
  gl.glStencilFunc(gl.GL_EQUAL, 0, 0xff) -- pass fragments with zero stencil value
  --apply.apply(skybox.render, self.context, graphics.Skybox) FIXME

  gl.glDisable(gl.GL_STENCIL_TEST) -- ignore stencil for UI/particles

  -- Pass 4: Render transparent objects
  --self:apply(transparent.render, graphics.Model) FIXME
  apply.apply(particles.render, self.context, graphics.Particles)
  apply.apply(billboards.render, self.context, graphics.Billboards)
  apply.apply(ribbon.render, self.context, graphics.Ribbon)
  apply.apply(text.render, self.context, graphics.Text)
  apply.apply(quad.render, self.context, graphics.Quad)

  -- Pass 5: Text/UI rendering...?
  --self:apply(ui.render, graphics.Ui) FIXME

  self.finalFrameBuffer:disable()
  gl.glDepthMask(gl.GL_TRUE)

  -- Blit final framebuf to screen
  local width = self.context.viewport.width
  local height = self.context.viewport.height
  gl.glBindFramebuffer(gl.GL_READ_FRAMEBUFFER, self.finalFrameBuffer.id)
  gl.glBlitFramebuffer(0, 0, width, height, 0, 0, width, height, gl.GL_COLOR_BUFFER_BIT, gl.GL_NEAREST)
  gl.glBindFramebuffer(gl.GL_READ_FRAMEBUFFER, 0)
end

return Deferred.new
