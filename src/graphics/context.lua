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
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, APEXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

local gl = require('gl')

local Context = {}; Context.__index = Context

-- Creates a rendering context, which tracks/caches graphics pipeline state.
function Context.new(camera)
  assert(camera, 'camera is missing from context')
  local self = setmetatable({}, Context) 
  self.camera = camera
  self.program = 0
  self.enabled = {}
  self.gen = 0 -- Generation; used to track rendering state changes
  return self
end

function Context:glUseProgram(program)
  if program ~= self.program then
    self.program = program
    gl.glUseProgram(self)
  end
end

-- Update the enabled OpenGL context flags
function Context:glEnable(...)
  for i, enum in ipairs({...}) do
    if not self.enabled[enum] then
      gl.glEnable(enum) 
    end
    self.enabled[enum] = self.gen
  end  
  for enum, gen in pairs(self.enabled) do
    if gen ~= self.gen then
      gl.glDisable(enum)
      self.enabled[enum] = nil
    end
  end
  self.gen = self.gen+1
end

return Context.new
