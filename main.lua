#!/usr/local/bin/rlwrap luajit
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

local config = require('config')
local dbg = require('dbg')

local function main()
  local game = require('game')
  local entity = require('entity')
  local graphics = require('graphics')
  local gamemath = require('gamemath')
  local vec = require('vec')
  local component = require('component')

  entity.World{}
  entity.Fighter{teamId = 2, origin = vec.Vec3(0, 0, 205)}
--  entity.EscapePod{teamId = 1}
--  entity.CommTower{}
--  entity.Cruiser{teamId = 1, kind = 'Destroyer'}
  game.run()
end

if config.debug then
  xpcall(main, dbg.start)
else
  xpcall(main, dbg.dump)
end



--[[
For shadow debugging
  local ent = entity.Fighter{teamId = 1}
  local camera = game.Table('Camera')
  local camera = camera[ent.id]
  camera:update(ent.id)
  local frustum = { -- frustum in screen space
    gamemath.deviceToWorld(graphics.camera, vec.Vec3(-1, -1, 0)),
    gamemath.deviceToWorld(graphics.camera, vec.Vec3(-1, 1, 0)),
    gamemath.deviceToWorld(graphics.camera, vec.Vec3(1, 1, 0)),
    gamemath.deviceToWorld(graphics.camera, vec.Vec3(1, -1, 0)),
  } 
  for i, p in ipairs(frustum) do
    --entity.Rock{origin = vec.Vec3(p.x, p.y, -1), kind = 'LargeRock0'}
  end
  --entity.Rock{origin = vec.Vec3(), rotation = vec.Quat.identity(), kind = 'SmallRock0'}
]]

