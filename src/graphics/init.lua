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

local config = require('config')
local vec = require('vec')

local Context = require('graphics.context')

local viewport = vec.Vec2(config.display.width, config.display.height)
local context = Context(viewport.width, viewport.height)

-- Render a graphics node with the given transform. Recursively render any
-- attached children as well.
local function render(node, camera, worldTransform)
  assert(camera.new == require('graphics.camera'))
  context:submit(node, camera, worldTransform)
end

-- Finish rendering the scene.
local function finish()
  context:finish()
end


return {
  Billboard = require('graphics.billboard'),
  Billboards = require('graphics.billboards'),
  Buffer = require('graphics.buffer'),
  Camera = require('graphics.camera'),
  Context = require('graphics.context'),
  DepthRenderTarget = require('graphics.depthrendertarget'),
  Font = require('graphics.font'),
  FrameBuffer = require('graphics.framebuffer'),
  HemiLight = require('graphics.hemilight'),
  Instance = require('graphics.instance'),
  Instances = require('graphics.instances'),
  Line = require('graphics.line'),
  Material = require('graphics.material'),
  Mesh = require('graphics.mesh'),
  Model = require('graphics.model'),
  Particle = require('graphics.particle'),
  Particles = require('graphics.particles'),
  PointLight = require('graphics.pointlight'),
  Program = require('graphics.program'),
  Quad = require('graphics.quad'),
  RenderTarget = require('graphics.rendertarget'),
  Ribbon = require('graphics.ribbon'),
  RibbonVertex = require('graphics.ribbonvertex'),
  Shader = require('graphics.shader'),
  SpotLight = require('graphics.spotlight'),
  StreamDrawBuffer = require('graphics.streamdrawbuffer'),
  Text = require('graphics.text'),
  Texture = require('graphics.texture'),
  Transform = require('graphics.transform'),
  context = context,
  render = render,
  finish = finish,
  viewport = viewport,
}
