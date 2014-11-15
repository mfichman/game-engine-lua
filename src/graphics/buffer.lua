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

local ffi = require('ffi')
local gl = require('gl')
local math = require('math')

local Buffer = {}; Buffer.__index = Buffer

-- Create a new attribute or index buffer that is an array of the elements 
-- indicated by 'kind'
function Buffer.new(target, usage, kind)
  local self = {}
  self.status = 'dirty'
  self.target = target
  self.usage = usage
  self.kind = ffi.typeof(string.format('%s[?]', kind))
  self.capacity = 32
  self.count = 0
  self.stride = ffi.sizeof(kind)
  self.element = self.kind(self.capacity)
  self.id = 0
  return setmetatable(self, Buffer)
end

-- Reserve up to 'count' bytes in the buffer, and increase the buffer count
-- to 'count'. Resizes the underlying array if necessary.
function Buffer:reserve(count)
  if count < self.count then return end
  if count < self.capacity then
    self.count = count
    return
  end 
  local capacity = count + math.floor(count/2)
  local element = self.kind(capacity)
  ffi.copy(element, self.element, ffi.sizeof(self.element))
  self.count = count
  self.capacity = capacity
  self.element = element
  self.status = 'dirty'
end

-- Append an element to the end of the buffer, and mark the buffer as dirty.
function Buffer:push(element)
  local index = self.count
  self:reserve(index+1)
  self.element[index] = element
  self.status = 'dirty'
end

-- Insert and element at the given location. Resize the buffer if necessary.
function Buffer:__newindex(index, element)
  self:reserve(index+1)
  self.element[index] = element
  self.status = 'dirty'
end

-- Returns the element at the given location, or 'nil' if the index is out
-- of range.
function Buffer:__index(index)
  if type(index) ~= 'number' then
    return Buffer[index]
  elseif index < self.count then
    return self.element[index]
  else
    return nil
  end
end

-- Sync the buffer with the graphics hardware if the buffer is dirty.
function Buffer:sync()
  if self.status == 'synced' then return end
  if self.id == 0 then
    local id = ffi.new('GLint[1]')
    gl.glGenBuffers(1, id)
    self.id = id[0]
  end
  local size = self.stride * self.count
  gl.glBindBuffer(self.target, self.id)
  gl.glBufferData(self.target, size, self.element, self.usage)
  self.status = 'synced'
end

-- Clear the buffer and mark as dirty.
function Buffer:clear()
  self.count = 0
  self.status = 'dirty'
end

-- Free the buffer and release the hardware handle
function Buffer:del()
  local id = ffi.new('GLint[1]', self.id) 
  gl.glDeleteBuffers(1, id)
  self.id = 0
end

Buffer.__gc = Buffer.del

return Buffer.new
