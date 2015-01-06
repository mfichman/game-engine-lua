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
local freetype = require('freetype')

local Font = {}; Font.__index = Font

local library = ffi.new('FT_Library[1]')
if freetype.FT_Init_FreeType(library) ~= 0 then
  error('could not initialize font library')
end

ffi.gc(function(library) 
  freetype.FT_Done_FreeType(library[0])  
end)

-- Initialize a new font with the given size and kind. The font 'kind' may be 
-- either 'sdf' for scalable signed distance field font rendering, or 'fixed'
-- for fixed fonts.
function Font.new(name, size, kind)
  local self = {
    name = name,
    size = size,
    kind = kind,
    handle = gl.Handle(gl.glGenTextures, gl.glDeleteTextures),
    face = ffi.new('FT_Face[1]')
  }
  self.id = self.handle[0]

  gl.glBindTexture(gl.GL_TEXTURE_2D, self.id)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR_MIPMAP_NEAREST)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP_TO_EDGE)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP_TO_EDGE)
  gl.glPixelStorei(gl.GL_UNPACK_ALIGNMENT, 1)

  if freetype.FT_New_Face(library[0], name, 0, face) ~= 0 then
    error('could not initialize font: '+name)
  else
    ffi.gc(function(face) 
      freetype.FT_Done_Face(face[0])
    end)
  end

  return setmetatable(self, Font)
end

return Font.new
