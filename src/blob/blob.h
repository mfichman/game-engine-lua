/* ========================================================================== --
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
-- ========================================================================== */

typedef uint32_t blob_Id;

__declspec(dllexport) void* blob_Ref_new(size_t len);
__declspec(dllexport) void* blob_Ref_find(blob_Id id);
__declspec(dllexport) blob_Id blob_Ref_id(void* self);
__declspec(dllexport) void blob_Ref_del(void* self);

