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

local dbg = require('dbg')
local w = 'foo'

function wrap() 
  dbg.start()
  local z = 3
  function foo() 
    local x = 1
    local y = 2
    local foo = {x = 1, y = 2, z = {}}
  
  
    bob.bill = 0
    print(x, y, z, foo)
    w = 10
  end
  foo()
  print(z)
end

xpcall(wrap, dbg.start)

