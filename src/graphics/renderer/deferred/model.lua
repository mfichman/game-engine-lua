-- Copyright (c) 2014 Matt Fichman
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
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, APEXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

-- Renders material info for triangle meshes into the G-buffer.

local ffi = require('ffi')
local gl = require('gl')
local graphics = require('graphics')
local asset = require('asset')
local program = asset.open('shader/model.prog')

-- Render a mesh, using the current bindings for the material and texture
local function mesh(g, mesh)
  assert(mesh, "model has no mesh!")
  assert(mesh.index, "mesh has no index buffer!")
  assert(g.camera, "no camera!")

  mesh:sync()
  
  -- Calculate the normal matrix and pass it to the vertex shader
  local camera = g.camera
  local normalMatrix = (camera.view * g.world):inverse():transpose()
  local temp = ffi.new('GLfloat[9]', {
    normalMatrix.data[0], normalMatrix.data[1], normalMatrix.data[2], 
    normalMatrix.data[4], normalMatrix.data[5], normalMatrix.data[6], 
    normalMatrix.data[8], normalMatrix.data[9], normalMatrix.data[10], 
  })

  local transform = camera.transform * g.world

  -- Pass the model matrix to the vertex shader
  g:glUniformMatrix3fv(program.normalMatrix, 1, 0, temp)
  g:glUniformMatrix4fv(program.transform, 1, 0, transform.data) 

  gl.glBindVertexArray(mesh.id)
  gl.glDrawElements(gl.GL_TRIANGLES, mesh.index.count, gl.GL_UNSIGNED_INT, nil)
  gl.glBindVertexArray(0)
end

-- Pass the texture data to the shader
local function texture(g, texture, index)
  if not texture then return end
  gl.glActiveTexture(index)
  gl.glBindTexture(gl.GL_TEXTURE_2D, texture.id) 
end

-- Pass the material data to the shader
local function material(g, material)
  g:glUniform3fv(program.ambientColor, 1, material.ambientColor.data)
  g:glUniform3fv(program.diffuseColor, 1, material.diffuseColor.data)
  g:glUniform3fv(program.specularColor, 1, material.specularColor.data)
  g:glUniform3fv(program.emissiveColor, 1, material.emissiveColor.data)
  g:glUniform1f(program.hardness, material.hardness)

  texture(g, material.diffuseMap, gl.GL_TEXTURE0)
  texture(g, material.specularMap, gl.GL_TEXTURE1)
  texture(g, material.normalMap, gl.GL_TEXTURE2)
  texture(g, material.emissiveMap, gl.GL_TEXTURE3)
end

-- Render a model (a mesh with an attached texture and material)
local function render(g, model)
  assert(g, "graphics context is nil!")
  assert(model, "model is nil")
  assert(model.material, "model has no material!")
  if model.material.opacity < 1 then
    return
  end

  g:glUseProgram(program.id) -- Use cached program ID if already set
  g:glEnable(gl.GL_CULL_FACE, gl.GL_DEPTH_TEST)

  material(g, model.material)
  mesh(g, model.mesh)
end

return {
  render = render
}
