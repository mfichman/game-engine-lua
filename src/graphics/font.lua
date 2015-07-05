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

local ffi = require('ffi')
local freetype = require('freetype')
local vec = require('vec')
local bit = require('bit')
local gl = require('gl')
local bit = require('bit')
local math = require('math')

local Font = {}; Font.__index = Font

local library = ffi.new('FT_Library[1]')
if freetype.FT_Init_FreeType(library) ~= 0 then
  error('could not initialize font library')
end

--[[ FIXME: Don't free until file is unloaded
ffi.gc(library, function(library) 
  freetype.FT_Done_FreeType(library[0])  
end)
]]

local function loadFixed(self)
  -- FreeType measures font size in units of 1/64 pixel.  So we multiply the 
  -- height by 64 to get the right size
  local bitmapSize = self.size

  -- Border around each glyph in the atlas, to prevent bleeding 
  local border = 20
  local dpi = 96

  local ftWidth = bitmapSize*64
  local ftHeight = bitmapSize*64
  freetype.FT_Set_Char_Size(self.face[0], ftWidth, ftHeight, dpi, dpi)
  local glyph = self.face[0].glyph

  -- Line height, in pixels. The glyph x/y/width/height is adjusted by this value, so that
  -- the origin is retranslated to the top of the line height value.
  local lineHeight = tonumber(self.face[0].size.metrics.height)/64/bitmapSize
  
  local atlasWidth = border
  local atlasHeight = 0

  local minY = math.huge

  -- Estimate the size of the texture atlas
  for i=32,128 do
    if freetype.FT_Load_Char(self.face[0], i, freetype.FT_LOAD_RENDER) ~= 0 then
      error('could not load font glyph: '..self.name)
    end
    atlasWidth = atlasWidth+glyph.bitmap.width/bitmapSize*self.size+border
    atlasHeight = math.max(atlasHeight, glyph.bitmap.rows/bitmapSize*self.size+2*border)
    minY = math.min(1-glyph.bitmap_top/bitmapSize/lineHeight, minY)
  end

  local clearBuffer = ffi.new('GLubyte[?]', atlasWidth*atlasHeight)
  gl.glBindTexture(gl.GL_TEXTURE_2D, self.id)
  gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_RED, atlasWidth, atlasHeight, 0, gl.GL_RED, gl.GL_UNSIGNED_BYTE, clearBuffer)

  -- Generate the texture atlas
  local x = border
  local y = border

  for i=32,128 do
    if freetype.FT_Load_Char(self.face[0], i, freetype.FT_LOAD_RENDER) ~= 0 then
      error('could not load font glyph: '..self.name)
    end

    local bitmap = glyph.bitmap
    local pixelWidth = bitmap.width/bitmapSize*self.size
    local pixelHeight = bitmap.rows/bitmapSize*self.size
    local texWidth = pixelWidth/atlasWidth
    local texHeight = pixelHeight/atlasHeight

    --local emScale = bitmapRows*bitmapSize

    self.glyph[i] = {
      texX = x/atlasWidth,
      texY = y/atlasHeight,
      texWidth = texWidth,
      texHeight = texHeight,
      advanceX = tonumber(glyph.advance.x)/64/bitmapSize/lineHeight,
      advanceY = tonumber(glyph.advance.y)/64/bitmapSize/lineHeight,
      width = bitmap.width/bitmapSize/lineHeight,
      height = bitmap.rows/bitmapSize/lineHeight,
      x = glyph.bitmap_left/bitmapSize/lineHeight,
      y = 1-glyph.bitmap_top/bitmapSize/lineHeight-minY,
    }
    
    gl.glTexSubImage2D(gl.GL_TEXTURE_2D, 0, x, y, bitmap.width, bitmap.rows, gl.GL_RED, gl.GL_UNSIGNED_BYTE, bitmap.buffer)

    if glyph.advance.y ~= 0 then
      error('invalid font: non-zero y-advance')
    end
    x = x+pixelWidth+border
  end

  gl.glGenerateMipmap(gl.GL_TEXTURE_2D)
end

local function loadSdf(self)
end

-- Initialize a new font with the given size and kind. The font 'kind' may be 
-- either 'sdf' for scalable signed distance field font rendering, or 'fixed'
-- for fixed fonts.
function Font.new(name, size, kind)
  local self = {
    name = name,
    size = size,
    kind = kind,
    handle = gl.Handle(gl.glGenTextures, gl.glDeleteTextures),
    face = ffi.new('FT_Face[1]'),
    glyph = {},
  }
  self.id = self.handle[0]

  gl.glBindTexture(gl.GL_TEXTURE_2D, self.id)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR_MIPMAP_NEAREST)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP_TO_EDGE)
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP_TO_EDGE)
  gl.glPixelStorei(gl.GL_UNPACK_ALIGNMENT, 1)

  if freetype.FT_New_Face(library[0], name, 0, self.face) ~= 0 then
    error('could not initialize font: '..name)
  else
    ffi.gc(self.face, function(face) 
      freetype.FT_Done_Face(face[0])
    end)
  end

  self = setmetatable(self, Font)

  if self.kind == 'fixed' then
    loadFixed(self)
  elseif self.kind == 'sdf' then
    loadSdf(self)
  else
    error('invalid font kind: '..self.kind)
  end

  return self
end

-- Return the kerning for the font given the previous & current characters
function Font:kerning(prev, cur) 
    local prevIndex = freetype.FT_Get_Char_Index(self.face[0], prev)
    local curIndex = freetype.FT_Get_Char_Index(self.face[0], cur)
    local delta = ffi.new('FT_Vector[1]')
    freetype.FT_Get_Kerning(self.face[0], prevIndex, curIndex, freetype.FT_KERNING_DEFAULT, delta)
    local x = bit.rshift(tonumber(delta[0].x), 6)
    local y = bit.rshift(tonumber(delta[0].y), 6)
    return vec.Vec2(x/self.size, y/self.size)
end

return Font.new
