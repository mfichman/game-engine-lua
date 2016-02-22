-- Copyright (c) 2016 Matt Fichman
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
