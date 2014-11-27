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

