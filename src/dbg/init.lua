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

local debug = require('debug')
local io = require('io')
local os = require('os')
local ffi = require('ffi')

local level = 1
local input = io.input()
local output = io.output()
local metatable = {}
local env = {}
local sources = {}
local lastcmd 
local start
local dump
local dumpref
local step

-- Returns the source line at line
local function getline(path, line)
  local source = sources[path]
  if not source then
    local fd = io.open(path)
    if not fd then
      return 'error: source not available'
    end
    source = {}
    for line in fd:lines() do
      table.insert(source, line)
    end
    sources[path] = source
    fd:close()
  end
  return source[line]
end

-- Returns the level of the 'start' function
local function startlevel()
  local level = 0
  while true do
    local info = debug.getinfo(level)
    if info.func == start then
      return level
    elseif info.func == dump then
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
      local k, f = unpack(case)
      local args = {line:match(k)}
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
  local f = debug.getinfo(level, 'f').func
  local i = 1
  while true do
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
        output:write('  ["'..k..'"] = '..tostring(v)..'\n')
      else
        output:write('  ['..tostring(k)..'] = '..tostring(v)..'\n')
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

local function list()
  local info = debug.getinfo(startlevel()+level, 'Slf')
  local line = info.currentline
  if info.short_src == '[C]' then
    print('error: source not available (C function)')
    return true
  end
  local text = {}
  local len = tostring(line+8):len()
  for i = -8,8 do
    local str = getline(info.short_src, line+i)
    if not str then
      break
    elseif i == 0 then
      table.insert(text, string.format('>> %'..len..'d | %s', line+i, str))
    else
      table.insert(text, string.format('   %'..len..'d | %s', line+i, str))
    end
  end
  print(table.concat(text, '\n'))
  return true
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
  local buf = {}
  local maxnamelen = 0
  while true do 
    name, v = debug.getlocal(level, i)
    if name == nil then
      break
    elseif name:match('%(.*%)') then
    else
      maxnamelen = math.max(maxnamelen, name:len()) 
      table.insert(buf, {name, tostring(v)})
    end
     i = i+1
  end  
  for i, pair in ipairs(buf) do
    local name, value = pair[1], pair[2]
    output:write(string.format('%-'..maxnamelen..'s  %s\n', name, value))
  end
  return true
end

