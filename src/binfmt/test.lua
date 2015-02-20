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

local binfmt = require('binfmt')
local ffi = require('ffi')

local n = 40000
local str = ffi.new('char[?]',n)
for i=0,n-1 do
  str[i] = i
end
local str = ffi.string(str,n)

local fd = binfmt.Writer(io.open('out','wb'))
fd:uint64(0x1212)
fd:uint8(8)
fd:string('foo12341234123412341234')
fd:string(str)
fd:close()

local fd = binfmt.Reader(io.open('out','rb'))
assert(fd:uint64()==0x1212)
assert(fd:uint8()==8)
assert(fd:string()=='foo12341234123412341234')
assert(fd:string()==str)
fd:close()
