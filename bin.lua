local class = require 'ext.class'
local range = require 'ext.range'
local math = require 'ext.math'

local Bin = class()

function Bin:init(min, max, count)
	self.min = min
	self.max = max
	self.bins = range(count):mapi(function() return 0 end)
end

function Bin:accum(v)
	local n = #self.bins
	local i = math.clamp(n * (v - self.min) / (self.max - self.min), 0, n-1) + 1
	self.bins[i] = self.bins[i] + 1
end

function Bin:__tostring()
	return require 'ext.tolua'(self.bins)
end

return Bin
