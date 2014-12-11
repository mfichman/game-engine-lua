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

local function render(g, instances)
  if instances.model.material.opacity < 1 then return end
  if not instances:visible() then return end

  program = program or asset.open('shader/flat/Instances.prog')
  white = white or asset.open('texture/White.png')
  blue = blue or asset.open('texture/Blue.png')

  gl.glUseProgram(program.id)

  instances:sync()
  local mesh = instances.model.mesh
  local count = instances.instance.count
  gl.glUniformMatrix4fv(program.viewProjectionMatrix, 1, 0, g.camera.viewProjectionMatrix:data()) 
  gl.glBindVertexArray(instances.id)
  gl.glDrawElementsInstanced(gl.GL_TRIANGLES, mesh.index.count, gl.GL_UNSIGNED_INT, nil, count)
  gl.glBindVertexArray(0)
end

return {
  render=render,
}
