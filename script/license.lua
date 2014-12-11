


local io = require('io')

local fd = io.open(arg[1])
local done = false

local out = {}

table.insert(out, io.open('copyright'):read('*all'))

for line in fd:lines() do
  if not done and line:match('^%-%-') then
  else
    done = true
    table.insert(out, line)
  end
end

print(table.concat(out, '\n'))
