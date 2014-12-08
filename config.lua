-- Copyright (c) 2014 Matt Fichman
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

