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
typedef struct FILE FILE;
int fwrite(const void* ptr, size_t size, size_t nitems, FILE* file);
int fread(void* ptr, size_t size, size_t nitems, FILE* file);
int fgetc(FILE* file);
int ungetc(int c, FILE* file);
int feof(FILE* file);
]]

return {
  Writer = require('binfmt.writer'),
  Reader = require('binfmt.reader'),
}
