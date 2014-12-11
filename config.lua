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

display = {
  vsync = true,
  width = 2560,
  height = 1440,
  width = 1920,
  height = 1200,
  fullscreen = false,
}

log = {
  cpu = false,
  memory = false,
}

chunk = {
  cachesize = 8,
  size = 64,
  pitch = 2,
}

key = {
  accel = "i",
  brake = "j",
  mine = "m",
  attack = "space",
  inspect = "enter",
  inventory = "u",
  zoomin = "add",
  zoomout = "subtract",
}

mouse = {
  attack = "left",
  action = "right",
  click = "left",
  alt = "right",
}

process = {
  'RigidBody',
  'Camera',
  'UserThrustControl',
  'UserYawControl',
  'UserFireControl',
  'Thruster',
  'Launcher',
  'Drag',
  'Lifetime',
  'Armor',
  'Group',
  'Model',
  'Target',
  'EngineFlame',
  'EngineTrail',
  'Beam',
  'Sparks',
  'Explosion',
  'Sun',
  'ChunkCache',
}

preload = {
  'texture/Blue.png',
  'texture/BulletYellow.png',
  'texture/DestroyerHullDiffuse.png',
  'texture/ExplosionGold.png',
  'texture/Flame2Gold.png',
  'texture/GradientYellow.png',
  'texture/IncandescentGold.png',
  'texture/IncandescentOrange.png',
  'texture/White.png',

  'mesh/Dagger.obj',
  'mesh/Debris0.obj',
  'mesh/Debris1.obj',
  'mesh/Debris2.obj',
  'mesh/Destroyer.obj',
  'mesh/EscapePod.obj',
  'mesh/Fighter.obj',
  'mesh/LightShapes.obj',
  'mesh/Missile.obj',
  'mesh/Quad.obj',
  'mesh/LargeRock0.obj',
  'mesh/LargeRock1.obj',
  'mesh/SmallRock0.obj',
  'mesh/SmallRock1.obj',
  'mesh/MediumRock0.obj',
  'mesh/MediumRock1.obj',

  'material/Dagger.mtl',
  'material/Debris0.mtl',
  'material/Debris1.mtl',
  'material/Debris2.mtl',
  'material/Destroyer.mtl',
  'material/EscapePod.mtl',
  'material/Fighter.mtl',
  'material/LightShapes.mtl',
  'material/Missile.mtl',
  'material/Quad.mtl',
  'material/LargeRock0.mtl',
  'material/LargeRock1.mtl',
  'material/SmallRock0.mtl',
  'material/SmallRock1.mtl',
  'material/MediumRock0.mtl',
  'material/MediumRock1.mtl',
}

