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

local RenderTarget = {}; RenderTarget.__index = RenderTarget

function RenderTarget.new(width, height, format)
  local self = { handle = gl.Handle(gl.glGenTextures, gl.glDeleteTextures) }
  self.id = self.handle[0]

  gl.glBindTexture(gl.GL_TEXTURE_2D, self.id)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP_TO_EDGE)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP_TO_EDGE)

  -- FIXME: Check for other depth component types
  if format == gl.GL_DEPTH_COMPONENT24 then
    gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, format, width, height, 0, gl.GL_DEPTH_COMPONENT, gl.GL_UNSIGNED_BYTE, nil)
  elseif format == gl.GL_DEPTH24_STENCIL8 then
    gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, format, width, height, 0, gl.GL_DEPTH_COMPONENT, gl.GL_UNSIGNED_BYTE, nil)
  else
    gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, format, width, height, 0, gl.GL_RGBA, gl.GL_UNSIGNED_BYTE, nil)
  end

  return setmetatable(self, RenderTarget)
end

return RenderTarget.new
