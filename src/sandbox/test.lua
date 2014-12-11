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

local sandbox = require('sandbox')
local unsafe = [[
  local string = require('string')
  assert(string.len('foobar') == 6)
  local val, err = pcall(function() local io = require('io') end)
  assert(err:match('package not found: io'))
]]

local fn = sandbox.load(unsafe)
fn()

