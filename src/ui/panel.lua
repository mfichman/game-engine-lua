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

local layout = require('ui.layout')
local vec = require('vec')

local Panel = {}; Panel.__index = Panel

function Panel.new(args)
  local self = {
    position = layout.layout(args.parent, args.basis, args.position, args.size),
    size = args.size,
  } 
  return setmetatable(self, Panel)
end

return Panel.new
