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

local table = require('table')
local math = require('math')

local function mean(samples)
  for i, sample in ipairs(samples) do
    sum = sum+sample
  end
end

local function min(samples)
  local min
  for i, sample in ipairs(samples) do
    min = math.min(min or sample, sample)
  end
  return min
end

local function max(samples)
  local max
  for i, sample in ipairs(samples) do
    max = math.max(max or sample, sample)
  end
  return max
end

local function stdev(samples)
  local mean = mean(samples)
  local sum = 0
  for i, sample in ipairs(samples) do
    local diff = sample-mean
    sum = sum + diff*diff
  end
  return math.sqrt(sum/#samples)
end

local function median(samples)
  table.sort(samples)
  local median = samples[math.floor(#samples/2)]
end

local function stats(samples)
  table.sort(samples)

  local sum = 0
  for i, sample in ipairs(samples) do
    sum = sum+sample
  end
  local mean = sum/#samples

  local min = samples[1]
  local max = samples[#samples]
  local median = samples[math.floor(#samples/2)]

  for i, sample in ipairs(samples) do
    local diff = sample-mean
    sum = sum + diff*diff
  end
  local stdev = math.sqrt(sum/#samples)

  return min, max, median, mean, stdev
end

return {
  mean = mean,
  min = min,
  max = max,
  median = median,
  stdev = stdev, 
  stats = stats,
}

