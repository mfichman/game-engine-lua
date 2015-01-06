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

local freetype = require('freetype')
local ffi = require('ffi')

local library = ffi.new('FT_Library[1]')
local face = ffi.new('FT_Face[1]')

freetype.FT_Init_FreeType(library)
freetype.FT_New_Face(library[0], 'font/Norwester.ttf', 0, face)
freetype.FT_Done_Face(face[0])
freetype.FT_Done_FreeType(library[0])
