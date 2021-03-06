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
local os = require('os')

if not arg[1] or not arg[2] then
  error('usage: license.lua template file')
end

if arg[2]:match('%*.skeleton.%*') then return end

local done = false
local out = {}
local date = os.date('*t')

local fd = io.open(arg[1])
local header = fd:read('*all'):gsub('%%year', date.year)
table.insert(out, header)
fd:close()

local fd = io.open(arg[2])
for line in fd:lines() do
  if not done and line:match('^%-%-') then
  elseif not done and line:match('^%/%*') then
  elseif not done and line:match('^ %*') then
  elseif not done and line == '' then
  else
    done = true
    table.insert(out, line)
  end
end
fd:close()

local fd = io.open(arg[2], 'w')
fd:write(table.concat(out, '\n'))
fd:write('\n')
fd:close()
