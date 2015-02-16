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

local Writer = {}; Writer.__index = Writer

local buf = ffi.new('char[64]')

function Writer.new(fd)
  local self = {fd = fd}
  return setmetatable(self, Writer)
end

function Writer:uint64(val)
  ffi.cast('uint64_t*', buf)[0] = val
  ffi.C.fwrite(buf, ffi.sizeof('uint64_t'), 1, self.fd)
end

function Writer:uint32(val)
  ffi.cast('uint32_t*', buf)[0] = val
  ffi.C.fwrite(buf, ffi.sizeof('uint32_t'), 1, self.fd)
end

function Writer:uint8(val)
  ffi.cast('uint8_t*', buf)[0] = val
  ffi.C.fwrite(buf, ffi.sizeof('uint8_t'), 1, self.fd)
end

function Writer:number(val)
  ffi.cast('double*', buf)[0] = val
  ffi.C.fwrite(buf, ffi.sizeof('double'), 1, self.fd)
end

function Writer:boolean(val)
  ffi.cast('uint8_t*', buf)[0] = val
  ffi.C.fwrite(buf, ffi.sizeof('uint8_t'), 1, self.fd)
end

function Writer:string(val)
  self:uint64(val:len()+1)
  ffi.C.fwrite(val, val:len()+1, 1, self.fd)
end

function Writer:close()
  self.fd:close()
end

return Writer.new
