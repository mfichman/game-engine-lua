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

local Env = require('sandbox.env')

local function load(chunk, source, mode)
  return _G.load(chunk, source, mode, Env())
end

local function loadfile(path, mode)
  return _G.loadfile(chunk, mode, Env())
end

local function dofile(path)
  local fn = loadfile(path)
  return fn()
end

return {
  Env = Env,
  dofile = dofile,
  load = load,
  loadfile = loadfile,
}
