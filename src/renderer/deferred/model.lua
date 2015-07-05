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
local asset = require('asset')

local program, white, blue

-- Render a mesh, using the current bindings for the material and texture
local function mesh(g, mesh)
  -- Calculate the normal matrix and pass it to the vertex shader
  local normalMatrix = (g.camera.viewMatrix * g.worldMatrix):inverse():transpose()
  local temp = ffi.new('GLfloat[9]', {
    normalMatrix.d00, normalMatrix.d01, normalMatrix.d02, 
    normalMatrix.d04, normalMatrix.d05, normalMatrix.d06, 
    normalMatrix.d08, normalMatrix.d09, normalMatrix.d10, 
  })

  local worldViewProjectionMatrix = g.camera.viewProjectionMatrix * g.worldMatrix

  -- Pass the model matrix to the vertex shader
  gl.glUniformMatrix3fv(program.normalMatrix, 1, 0, temp)
  gl.glUniformMatrix4fv(program.worldViewProjectionMatrix, 1, 0, worldViewProjectionMatrix:data()) 

  gl.glBindVertexArray(mesh.id)
  gl.glDrawElements(gl.GL_TRIANGLES, mesh.index.count, gl.GL_UNSIGNED_INT, nil)
  gl.glBindVertexArray(0)
end

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

-- Render a model (a mesh with an attached texture and material)
local function render(g, model)
  assert(model.material, 'model has no material!')

  if model.renderMode == 'invisible' then return end
  if model.material.opacity < 1 then return end
  program = program or asset.open('shader/deferred/Model.prog') 
  white = white or asset.open('texture/White.png')
  blue = blue or asset.open('texture/Blue.png')

  g:glUseProgram(program.id)
  g:glEnable(gl.GL_CULL_FACE, gl.GL_DEPTH_TEST)
  g:commit()
  gl.glUniform1i(program.diffuseMap, 0)
  gl.glUniform1i(program.specularMap, 1)
  gl.glUniform1i(program.normalMap, 2)
  gl.glUniform1i(program.emissiveMap, 3)

  material(g, model.material)
  mesh(g, model.mesh)
end

return {
  render=render
}
