local class = require 'ext.class'
local range = require 'ext.range'
local math = require 'ext.math'

--[[
flags:
clamp = clamp indexes instead of discarding oob
--]]
local Bin = class()

function Bin:init(min, max, count)
	self.min = min
	self.max = max
	self.bins = range(count):mapi(function() return 0 end)
end

function Bin:accum(v)
	if v ~= v then return end	-- no nans at all, sorry.  inf maybe, take it up with .clamp
	local n = #self.bins
	local i = math.floor(n * (v - self.min) / (self.max - self.min))
	if self.clamp then
		i = math.clamp(i, 0, n-1)
	end
	if i < 0 or i >= n then return end
	i = i + 1
	self.bins[i] = self.bins[i] + 1
end

function Bin:__tostring()
	return require 'ext.tolua'(self.bins)
end

function Bin.__concat(a,b)
	return tostring(a) .. tostring(b)
end

return Bin
