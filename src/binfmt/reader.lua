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

local Reader = {}; Reader.__index = Reader

local buf = ffi.new('char[64]')

function Reader.new(fd)
  local self = {fd = fd}
  return setmetatable(self, Reader)
end

function Reader:uint64()
  ffi.C.fread(buf, ffi.sizeof('uint64_t'), 1, self.fd)
  return tonumber(ffi.cast('uint64_t*', buf)[0])
end

function Reader:uint32()
  ffi.C.fread(buf, ffi.sizeof('uint32_t'), 1, self.fd)
  return tonumber(ffi.cast('uint32_t*', buf)[0])
end

function Reader:uint8()
  ffi.C.fread(buf, ffi.sizeof('uint8_t'), 1, self.fd)
  return tonumber(ffi.cast('uint8_t*', buf)[0])
end

function Reader:number()
  ffi.C.fread(buf, ffi.sizeof('double'), 1, self.fd)
  return tonumber(ffi.cast('double*', buf)[0])
end

function Reader:boolean()
  ffi.C.fread(buf, ffi.sizeof('uint8_t'), 1, self.fd)
  return ffi.cast('uint8_t*', buf)[0] ~= 0
end

function Reader:string()
  local n = self:uint64()
  local buf = ffi.new('char[?]', n)
  ffi.C.fread(buf, n, 1, self.fd)
  return ffi.string(buf, n-1) 
end

function Reader:eof()
  local c = ffi.C.fgetc(self.fd)
  local eof = ffi.C.feof(self.fd)~=0
  ffi.C.ungetc(c, self.fd)
  return eof
end

function Reader:close()
  self.fd:close()
end

return Reader.new
