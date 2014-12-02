-- Copyright (c) 2014 Matt Fichman
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

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
