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
  gl.glBindBufferBase(gl.GL_UNIFORM_BUFFER, program.material, material.id)

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
  g:glUniform1i(program.diffuseMap, 0)
  g:glUniform1i(program.specularMap, 1)
  g:glUniform1i(program.normalMap, 2)
  g:glUniform1i(program.emissiveMap, 3)

  material(g, model.material)
  mesh(g, model.mesh)
end

return {
  render=render
}
