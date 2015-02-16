-- ========================================================================== --
--                                                                            --
-- Copyright (c) 2015 Matt Fichman <matt.fichman@gmail.com>                   --
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
local sfml = require('sfml')
local game = require('game')
local gamemath = require('gamemath')
local graphics = require('graphics')
local vec = require('vec')

local viewport = vec.Vec2(config.display.width, config.display.height)
local camera = graphics.Camera{
  viewport = viewport,
  mode = 'ortho',
  top = 0,
  bottom = 1,
  left = 0,
  right = viewport.width/viewport.height,
  far = 0,
  near = 1,
}

camera:update()

-- Render each component by submitting it to the graphics pipeline. Then,
-- render all child components, if present.
local function render(component)
  if component.node then
    graphics.context:submit(component.node, camera, component.transform)
  end 
  if component.component then
    for i, v in ipairs(component.component) do
      render(v) 
    end
  end
end

-- Traverse through all the components and fire click events for components
-- that intersect with the mouse position.
local function click(component)
  local screen = sfml.Mouse_getPosition(game.window)
  local position = gamemath.screenToWorld(camera, screen)

  if component.click then
    if position.x > component.position.x and 
       position.y > component.position.y and
       position.x < component.position.x+component.size.x and
       position.y < component.position.y+component.size.y then

      component:click()
    end
  end
  if component.component then
    for i, v in ipairs(component.component) do
      click(v) 
    end
  end
end

return {
  Component = require('ui.component'),
  Composite = require('ui.composite'),
  Panel = require('ui.panel'),
--  Button = require('ui.button'),
  Image = require('ui.image'),
  Label = require('ui.label'),
  ItemIcon = require('ui.itemicon'),
  Grid = require('ui.grid'),
  ItemBox = require('ui.itembox'),
  TitleBox = require('ui.titlebox'),
  render = render,
  click = click,
  camera = camera,
}
