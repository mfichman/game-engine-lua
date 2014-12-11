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

local GLfloat = ffi.typeof('GLfloat')
local VoidPtr = ffi.typeof('void*')

-- Binds the vertex attribute with the given name to the given attribute index.
local function defAttribute(struct, id, name)
  local stride = ffi.sizeof(struct)
  local offset, bpos, bsize = ffi.cast(VoidPtr, ffi.offsetof(struct, name))
  local ref = ffi.new(struct)[name]
  local size = type(ref) == 'number' and 4 or ffi.sizeof(ref)
  -- FIXME: Assuming a 4-byte number here is a bit hackish
  gl.glEnableVertexAttribArray(id)
  gl.glVertexAttribPointer(id, size/ffi.sizeof(GLfloat), gl.GL_FLOAT, 0, stride, offset)
end

return {
  defAttribute = defAttribute,
}
