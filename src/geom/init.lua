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

local ffi = require('ffi')
local vec = require('vec')

local Face = require('geom.face')

-- Generates an icosohedron, calling 'gen' for each generated triangle
local function icosohedron(gen)

  local t = (1.0 + math.sqrt(5.0)) / 2.0;

  local vertex = ffi.new('vec_Vec3[12]', {
    vec.Vec3(-1,  t,  0),
    vec.Vec3( 1,  t,  0),
    vec.Vec3(-1, -t,  0),
    vec.Vec3( 1, -t,  0),
    vec.Vec3( 0, -1,  t),
    vec.Vec3( 0,  1,  t),
    vec.Vec3( 0, -1, -t),
    vec.Vec3( 0,  1, -t),
    vec.Vec3( t,  0, -1),
    vec.Vec3( t,  0,  1),
    vec.Vec3(-t,  0, -1),
    vec.Vec3(-t,  0,  1),
  })
  
  local function triangle(i0, i1, i2)
    local face = Face{
      vertex0 = vertex[i0],
      vertex2 = vertex[i1],
      vertex1 = vertex[i2],
    }
    gen(face) 
  end

  -- 5 adjacent faces
  triangle(0, 11, 5)
  triangle(0, 5, 1)
  triangle(0, 1, 7)
  triangle(0, 7, 10)
  triangle(0, 10, 11)

  -- 5 adjacent triangles
  triangle(1, 5, 9)
  triangle(5, 11, 4)
  triangle(11, 10, 2)
  triangle(10, 7, 6)
  triangle(7, 1, 8)

  -- 5 triangles around point 3
  triangle(3, 9, 4)
  triangle(3, 4, 2)
  triangle(3, 2, 6)
  triangle(3, 6, 8)
  triangle(3, 8, 9)

  -- 5 adjacent triangles
  triangle(4, 9, 5)
  triangle(2, 4, 11)
  triangle(6, 2, 10)
  triangle(8, 6, 7)
  triangle(9, 8, 1)
end

-- Subdivides a triangular face ('face'). When a new face is generated, 
-- subdivide invokes the 'gen' function, passing the new face plus the
-- weight factor for each original vertex after billinear interpolation.
local function subdivide(face, levels, gen)
  if levels <= 0 then
    gen(face) -- gen(face, wv0, wv1, wv2) FIXME: Interpolate
  else
    local p0 = face.vertex0
    local p1 = face.vertex1
    local p2 = face.vertex2

    -- Calculate midpoint of each edge of the triangle
    local p01 = ((face.vertex0+face.vertex1)/2)
    local p12 = ((face.vertex1+face.vertex2)/2)
    local p20 = ((face.vertex2+face.vertex0)/2)

    subdivide(Face(p0, p01, p20), levels-1, gen)
    subdivide(Face(p1, p12, p01), levels-1, gen)
    subdivide(Face(p2, p20, p12), levels-1, gen)
    subdivide(Face(p01, p12, p20), levels-1, gen)
  end
end

return {
  Buffer = require('geom.buffer'),
  Face = require('geom.face'),
  Mesh = require('geom.mesh'),
  MeshVertex = require('geom.meshvertex'),
  icosohedron = icosohedron,
  subdivide = subdivide,
}


