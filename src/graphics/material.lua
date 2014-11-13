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

local vec = require('vec')

local Material = {}; Material.__index = Material

function Material.new(args)
  local self = setmetatable({}, Material)
  local args = args or self
  self.diffuseMap = args.diffuseMap
  self.specularMap = args.specularMap
  self.normalMap = args.normalMap
  self.emissiveMap = args.emissiveMap
  self.ambientColor = args.ambientColor or vec.Vec4(0, 0, 0, 1)
  self.diffuseColor = args.diffuseColor or vec.Vec4(1, 1, 1, 1)
  self.specularColor = args.specularColor or vec.Vec4(1, 1, 1, 1)
  self.emissiveColor = args.emissiveColor or vec.Vec4(0, 0, 0, 1)
  self.hardness = args.hardnesss or 40
  self.opacity = args.opacity or 1
  self.blendMode = args.blendMode or 'alpha'
  return self
end

return Material.new
