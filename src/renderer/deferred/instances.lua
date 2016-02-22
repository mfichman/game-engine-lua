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
local graphics = require('graphics')
local asset = require('asset')
local struct = require('graphics.struct')

local program, white, blue, buffer

local function createDrawBuffer()
  local buffer = graphics.StreamDrawBuffer()
  gl.glBindVertexArray(buffer.vertexArrayId)
  gl.glEnableVertexAttribArray(4) -- rotation (per-instance data)
  gl.glEnableVertexAttribArray(5) -- origin (per-instance data)
  gl.glVertexAttribDivisor(4, 1) -- advance one entry per instance
  gl.glVertexAttribDivisor(5, 1) -- advance one entry per instance
  gl.glBindVertexArray(0)
  return buffer
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

local function drawInstances(instances)
  -- Append the geometry for this frame to the streaming draw buffer, and
  -- record the offset to the start of the streaming draw buffer.
  buffer = buffer or createDrawBuffer()
  
  local offset = buffer:append(instances.instance)
  local stride = instances.instance.stride
  local mesh = instances.model.mesh

  gl.glBindVertexArray(buffer.vertexArrayId)

  -- Bind the normal mesh vertices and indices, as is done with a single
  -- non-instanced mesh.
  gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, instances.model.mesh.index.id)
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, instances.model.mesh.vertex.id)
  struct.defAttribute('geom_MeshVertex', 0, 'position')
  struct.defAttribute('geom_MeshVertex', 1, 'normal')
  struct.defAttribute('geom_MeshVertex', 2, 'tangent')
  struct.defAttribute('geom_MeshVertex', 3, 'texcoord')

  -- Define the offset from the beginning of the stream draw buf to the
  -- rotation/origin attributes to use during the instanced draw call
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, buffer.id)
  gl.glVertexAttribPointer(4, 4, gl.GL_FLOAT, 0, stride, ffi.cast(ffi.typeof('void*'), offset+(0*ffi.sizeof('GLfloat'))))
  gl.glVertexAttribPointer(5, 3, gl.GL_FLOAT, 0, stride, ffi.cast(ffi.typeof('void*'), offset+(4*ffi.sizeof('GLfloat'))))

  -- Draw the instances
  local count = instances.instance.count
  gl.glDrawElementsInstanced(gl.GL_TRIANGLES, mesh.index.count, gl.GL_UNSIGNED_INT, nil, count)

  gl.glBindVertexArray(0)

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
  g:glUniform1i(program.diffuseMap, 0)
  g:glUniform1i(program.specularMap, 1)
  g:glUniform1i(program.normalMap, 2)
  g:glUniform1i(program.emissiveMap, 3)
  gl.glBindBufferBase(gl.GL_UNIFORM_BUFFER, program.camera, g.camera.id)

  material(g, instances.model.material)

  drawInstances(instances)

  if instances.clearMode == 'auto' then
    instances.instance:clear()
  elseif instances.clearMode == 'manual' then
  else
    error('invalid instance clear mode')
  end
end

return {
  render=render,
  drawInstances=drawInstances,
}
