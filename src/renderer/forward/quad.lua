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

local asset = require('asset')
local gl = require('gl')
local vec = require('vec')

local program, mesh

-- Render a single quad to the screen.
local function render(g, quad)
  local camera = g.camera
  local texture = quad.texture

  if not mesh then asset.open('mesh/Quad.obj') end
  program = program or asset.open('shader/forward/Quad.prog')
  mesh = mesh or asset.open('mesh/Quad.obj/Quad')

  g:glUseProgram(program.id)
  g:glDepthMask(gl.GL_FALSE)
  g:glEnable(gl.GL_BLEND, gl.GL_DEPTH_TEST)
  g:glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  g:commit()

  gl.glUniform1i(program.tex, 0)
  gl.glActiveTexture(gl.GL_TEXTURE0)
  gl.glBindTexture(gl.GL_TEXTURE_2D, texture.id)
  gl.glUniform4fv(program.tint, 1, quad.tint:data())

  -- Pass matrices to the vertex shader
  local worldMatrix
  local scale = vec.Mat4.scale(quad.width, quad.height, 1)
  if quad.mode == 'particle' then
    error('not supported')
  elseif quad.mode == 'normal' then
    worldMatrix = g.worldMatrix * scale
  else
    error('invalid quad mode')
  end
  local worldViewProjectionMatrix = camera.viewProjectionMatrix * worldMatrix
  
  gl.glUniformMatrix4fv(program.worldViewProjectionMatrix, 1, 0, worldViewProjectionMatrix:data())

  -- Render quad
  gl.glBindVertexArray(mesh.id)
  gl.glDrawElements(gl.GL_TRIANGLES, mesh.index.count, gl.GL_UNSIGNED_INT, nil)
  gl.glBindVertexArray(0)
end

return {
  render = render,
}
