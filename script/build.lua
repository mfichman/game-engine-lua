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

build.lib { 
  'BulletCollision',
  'BulletSoftBody',
  'BulletDynamics',
  'LinearMath',
  'BulletMultiThreaded'
}

if ffi.os == 'Windows' then
  build.libpath { 'C:\\WinBrew\\lib' }
  build.include {'C:\\WinBrew\\include'}
  build.include {'C:\\WinBrew\\include\\Bullet'}
else
  build.include {'/usr/local/include/Bullet'}
end
build.module('physics')

