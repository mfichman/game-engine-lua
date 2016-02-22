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

local tablex = require('tablex')

local t = {foo = '1', baz = '2'}
local c = tablex.const(t)

assert(c.foo =='1')
assert(c.baz =='2')

val, err = pcall(function() c.foo = 1 end)
assert(err)

val, err = pcall(function() c.dingus = 1 end)
assert(err)

local l = tablex.List()
l:enq(1)
assert(l:len()==1)
local n = l:enq(2)
assert(l:len()==2)
l:enq(3)
assert(l:len()==3)

l:remove(n)
assert(l:len()==2)

assert(l:deq()==1)
assert(l:len()==1)
assert(l:deq()==3)
assert(l:len()==0)

local q = tablex.Queue()
q:push('foo')
q:push('bar')
q:push('baz')

assert(q:len()==3)
assert(q:pop()=='foo')
assert(q:len()==2)
assert(q:pop()=='bar')
assert(q:len()==1)
assert(q:pop()=='baz')
assert(q:len()==0)

