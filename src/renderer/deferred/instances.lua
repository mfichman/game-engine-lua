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

local ffi = require('ffi')
local gl = require('gl')
local graphics = require('graphics')
local asset = require('asset')
local struct = require('graphics.struct')

local program, white, blue

-- Pass the texture data to the shader
local function texture(g, texture, index)
  assert(texture, 'texture is nil')
  gl.glActiveTexture(index)
  gl.glBindTexture(gl.GL_TEXTURE_2D, texture.id) 
end

-- Pass the material data to the shader
local function material(g, material)
  g:glUniform3fv(program.diffuseColor, 1, material.diffuseColor:data())
  g:glUniform3fv(program.ambientColor, 1, material.ambientColor:data())
  g:glUniform3fv(program.specularColor, 1, material.specularColor:data())
  g:glUniform3fv(program.emissiveColor, 1, material.emissiveColor:data())
  g:glUniform1f(program.hardness, material.hardness)

  texture(g, material.diffuseMap or white, gl.GL_TEXTURE0+0)
  texture(g, material.specularMap or white, gl.GL_TEXTURE0+1)
  texture(g, material.normalMap or blue, gl.GL_TEXTURE0+2)
  texture(g, material.emissiveMap or white, gl.GL_TEXTURE0+3)
end

-- Render an instanced model
local function render(g, instances)
  if instances.model.material.opacity < 1 then return end
  if not instances:visible() then return end

  program = program or asset.open('shader/deferred/Instances.prog') 
  white = white or asset.open('texture/White.png')
  blue = blue or asset.open('texture/Blue.png')

  g:glUseProgram(program.id)
  g:glEnable(gl.GL_CULL_FACE, gl.GL_DEPTH_TEST)
  g:commit()
  gl.glUniform1i(program.diffuseMap, 0)
  gl.glUniform1i(program.specularMap, 1)
  gl.glUniform1i(program.normalMap, 2)
  gl.glUniform1i(program.emissiveMap, 3)

  material(g, instances.model.material)

  instances:sync()
  local mesh = instances.model.mesh
  local count = instances.instance.count
  gl.glUniformMatrix4fv(program.viewProjectionMatrix, 1, 0, g.camera.viewProjectionMatrix:data()) 
  gl.glUniformMatrix4fv(program.viewMatrix, 1, 0, g.camera.viewMatrix:data()) 
  gl.glBindVertexArray(instances.id)
  gl.glDrawElementsInstanced(gl.GL_TRIANGLES, mesh.index.count, gl.GL_UNSIGNED_INT, nil, count)
  gl.glBindVertexArray(0)

  if instances.clearMode == 'auto' then
    instances.instance:clear()
  elseif instances.clearMode == 'manual' then
  else
    error('invalid instance clear mode')
  end
end

return {
  render=render
}
