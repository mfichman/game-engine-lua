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

local loaders = {
  ['%.png$'] = require('asset.texture'),
  ['%.jpg$'] = require('asset.texture'),
  ['%.gif$'] = require('asset.texture'),
  ['%.obj$'] = require('asset.model'),
  ['%.mtl$'] = require('asset.material'),
  ['%.prog$'] = require('asset.program'),
  ['%.vert$'] = require('asset.shader'),
  ['%.geom$'] = require('asset.shader'),
  ['%.frag$'] = require('asset.shader'),
  ['%.ttf$'] = require('asset.font'),
}

local loaded = require('asset.loaded')

local function open(name, ...)
  local path = table.concat({name, ...})
  if loaded[path] then return loaded[path] end
  for pattern, loader in pairs(loaders) do
    if name:match(pattern) then
      local asset = loader.open(name, ...)
      loaded[path] = asset
      return asset
    end
  end
  error('no loader found for '..name)
end

return {
  open = open,
  texture = require('asset.texture'),
  model = require('asset.model'),
  material = require('asset.material'),
  program = require('asset.program'),
  shader = require('asset.shader'),
  loaded = loaded,
}

