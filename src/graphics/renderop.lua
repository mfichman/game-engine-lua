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

local RenderOp = {}; RenderOp.__index = RenderOp

-- A render op encapsulates everything needed for a single draw command: the
-- object to be rendered, the complete transform set and the Z value.
function RenderOp.new(node, camera, worldMatrix)
  local self = {
    worldMatrix = worldMatrix,
    node = node,
    camera = camera,
  }
  return setmetatable(self, RenderOp)
end

return RenderOp.new
