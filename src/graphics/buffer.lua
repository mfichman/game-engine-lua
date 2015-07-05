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
local math = require('math')

local Buffer = {}; Buffer.__index = Buffer

-- Create a new attribute or index buffer that is an array of the elements 
-- indicated by 'kind'
function Buffer.new(target, usage, buffer)
  local handle = gl.Handle(gl.glGenBuffers, gl.glDeleteBuffers)
  local id = handle[0]
  local size = buffer.stride * buffer.count
  gl.glBindBuffer(target, id)
  gl.glBufferData(target, size, buffer.element, usage)

  local self = {
    id = handle[0],
    handle = handle,
    target = target,
    usage = usage,
    count = buffer.count,
    stride = buffer.stride,
  }
  return setmetatable(self, Buffer)
end

return Buffer.new
