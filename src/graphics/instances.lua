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

local vec = require('vec')
local gl = require('gl')
local geom = require('geom')
local struct = require('graphics.struct')

local Buffer = require('graphics.buffer')
local Instance = require('graphics.instance')

local Instances = {}; Instances.__index = Instances

-- Creates a new set of mesh instances. Each instance is a mesh with its own
-- world transform.  All instances in an instance set use the same texture,
-- material, mesh, and shader, so that they can all be drawn in the same batch.
-- This increases efficiency by reducing the number of draw calls that the
-- renderer needs to issue.
function Instances.new(args)
  assert(args.model, 'no model set for instances')
  local self = {
    model = args.model,
    clearMode = args.clearMode or 'manual',
    instance = geom.Buffer('graphics_Instance'),
  }
  return setmetatable(self, Instances)
end

function Instances:visible()
  return self.instance.count > 0
end

return Instances.new
