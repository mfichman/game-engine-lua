-- Debugger for Lua programs with remote connection support.  Provides access
-- to locals at each stack level.

local debug = require('debug')
local io = require('io')
local os = require('os')
local level = 1
local input = io.input()
local output = io.output()
local metatable = {}
local env = {}
local sources = {}
local lastcmd 
local start
local step

-- Returns the source line at line
local function getline(path, line)
  local source = sources[path]
  if not source then
    local fd = io.open(path)
    source = {}
    for line in fd:lines() do
      table.insert(source, line)
    end
    sources[path] = source
  end
  return source[line]
end

-- Returns the level of the 'start' function
local function startlevel()
  local level = 0
  while true do
    local fn = debug.getinfo(level).func
    if fn == start then
      return level
    else
      level = level+1
    end
  end
end

-- Match cases with functions. Each case consists of a pattern that is used to
-- match the argument. If a pattern matches, then match calls the function
-- paired with that pattern.
local function match(line)
  return function(cases)
    if line == nil then
      return false
    end
    for _, case in ipairs(cases) do
      k, f = unpack(case)
      args = {line:match(k)}
      if #args > 0 then
        return f(unpack(args))
      end
    end
    return true
  end
end

-- Returns the upvalue with the name 'k'.
local function getupvalue(k)
  local level = startlevel()+level
  local i = 1
  while true do
    local f = debug.getinfo(level, 'f').func
    local name, v = debug.getupvalue(f, i)
    if name == nil then
      return nil
    elseif name == k then
      return v
    else
      i = i+1
    end
  end
end

-- Sets a local value, if found 
local function setupvalue(k, v)
  local level = startlevel()+level
  local i = 1  
  while true do 
    local f = debug.getinfo(level, 'f').func
    local name = debug.getupvalue(f, i)
    if name == nil then
      return nil
    elseif name == k then
      debug.setupvalue(f, i, v)
      return name
    else
      i = i+1
    end
  end
end

-- Returns the local with the name 'k' at the given stack level in the user
-- program.
local function getlocal(k)
  local level = startlevel()+level
  local i = 1
  while true do
    local name, v = debug.getlocal(level, i)
    if name == nil then
      return nil
    elseif name == k then
      return v
    else
      i = i+1
    end
  end
end

-- Sets a local value, if found 
local function setlocal(k, v)
  local level = startlevel()+level
  local i = 1  
  while true do 
    local name = debug.getlocal(level, i)
    if name == nil then
      return nil
    elseif name == k then
      debug.setlocal(level, i, v)
      return name
    else
      i = i+1
    end
  end
end

-- Pretty-print a value. Basically the same as the base library's print(),
-- except that it prints tables in a human-readable format.
local function pretty(val)
  if type(val) == 'table' then
    output:write('{\n')
    for k, v in pairs(val) do
      if type(k) == 'string' then
        output:write('  ["'..k..'"]='..tostring(v)..'\n')
      else
        output:write('  ['..tostring(k)..']='..tostring(v)..'\n')
      end
    end
    output:write('}\n')
  else
    output:write(tostring(val)..'\n')
  end
end

local function display(...)
  local out = {}
  for i, v in ipairs({...}) do
    table.insert(out, tostring(v))
  end
  output:write(table.concat(out, '\t'))
  output:write('\n')
end

-- Evaluate some code and print the result or error to stdout
local function dostring(code)
  local chunk, err = loadstring(code, 'stdin', nil, env)
  if chunk == nil then
    return err
  end

  local function results(...)
    if select(1, ...) then
      return select(2, ...)
    end
  end  

  return results(xpcall(chunk, function(e) output:write(e..'\n') end))
end

-- Eval and print a code chunk.
local function show(code)
  pretty(dostring('return '..code))
  return true
end

-- Eval and print a code chunk. 
local function eval(code)
  local result = dostring(code)
  if result then
    print(result)
  end
  return true
end

-- Move one level up the stack.
local function up()
  level = level+1
  return true
end

-- Move one level down the stack.
local function down()
  level = level-1
  return true
end

-- Print all the variables at the current scope (stack level)
local function locals()
  local level = startlevel()+level
  local i = 1
  while true do 
    name, v = debug.getlocal(level, i)
    if name == nil then
      return true
    else
      output:write(name..'\t'..tostring(v)..'\n')
    end
     i = i+1
  end  
  return true
end

-- Show a backtrace starting at the current level.
local function bt()
  output:write(debug.traceback('', startlevel()))
  output:write('\n')
  return true
end

-- Continue execution of the program
local function cont()
  return false
end

local function kill()
  os.exit(1)
end

function step()
  debug.sethook(start, 'l')
  return false
end

-- Run the debugger interpreter. Loads chunks one line at a time, and executes
-- the chunk in a special environment that exposes debug primitives.
function start(e, line)
  if e == 'line' then
    local info = debug.getinfo(2, 'Sf')
    if info.func == step then return end
    if info.func == start then return end
    print(string.format('%s:%d', info.short_src, line), getline(info.short_src, line))
    debug.sethook()
  elseif e then
    output:write(debug.traceback(e))
    output:write('\n')
  end

  level = 0
  local continue = true
  while continue do
    output:write('> ')
    output:flush()

    local line = input:read('*line')
    if line == '' then line = lastcmd end
    lastcmd = line
    
    continue = match(line) {
      {':up', up},
      {':down', down},
      {':locals', locals},
      {':bt', bt},
      {':show%s*(.*)', show},
      {':cont', cont},
      {':step', step},
      {':next', step},
      {':kill', kill},
      {':list', list},
      {'(.*)', eval},
    }
  end
end

-- Returns a local or upvalue variable
local function getvar(t, k)
  return getlocal(k) or getupvalue(k) or _G[k]
end

-- Sets a local or upvalue variable
local function setvar(t, k, v)
  if not setlocal(k, v) and not setupvalue(k, v) then
    output:write('error: no local or upvalue: "'..k..'"\n')
  end
end

setmetatable(env, {__index=getvar, __newindex=setvar})

return {
  start=start,
}