-- Show a backtrace starting at the current level.
local function backtrace(msg)
  output:write(debug.traceback(msg or '', level+startlevel()))
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
    local info = debug.getinfo(2, 'Slf')
    if info.func == step then return end
    if info.func == start then return end
    debug.sethook()
    local info = debug.getinfo(2, 'Slf')
    local text = getline(info.short_src, line)
    output:write(string.format('%s:%d', info.short_src, line, text))
  elseif e then
    backtrace(e)
  else 
    local info = debug.getinfo(2, 'Slf')
    local line = info.currentline
    local text = getline(info.short_src, line)
    output:write(string.format('%s:%d: breakpoint\n', info.short_src, line, text))
  end

  level = 0
  local continue = true
  while continue do
    output:write('> ')
    output:flush()

    local line = input:read('*line')
    if not line then 
      output:write('\n')
      os.exit() 
    end
    if line == '' then line = lastcmd end
    lastcmd = line
    
    continue = match(line) {
      {':up', up},
      {':down', down},
      {':locals', locals},
      {':backtrace', backtrace},
      {':bt', backtrace},
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

-- Dump a value, and if the value is a table, recursively dump its fields.
local function dumpval(fd, index, v)
  local kind = type(v)
  if kind == 'string' then
    fd:uint8(string.byte('r'))
    fd:uint32(index[v])
    -- Intern strings to save memory
  elseif kind == 'table' then
    fd:uint8(string.byte('r'))
    fd:uint32(index[v])
  elseif kind == 'number' then
    fd:uint8(string.byte('n'))
    fd:number(v)
  elseif kind == 'boolean' then
    fd:uint8(string.byte('b'))    
    fd:boolean(v)
  else 
    fd:uint8(string.byte('r'))
    fd:uint32(index[tostring(v)])
    -- CDATA, opaque types, etc. Dump as strings
  end
end

-- Recursively dump a table and all its fields
local function dumptable(fd, index, t)
  if index[t] then return end
  local id = fd.id
  index[t] = id
  fd.id = id+1

  -- Forward-declare the table
  fd:uint8(string.byte('t'))
  fd:uint32(id) 
  fd:uint32(0)

  -- Output any tables/strings that this table references
  local n = 0
  for k,v in pairs(t) do
    dumpref(fd, index, k)
    dumpref(fd, index, v)
    n = n+1
  end

  -- Output the table definition
  fd:uint8(string.byte('t'))
  fd:uint32(id) 
  fd:uint32(n)

  for k,v in pairs(t) do
    dumpval(fd, index, k)
    dumpval(fd, index, v)
  end
end

-- Dump an interned string
local function dumpstr(fd, index, v)
  if index[v] then return end
  local id = fd.id
  index[v] = id
  fd.id = id+1
  fd:uint8(string.byte('s'))
  fd:uint32(id)
  fd:string(v) 
end

-- Dump a reference type (string or table)
function dumpref(fd, index, v)
  local kind = type(v)
  if kind == 'table' then
    dumptable(fd, index, v)
  elseif kind == 'string' then
    dumpstr(fd, index, v)
  elseif kind == 'number' then
    -- Do nothing
  elseif kind == 'boolean' then
    -- Do nothing
  else
    dumpstr(fd, index, tostring(v))
  end
end

-- Return all upvalues, as a table, with each upvalue indexed by name
local function getupvalues(level)
  local level = startlevel()+level
  local f = debug.getinfo(level, 'f').func
  local upvalues = {}
  local i = 1
  while true do
    local name, v = debug.getupvalue(f, i)
    if name == nil then
      break
    else
      upvalues[name] = v
      i = i+1
    end
  end
  return upvalues
end

-- Return all locals, as a table, with each local indexed by name
local function getlocals(level)
  local level = startlevel()+level
  local locals = {}
  local i = 1
  while true do
    local name, v = debug.getlocal(level, i)
    if name == nil then
      break
    else
      locals[name] = v
      i = i+1
    end
  end
  return locals
end

-- Return the stack frame at the given level
local function getframe(level) 
  local info = debug.getinfo(startlevel()+level)
  if info then
    return {
      info = info,
      upvalues = getupvalues(level),  
      locals = getlocals(level),
    }
  else 
    return nil
  end
end

-- Return the entire stack, including all locals and upvalues, as a single
-- table containing an entry for each frame.
local function getstack()
  local level = 0
  local stack = {}
  while true do
    local frame = getframe(level)
    if frame then
      table.insert(stack, frame)
      level = level+1
    else
      break 
    end
  end
  return stack
end

-- Create a 'core' dump for the process, by serializing all tables to disk,
-- starting with any variables on the stack.
function dump(e, line)
  -- Retrieve references to local variables for each stack frame and insert 
  -- that info into the core data table 
  local stack = getstack()

  -- Serialize the core data to disk
  local binfmt = require('binfmt')
  local fd = binfmt.Writer(io.open('core', 'w'))
  local index = {}
  local core = {
    trace = debug.traceback(e, 2),
    stack = stack,
  }
  fd.id = 1
  dumptable(fd, index, core)
  fd:close()
end

-- Read a value
local function readval(fd, index)
  local kind = string.char(fd:uint8())
  if kind == 's' then
    return fd:string()
  elseif kind == 'n' then
    return fd:number()
  elseif kind == 'b' then
    return fd:boolean()
  elseif kind == 'r' then
    local id = tonumber(fd:uint32())
    local ref = index[id]
    if not ref then start() end
    assert(ref)
    return ref
  else
    error('unknown type: '..string.byte(kind))
  end
end

-- Read an interned string
local function readstr(fd, index)
  local id = fd:uint32()
  local v = fd:string()
  index[id] = v
  return v 
end

-- Read a table
local function readtable(fd, index)
  local id = fd:uint32()
  local n = fd:uint32()
  local t = index[id] or {}
  index[id] = t

  for i=1,n do
    local k = readval(fd, index)
    local v = readval(fd, index) 
    t[k] = v
  end
  return t
end

-- Read a reference
local function readref(fd, index)
  local kind = string.char(fd:uint8())
  if kind == 't' then
    return readtable(fd, index)
  elseif kind == 's' then
    return readstr(fd, index)
  else
    error('unknown ref type: '..string.byte(kind))
  end

end

-- Read a core dump for a process
local function read(fd)
  local binfmt = require('binfmt')
  local fd = binfmt.Reader(fd)
  local index = {}
  local data
  while not fd:eof() do
    data = readref(fd, index)
  end
  fd:close()
  return data
end

-- Iterate over everything reachable from _G
local function memiter(f)
  local seen = {}
  local function memiter(t)
    if seen[t] then return end
    f(t)
    seen[t] = true
    for k,v in pairs(t) do
      if type(v) == 'table' then
        memiter(v)
      elseif type(v) == 'userdata' then
        f(v)
      elseif type(v) == 'cdata' then
        f(v)
      end
    end
  end
  memiter(_G)
end

-- Attempts to discover a human-readable description for t.  This is either the
-- location of the constructor, if present, or the mem address of the
-- metatable. For FFI types, the FFI type name is printed.
local function typeof(t)
  if type(t) == 'table' then
    local mt = getmetatable(t)
    if not mt then
      local keys = {}
      for k,v in pairs(t) do
        table.insert(keys,tostring(k))
      end
      return table.concat(keys,',')
    elseif type(mt.new) == 'function' then
      --local info = debug.getinfo(mt.new)
      --return info.source..':'..info.linedefined
      return mt
    else
      return mt
    end
  elseif type(t) == 'userdata' then
    return 'userdata'
  elseif type(t) == 'cdata' then
    return tostring(ffi.typeof(t))
  else
    return type(t)
  end
end

-- Print counts of each type of table (by looking at getmetatable)
local function memcount(f)
  local count = {}
  memiter(function(t) 
    local mt = typeof(t)
    count[mt] = (count[mt] or 0)+1
  end) 
  return count
end

-- Print the top 20 tables using the most memory
local function memtop(f)
  local count = memcount(f)
  local values = {}
  for k,v in pairs(count) do
    table.insert(values, {k,v})
  end
  table.sort(values, function(a,b) 
    return a[2]>b[2]
  end)
  for i=1,math.min(10,#values) do
    print(unpack(values[i]))
  end 
  print()
end

-- Begin logging execution of the process
local function log()
  local fd = assert(io.open('dbg.log','w'))
  local function step()
    fd:write(debug.traceback())
    fd:write('\n')
  end
  debug.sethook(step, 'l')
end

setmetatable(env, {__index = getvar, __newindex = setvar})

return {
  start = start,
  dump = dump,
  read = read,
  memiter = memiter,
  memcount = memcount,
  memtop = memtop,
  log = log,
}
