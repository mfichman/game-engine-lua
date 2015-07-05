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

local ffi = require('ffi')
local gl = require('gl')
local graphics = require('graphics')
local asset = require('asset')
local vec = require('vec')
local struct = require('graphics.struct')

local program
local buffer

local function createDrawBuffer()
  local buffer = graphics.StreamDrawBuffer()
  gl.glBindVertexArray(buffer.vertexArrayId)
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, buffer.id)
  struct.defAttribute('graphics_TextVertex', 0, 'position')
  struct.defAttribute('graphics_TextVertex', 1, 'texcoord')
  gl.glBindVertexArray(0) 
  return buffer
end

-- Render text objects
local function render(g, text)

  local camera = g.camera
  local font = text.font

  program = program or asset.open('shader/forward/Text.prog')
  buffer = buffer or createDrawBuffer()

  g:glUseProgram(program.id)
  g:glDepthMask(gl.GL_FALSE)
  g:glEnable(gl.GL_BLEND, gl.GL_DEPTH_TEST)
  g:glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  g:commit()

  gl.glUniform1i(program.tex, 0)
  gl.glActiveTexture(gl.GL_TEXTURE0)
  gl.glBindTexture(gl.GL_TEXTURE_2D, font.id)
  gl.glUniform4fv(program.color, 1, text.color:data())
  gl.glUniform1i(program.sdf, (font.kind == 'sdf') and 1 or 0)

  -- Pass matrices to the vertex shader
  local worldMatrix = g.worldMatrix * vec.Mat4.scale(text.size, text.size, text.size)
  local worldViewProjectionMatrix = camera.viewProjectionMatrix * worldMatrix

  gl.glUniformMatrix4fv(program.worldViewProjectionMatrix, 1, 0, worldViewProjectionMatrix:data())
  
  -- Render text
  buffer:draw(gl.GL_TRIANGLES, text.vertex)
  gl.glBindVertexArray(0)
end

return {
  render = render,
}
