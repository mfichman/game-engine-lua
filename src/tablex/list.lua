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

local List = {}; List.__index = List

function List.new()
  return setmetatable({size=0}, List)
end

function List:remove(node)
  local p = node.p
  local n = node.n

  if p then p.n = n end
  if n then n.p = p end
  self.size = self.size - 1
end

function List:enq(value)
  local tail = self.tail
  local node = {value = value, p = tail}
  if tail then
    tail.n = node
  end
  if not self.head then
    self.head = node
  end
  self.tail = node
  self.size = self.size + 1
  return node
end

function List:deq(node)
  local head = self.head
  if head then
    local n = head.n
    if n then n.p = nil end
    self.head = n
    self.size = self.size - 1
    return head.value 
  end
end

function List:len()
  return self.size
end

return List.new
