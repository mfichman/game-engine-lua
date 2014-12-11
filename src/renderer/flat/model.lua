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

local asset = require('asset')
local gl = require('gl')

local program

local function render(g, model)
  if model.material.opacity < 1 then return end
  local mesh = model.mesh
  mesh:sync()

  program = program or asset.open('shader/flat/Model.prog')
  gl.glUseProgram(program.id)

  -- Pass the model matrix to the vertex shader
  local worldViewProjectionMatrix = g.camera.viewProjectionMatrix * g.worldMatrix
  gl.glUniformMatrix4fv(program.worldViewProjectionMatrix, 1, 0, worldViewProjectionMatrix:data())

  -- Render the mesh
  gl.glBindVertexArray(mesh.id)
  gl.glDrawElements(gl.GL_TRIANGLES, mesh.index.count, gl.GL_UNSIGNED_INT, nil)
  gl.glBindVertexArray(0)
end

return {
  render=render,
}
