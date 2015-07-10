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

debug = true

display = {
  vsync = true,
  width = 1680,
  height = 1100,

--  width = 2400,
--  height = 1600,
--  width = 1200,
--  height = 800,
  fullscreen = false,
}

render = {
  shadowMapSize = 4096,
}

log = {
  cpu = false,
  memory = false,
}

zone = {
  seed = 100939191,
  size = 1024, -- each block is 1024 m^3
}

chunk = {
  cacheSize = 64, 
  size = 24,
}

key = {
  accel = 'i',
  move = 'a',
  brake = 'k',
  mine = 'm',
  attack = 'space',
  inspect = 'enter',
  inventory = 'u',
  zoomIn = 'add',
  zoomOut = 'subtract',
}

mouse = {
  attack = 'left',
  action = 'right',
  click = 'left',
  alt = 'right',
}

process = {
  'Entity',
  'RigidBody',
  'Camera',
  'UserControl',
  'Move',
  'Thrust',
  'Launch',
  'Mine',
  'Drag',
  'Lift',
  'Lifetime',
  'Armor',
  'Group',
  'Terrain',
  'Model',
  'InstancedModel',
  'Target',
  'EngineFlame',
  'EngineTrail',
  'Beam',
  'Sparks',
  'Stars',
  'Grid',
  'Explosion',
  'Sun',
  'Hud',
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
  'mesh/LargeRock0.obj',
  'mesh/LargeRock1.obj',
  'mesh/LightShapes.obj',
  'mesh/MediumRock0.obj',
  'mesh/MediumRock1.obj',
  'mesh/Missile.obj',
  'mesh/Quad.obj',
  'mesh/SmallRock0.obj',
  'mesh/SmallRock1.obj',

  'material/Dagger.mtl',
  'material/Debris0.mtl',
  'material/Debris1.mtl',
  'material/Debris2.mtl',
  'material/Destroyer.mtl',
  'material/EscapePod.mtl',
  'material/Fighter.mtl',
  'material/LargeRock0.mtl',
  'material/LargeRock1.mtl',
  'material/LightShapes.mtl',
  'material/MediumRock0.mtl',
  'material/MediumRock1.mtl',
  'material/Missile.mtl',
  'material/Quad.mtl',
  'material/SmallRock0.mtl',
  'material/SmallRock1.mtl',
}

