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

local io = require('io')
local os = require('os')

if arg[1]:match('%.skeleton%.lua') then return end

local done = false
local out = {}
local date = os.date('*t')

local fd = io.open('.skeleton.lua')
local header = fd:read('*all'):gsub('%%year', date.year)
table.insert(out, header)
fd:close()

local fd = io.open(arg[1])
for line in fd:lines() do
  if not done and line:match('^%-%-') then
  elseif not done and line == '' then
  else
    done = true
    table.insert(out, line)
  end
end
fd:close()

local fd = io.open(arg[1], 'w')
fd:write(table.concat(out, '\n'))
fd:write('\n')
fd:close()
