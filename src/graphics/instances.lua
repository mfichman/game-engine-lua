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

local vec = require('vec')
local gl = require('gl')
local struct = require('graphics.struct')

local Buffer = require('graphics.buffer')
local Instance = require('graphics.instance')

local Instances = {}; Instances.__index = Instances

-- Creates a new set of mesh instances. Each instance is a mesh with its own
-- world transform.  All instances in an instance set use the same texture,
-- material, mesh, and shader, so that they can all be drawn in the same batch.
-- This increases efficiency by reducing the number of draw calls that the
-- renderer needs to issue.
function Instances.new(args)
  assert(args.model, 'no model set for instances')
  local handle = gl.Handle(gl.glGenVertexArrays, gl.glDeleteVertexArrays)
  local self = {
    model = args.model,
    clearMode = args.clearMode or 'manual',
    instance = Buffer(gl.GL_ARRAY_BUFFER, gl.GL_DYNAMIC_DRAW, 'graphics_Instance'),
    handle = handle,
    id = handle[0],
  }
  self.model.mesh:sync()
  self.instance:sync()

  gl.glBindVertexArray(self.id)
  -- First, bind the normal mesh vertices and indices, as is done with a single
  -- non-instanced mesh.
  gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, self.model.mesh.index.id)
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.model.mesh.vertex.id)
  struct.defAttribute('graphics_MeshVertex', 0, 'position')
  struct.defAttribute('graphics_MeshVertex', 1, 'normal')
  struct.defAttribute('graphics_MeshVertex', 2, 'tangent')
  struct.defAttribute('graphics_MeshVertex', 3, 'texcoord')
  -- Bind the world transform as rotation (quaternion) and position.
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.instance.id)
  struct.defAttribute('graphics_Instance', 4, 'rotation')
  struct.defAttribute('graphics_Instance', 5, 'origin')
  -- Advance the instance array once per cycle through the index buffer.
  gl.glVertexAttribDivisor(4, 1)
  gl.glVertexAttribDivisor(5, 1)
  gl.glBindVertexArray(0)

  return setmetatable(self, Instances)
end

function Instances:sync()
  self.instance:sync()
end

function Instances:visible()
  return self.instance.count > 0
end

return Instances.new
