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

local path = require('path')
local ffi = require('ffi')

ffi.cdef(path.open('vec/vec.h'):read('*all'))

return {
  Mat4 = require('vec.mat4'),
  Mat4x4 = require('vec.mat4x4'),
  Quat = require('vec.quat'),
  Vec2 = require('vec.vec2'),
  Vec3 = require('vec.vec3'),
  Vec4 = require('vec.vec4'),
  Transform = require('vec.transform'),
  Color = require('vec.color'),
}
