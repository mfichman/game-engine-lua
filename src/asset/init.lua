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
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, APEXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

local loaders = {
  ['%.png$']=require('asset.texture'),
  ['%.jpg$']=require('asset.texture'),
  ['%.gif$']=require('asset.texture'),
  ['%.obj$']=require('asset.mesh.obj'),
  ['%.prog']=require('asset.program'),
  ['%.vert']=require('asset.shader'),
  ['%.geom']=require('asset.shader'),
  ['%.frag']=require('asset.shader'),
}

local loaded = {}

local function open(k)
  if loaded[k] then return loaded[k] end
  for pattern, loader in pairs(loaders) do
    if k:match(pattern) then
      local asset = loader.open(k)
      loaded[k] = asset
      return asset
    end
  end
  error('no loader found for '..k)
end

return {
  open=open,
  texture=require('asset.texture'),
}

