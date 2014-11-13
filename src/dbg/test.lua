local dbg = require('dbg')
local w = 'foo'


function wrap() 
  dbg.start()
  local z = 3
  function foo() 
    local x = 1
    local y = 2
    local foo = {x=1, y=2, z={}}
  
  
    bob.bill = 0
    print(x, y, z, foo)
    w = 10
  end
  foo()
  print(z)
end

xpcall(wrap, dbg.start)

