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

local Queue = {}; Queue.__index = Queue

function Queue.new()
  return setmetatable({first = 0, last = -1}, Queue)
end

function Queue:push(value)
  local last = self.last + 1
  self.last = last
  self[last] = value
end

function Queue:pop()
  local first = self.first
  if first > self.last then error('list is empty') end
  local value = self[first]
  self[first] = nil
  self.first = first + 1
  return value
end

function Queue:len()
  return self.last - self.first + 1
end

return Queue.new
