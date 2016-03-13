-- Copyright (c) 2016 Matt Fichman
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

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
