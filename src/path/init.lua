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

local m = {}

m.path = './src;.'

-- Join filesystem path components
function m.join(...)
  local buf = {}
  for i, v in ipairs({...}) do
    local v = v:match('^(.+)/$') or v
    table.insert(buf, v)
  end
  return table.concat(buf, '/')
end

-- Find a file on the path
function m.find(item)
  for path in m.path:gfind('([^;]+);?') do
    local path = m.join(path, item)
    local fd = io.open(path)
    if fd then 
      fd:close()
      return path
    end
  end
end

-- Open a file on the path
function m.open(item, flags)
  local path = m.find(item)
  if not path then error('file not found: '..item) end
  return io.open(path)
end

return m
