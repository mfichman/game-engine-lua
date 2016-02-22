-- Copyright (c) 2016 Matt Fichman
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

local io = require('io')
local ffi = require('ffi')

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

-- Open a library on the path
function m.load(name)
  local path
  if ffi.os == 'Windows' then
    path = m.find(name..'.dll')
  elseif ffi.os == 'OSX' then
    path = m.find('lib'..name..'.dylib')
  else
    error('unsupported platform')
  end
  if path then
    return ffi.load(path)
  else
    return ffi.load(name)
  end
end

-- Open a file on the path
function m.open(item, flags)
  local path = m.find(item)
  if not path then error('file not found: '..item) end
  return io.open(path)
end

return m
