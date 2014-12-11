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

package.path = './src/?.lua;./src/?/init.lua;'..package.path

local game = require('game')
local dbg = require('dbg')
local entity = require('entity')
local vec = require('vec')
local config = require('config')
local world = require('world')

local function main()
  entity.World{}
  entity.Fighter{teamId = 1}
--  entity.Cruiser{teamId = 1, kind = 'Destroyer'}
  game:run()
end

xpcall(main, dbg.start)
