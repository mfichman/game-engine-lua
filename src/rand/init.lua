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

local math = require('math')
local vec = require('vec')
local ffi = require('ffi')
local path = require('path')

local rand = path.load('rand')
ffi.cdef(path.open('rand/rand.h'):read('*all'))

-- Returns a random number in the range [min, max)
local function float(min, max)
  return min+(max-min)*math.random()
end

local function normal(mean, stdev)
  local x1, x2, w, y1, y2

  while true do
    x1 = 2 * float(0, 1) - 1
    x2 = 2 * float(0, 1) - 1
    w = x1*x1 + x2*x2
    if w < 1 then break end
  end

  w = math.sqrt((-2*math.log(w))/w)
  y1 = x1 * w
  y2 = x2 * w

  return stdev*y1+mean
end

local function int(min, max)
  return math.random(min, max)
end

local function sphere(radius)
  local r = float(0, radius)
  local phi = float(0, 2 * math.pi)
  local theta = float(0, math.pi)

  return vec.Vec3{
    x = r * math.sin(theta) * math.cos(phi),
    y = r * math.sin(theta) * math.sin(phi),
    z = r * math.cos(theta),
  }
end

local function fade(t) 
    return t * t * t * (t * (t * 6 - 15) + 10)
end

local function lerp(t, a, b)
    return a + t * (b - a)
end

local function grad(hash, x, y, z)  
  local h = bit.band(hash, 15) -- CONVERT LO 4 BITS OF HASH CODE 
  local u = h < 8 and x or y -- INTO 12 GRADIENT DIRECTIONS. 
  local v = h < 4 and y or ((h==12 or h==14) and x or z)
  return (bit.band(h, 1) == 0 and u or -u) + (bit.band(h, 2) == 0 and v or -v)
end

-------------------------------------------------------------------------------
-- Initialization for perlin noise implementation
local permutation = { 151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,
  21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,
  35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,
  74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,
  230,220,105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,
  80,73,209,76,132,187,208,89,18,169,200,196,135,130,116,188,159,86,
  164,100,109,198,173,186,3,64,52,217,226,250,124,123,5,202,38,147,
  118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,223,
  183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,
  172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,
  218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,
  145,235,249,14,239,107,49,192,214,31,181,199,106,157,184,84,204,176,
  115,121,50,45,127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,
  141,128,195,78,66,215,61,156,180
}
local p = ffi.new('int[512]')
for i=0,255 do
  p[256+i] = permutation[i+1]
  p[i] = permutation[i+1]
end
-------------------------------------------------------------------------------

local function perlin(x, y, z)
  return rand.rand_perlin(x, y, z)
--[[
  local floor = math.floor
  local X = bit.band(floor(x), 255)             -- FIND UNIT CUBE THAT
  local Y = bit.band(floor(y), 255)             -- CONTAINS POINT.
  local Z = bit.band(floor(z), 255)
  local x = x - floor(x)                           -- FIND RELATIVE X,Y,Z
  local y = y - floor(y)                           -- OF POINT IN CUBE. 
  local z = z - floor(z)
  local u = fade(x)                      -- COMPUTE FADE CURVES 
  local v = fade(y)                      -- FOR EACH OF X,Y,Z.  
  local w = fade(z)
  local A = p[X]+Y
  local AA = p[A]+Z
  local AB = p[A+1]+Z -- HASH COORDINATES OF
  local B = p[X+1]+Y
  local BA = p[B]+Z
  local BB = p[B+1]+Z -- THE 8 CUBE CORNERS,
  return lerp(w, lerp(v,lerp(u, grad(p[AA], x, y, z),         -- AND ADD 
                       grad(p[BA], x-1, y, z)),               -- BLENDED *
                 lerp(u, grad(p[AB], x, y-1, z),              -- RESULTS 
                       grad(p[BB], x-1, y-1, z))),            -- FROM  8 
                 lerp(v, lerp(u, grad(p[AA+1], x, y, z-1 ),   -- CORNERS 
                       grad(p[BA+1], x-1, y, z-1)),           -- OF CUBE
                 lerp(u, grad(p[AB+1], x, y-1, z-1),
                       grad(p[BB+1], x-1, y-1, z-1))))
]]
end

local function noise(x, y, seed, options)
  return rand.rand_noise(x, y, seed, options)
--[[
  local n = 0
  local f = options.frequency or 1
  local a = options.amplitude or 1
  local lacunarity = options.lacunarity or 1
  local persistence = options.persistence or 1
  local bias = options.bias or .5
  local octaves = options.octaves or 1
  for i=1,octaves do
    n = n + a*perlin(x*f, y*f, (seed+i+bias)*f)
    --n = n + a*rand.rand_perlin(x*f, y*f, (seed+i+bias)*f)
    f = f * lacunarity
    a = a * persistence
  end
  return n 
]]
end

return {
  float = float,
  int = int,
  sphere = sphere,
  noise = noise,
  perlin = perlin,
  normal = normal,
}
