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

local ffi = require('ffi')
local gl = require('gl')

local GLfloat = ffi.typeof('GLfloat')
local VoidPtr = ffi.typeof('void*')
local CharPtr = ffi.typeof('char*')

-- Returns the size of 'field' in 'struct'
local function sizeOf(struct, field)
  local p = ffi.cast(struct, 1)
  return ffi.sizeof(p[field])
end

-- Calculates the offset of 'field' in 'struct' 
local function offsetOf(struct, field)
  local p = ffi.cast(struct, 1)
  local q = ffi.cast(CharPtr, p[field])
  return q-ffi.cast(CharPtr, p)
end

-- Binds the vertex attribute with the given name to the given attribute index.
local function defAttribute(struct, id, name)
  local stride = ffi.sizeof(struct)
  local size = sizeOf(struct..'*', name)
  local offset = ffi.cast(VoidPtr, offsetOf(struct..'*', name))
  gl.glEnableVertexAttribArray(id)
  gl.glVertexAttribPointer(id, size/ffi.sizeof(GLfloat), gl.GL_FLOAT, 0, stride, offset)
end

return {
  defAttribute=defAttribute,
}
