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

local sfml = require('sfml')

local Binding = {}; Binding.__index = Binding

function Binding.new(args)
  local self = {
    key = args.key,
    mouse = args.mouse,
  }
  return setmetatable(self, Binding)
end

function Binding:__call()
  if self.key and sfml.Keyboard_isKeyPressed(self.key) == 1 then return true end
  if self.mouse and sfml.Mouse_isButtonPressed(self.mouse) == 1 then return true end
  return false
end

return Binding.new
