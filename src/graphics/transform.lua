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

local Transform = {}; Transform.__index = Transform

function Transform.new(args)
  local self = {
    component = {},
    origin = args and args.origin or vec.Vec3(),
    rotation = args and args.rotation or vec.Quat.identity(),
    shadowMode = args and args.shadowMode or 'shadowed',
    renderMode = args and args.renderMode or 'visible',
  }
  return setmetatable(self, Transform)
end

function Transform:componentIs(comp)
  assert(comp)
  table.insert(self.component, comp)
  return comp
end

function Transform:componentDel(comp)
  assert(comp)
  for i, v in ipairs(self.component) do
    if v == comp then
      table.remove(self.component, i)
      return
    end
  end
end

function Transform:clone()
  local clone = Transform.new(self)
  for i, component in ipairs(self.component) do
    clone:componentIs(component:clone())
  end
  return clone
end

return Transform.new
