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
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

local graphics = require('graphics')
local gl = require('gl')
local sfml = require('sfml')
local ffi = require('ffi')
local vec = require('vec')

local context = sfml.Context()
if ffi.os == 'Windows' then
  local glew = require('glew')
  glew.glewInit()
end

-- Buffer
local b = graphics.Buffer(gl.GL_ARRAY_BUFFER, gl.GL_STATIC_DRAW, 'int')
assert(b.count == 0)
b[10] = 10
assert(b[10] == 10)
assert(b.capacity == 32)
assert(b.count == 11)
b:push(99)
assert(b[11] == 99)
assert(b.capacity == 32)
assert(b.count == 12)
b:sync()
b:clear()
assert(b.count == 0)
b:del()

-- Texture
local t = graphics.Texture(8, 8, ffi.new('GLuint[64]'))
assert(t.id ~= 0)
t:del()

-- Program
local source = [[
  #version 330
  uniform vec3 position;
  uniform vec3 rotation;
  out vec3 out1;
  out vec3 out2;
  void main() {
    out1 = position;
    out2 = rotation;
  }
]]

local f = graphics.Shader(gl.GL_FRAGMENT_SHADER, source)
local v = graphics.Shader(gl.GL_VERTEX_SHADER, '#version 330\nvoid main() {}')
local g = graphics.Shader(gl.GL_GEOMETRY_SHADER, '#version 330\nvoid main() {}')
local p = graphics.Program(f, v, nil)
assert(p.position)
assert(p.rotation)
gl.glUseProgram(p.id)
local x = ffi.new('GLfloat[3]')
gl.glUniform3fv(p.position, 1, x)
assert(gl.glGetError()==0)

-- Mesh
local m = graphics.Mesh()
m:sync()
m:del()

-- Camera
local c = graphics.Camera()
c:update()
c.mode = 'ortho'
c:update()

-- Context
local ctx = graphics.Context(800, 600)
ctx:glEnable(gl.GL_DEPTH_TEST)
ctx:glEnable(gl.GL_DEPTH_TEST)
ctx:glEnable(gl.GL_CULL_FACE)
ctx:glEnable(gl.GL_DEPTH_TEST, gl.GL_BLEND, gl.GL_CULL_FACE)

-- FrameBuffer
local width, height = 800, 600
local f = graphics.FrameBuffer()
  
f:drawBufferEnq(graphics.RenderTarget(width, height, gl.GL_RGB))
--[[f:drawBufferEnq(graphics.RenderTarget(width, height, gl.GL_RGBA))
f:drawBufferEnq(graphics.RenderTarget(width, height, gl.GL_RGB16F))
f:drawBufferEnq(graphics.RenderTarget(width, height, gl.GL_RGB))
f:depthBufferIs(graphics.RenderTarget(width, height, gl.GL_DEPTH_COMPONENT24))
]]
f:check()


local nested = graphics.Transform()
nested.origin = vec.Vec3(2, 4, 6)
nested.name = '1'
nested:componentIs(graphics.Model())

local node = graphics.Transform()
node.origin = vec.Vec3(1, 2, 3)
node.name = '2'
node:componentIs(nested)

ctx:submit(node)

assert(#ctx.op == 1)
assert(ctx.op[1])
assert(ctx.op[1].node.new == graphics.Model)
--assert(ctx.op[1].worldTransform.origin.x == 3)
--assert(ctx.op[1].worldTransform.origin.y == 6)
--assert(ctx.op[1].worldTransform.origin.z == 9)

local asset = require('asset')
local p = asset.open('shader/deferred/Model.prog')
local arr = ffi.new('GLfloat[3]')

gl.glUseProgram(p.id)
gl.glUniform3fv(p.diffuseColor, 1, arr)
assert(gl.glGetError() == 0)
