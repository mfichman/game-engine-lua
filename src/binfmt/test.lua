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
