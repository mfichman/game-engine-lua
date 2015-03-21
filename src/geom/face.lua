-- ========================================================================== --
--                                                                            --
-- Copyright (c) 2015 Matt Fichman <matt.fichman@gmail.com>                   --
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

ffi.cdef[[
  typedef struct geom_Face {
    vec_Vec3 vertex0;
    vec_Vec3 vertex1;
    vec_Vec3 vertex2;
  } geom_Face;
]]

local Face = {}; Face.__index = Face
local FaceType = ffi.typeof('geom_Face')

function Face.new(...)
  return FaceType(...)
end

ffi.metatype(FaceType, Face)
return Face.new
