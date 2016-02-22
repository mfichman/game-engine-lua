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

local vec = require('vec')
local ffi = require('ffi')
local gl = require('gl')

local Material = {}; Material.__index = Material

ffi.cdef[[
struct graphics_MaterialBuffer {
  vec_Color ambientColor;
  vec_Color diffuseColor;
  vec_Color specularColor;
  vec_Color emissiveColor;
  vec_Scalar hardness; 
} graphics_MaterialBuffer;
]]

local MaterialBuffer = ffi.typeof('struct graphics_MaterialBuffer')

function Material.new(args)
  local handle = gl.Handle(gl.glGenBuffers, gl.glDeleteBuffers)
  local id = handle[0]
  local args = args or {}
  local self = {
    id = handle[0],
    diffuseMap = args.diffuseMap,
    specularMap = args.specularMap,
    normalMap = args.normalMap,
    emissiveMap = args.emissiveMap,
    ambientColor = args.ambientColor or vec.Color(0, 0, 0, 1),
    diffuseColor = args.diffuseColor or vec.Color(1, 1, 1, 1),
    specularColor = args.specularColor or vec.Color(1, 1, 1, 1),
    emissiveColor = args.emissiveColor or vec.Color(0, 0, 0, 1),
    hardness = args.hardnesss or 40,
    opacity = args.opacity or 1,
    blendMode = args.blendMode or 'alpha',
    name = args.name,
    handle = handle,
  }

  local buffer = MaterialBuffer {
    ambientColor = self.ambientColor,
    diffuseColor = self.diffuseColor,
    specularColor = self.specularColor,
    emissiveColor = self.emissiveColor,
    hardness = self.hardness,
  }

  gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, self.id)
  gl.glBufferData(gl.GL_UNIFORM_BUFFER, ffi.sizeof(buffer), buffer, gl.GL_STATIC_DRAW)

  return setmetatable(self, Material)
end

function Material:clone()
  return self
end

return Material.new
