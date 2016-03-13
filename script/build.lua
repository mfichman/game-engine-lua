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


local init = require('init')
local build = require('build')
local ffi = require('ffi')

if ffi.os == 'Windows' then
  build.libpath {os.getenv('LOCALAPPDATA')..'\\WinBrew\\lib'}
  build.include {os.getenv('LOCALAPPDATA')..'\\WinBrew\\include'}
  build.include {os.getenv('LOCALAPPDATA')..'\\WinBrew\\include\\Bullet'}
else
  build.libpath {'/usr/local/lib'}
  build.include {'/usr/local/include'}
  build.include {'/usr/local/include/Bullet'}
end

build.lib { 
  'BulletCollision',
  'BulletSoftBody',
  'BulletDynamics',
  'LinearMath',
}

if ffi.os == 'Windows' then
  build.lib {'lua51'}
else
  build.lib {'luajit-5.1.2'}
end

build.module('physics')
build.module('thread')
build.module('blob')
build.module('rand')
if ffi.os ~= 'Windows' then
  build.module('net')
end
