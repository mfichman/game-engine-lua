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
