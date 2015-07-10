-- ========================================================================== --
--                                                                            --
-- Copyright (c) 2015 Matt Fichman <matt.fichman@gmail.com>                   --
--                                                                            --
-- This file is part of Quadrant.  It is subject to the license terms in the  --
-- LICENSE.md file found in the top-level directory of this software package  --
-- and at http://github.com/mfichman/quadrant/blob/master/LICENSE.md.         --
-- No person may use, copy, modify, publish, distribute, sublicense and/or    --
-- sell any part of Quadrant except according to the terms contained in the   --
-- LICENSE.md file.                                                           --
--                                                                            --
-- ========================================================================== --

local Component = require('ui.component')
local Composite = {}; Composite.__index = Composite

function Composite.new(args)
  local self = Component(args)
  local component = {}
  local ui = require('ui')

  for i, v in ipairs(args) do
    local kind = ui[v.kind]
    v.parent = self
    table.insert(component, kind(v))
  end

  self.component = component

  return setmetatable(self, Composite)
end

return Composite.new
