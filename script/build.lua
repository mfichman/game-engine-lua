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

package.path = './src/?.lua;./src/?/init.lua;'..package.path

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

