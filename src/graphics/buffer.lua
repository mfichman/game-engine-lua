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
  self.capacity = 0
  self.count = 0
  self.stride = ffi.sizeof(kind)
  self.element = self.kind(self.capacity)
  self.id = 0
  self.handle = 0
  return setmetatable(self, Buffer)
end

-- Reserve up to 'count' bytes in the buffer, and increase the buffer count
-- to 'count'. Resizes the underlying array if necessary.
function Buffer:reserve(count)
  if count < self.capacity then return end 
  local capacity = math.max(64, count + math.floor(count/2))
  local element = self.kind(capacity)
  ffi.copy(element, self.element, ffi.sizeof(self.kind, self.capacity))
  self.capacity = capacity
  self.element = element
  self.status = 'dirty'
end

function Buffer:resize(count)
  if count < self.count then return end
  self:reserve(count)
  self.count = count
end

-- Append an element to the end of the buffer, and mark the buffer as dirty.
function Buffer:push(element)
  local index = self.count
  self:resize(index+1)
  self.element[index] = element
  self.status = 'dirty'
end

-- Insert and element at the given location. Resize the buffer if necessary.
function Buffer:__newindex(index, element)
  self:resize(index+1)
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
    self.handle = gl.Handle(gl.glGenBuffers, gl.glDeleteBuffers)
    self.id = self.handle[0]
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

return Buffer.new
