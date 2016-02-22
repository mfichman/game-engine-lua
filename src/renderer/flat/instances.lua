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

local asset = require('asset')
local gl = require('gl')
local struct = require('graphics.struct')
local graphics = require('graphics')

-- FIXME: Steal the drawInstances function from the deferred renderer, so that
-- we don't have to re-implement it for shadows. Ultimately, geom draw
-- functions should be located in a convenient place. StreamDrawBuffer.draw
-- probably belongs there, too.
local deferred = require('renderer.deferred.instances')

local program, white, blue

local function render(g, instances)
  if instances.model.material.opacity < 1 then return end
  if not instances:visible() then return end

  program = program or asset.open('shader/flat/Instances.prog')
  white = white or asset.open('texture/White.png')
  blue = blue or asset.open('texture/Blue.png')

  gl.glUseProgram(program.id)

  -- Draw the instances
  deferred.drawInstances(instances)
end

return {
  render=render,
}
