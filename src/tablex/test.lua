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

