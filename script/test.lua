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

local os = require('os')

local test = {
  'src/asset/test.lua',
  'src/game/test.lua',
  'src/graphics/test.lua',
  'src/path/test.lua',
  'src/sandbox/test.lua',
  'src/vec/test.lua',
  'src/physics/test.lua',
  'src/tablex/test.lua',
  'src/item/test.lua',
  'src/freetype/test.lua',
  'src/binfmt/test.lua',
}

for i, test in ipairs(test) do
  print(test)
  dofile(test)
end
