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

local graphics = require('graphics')
local gl = require('gl')
local sfml = require('sfml')
local ffi = require('ffi')

local settings = sfml.ContextSettings()
settings.depthBits = 24
settings.stencilBits = 0
settings.majorVersion = 3
settings.minorVersion = 2
local context = sfml.Context()

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
local c = graphics.Context(1)
c:glEnable(gl.GL_DEPTH_TEST)
c:glEnable(gl.GL_DEPTH_TEST)
c:glEnable(gl.GL_CULL_FACE)
c:glEnable(gl.GL_DEPTH_TEST, gl.GL_BLEND, gl.GL_CULL_FACE)

-- FrameBuffer
local width, height = 800, 600
local f = graphics.FrameBuffer()
f:drawBufferEnq(graphics.RenderTarget(width, height, gl.GL_RGB))
f:drawBufferEnq(graphics.RenderTarget(width, height, gl.GL_RGBA))
f:drawBufferEnq(graphics.RenderTarget(width, height, gl.GL_RGB16F))
f:drawBufferEnq(graphics.RenderTarget(width, height, gl.GL_RGB))
f:depthBufferIs(graphics.RenderTarget(width, height, gl.GL_DEPTH_COMPONENT24))
f:check()


