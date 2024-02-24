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
	self.count = count
	for i=1,count do
		self[i] = 0
	end
end

function Bin:accum(v)
	if v ~= v then return end	-- no nans at all, sorry.  inf maybe, take it up with .clamp
	local n = self.count
	local i = math.floor(n * (v - self.min) / (self.max - self.min))
	if self.clamp then
		i = math.clamp(i, 0, n-1)
	end
	if i < 0 or i >= n then return end
	i = i + 1
	self[i] = self[i] + 1
end

-- get the bounds of the 1-based i'th bin
function Bin:getBinBounds(i)
	local bmin = (i-1) / self.count * (self.max - self.min) + self.min
	local bmax = i / self.count * (self.max - self.min) + self.min
	return bmin, bmax
end

function Bin:__tostring()
	return require 'ext.tolua'(self)
end

function Bin.__concat(a,b)
	return tostring(a) .. tostring(b)
end

-- get length of a single bin
function Bin:getDx()
	return (self.max - self.min) / self.count
end

-- don't calc unless you ask for it
-- get the left and right boundaries of each bin
function Bin:getCenters()
	local dx = self:getDx()
	return range(self.count):mapi(function(i)
		return (i - .5) * dx + self.min
	end)
end

function Bin:normalize()
	local sum = 0
	for i=1,self.count do
		sum = sum + self[i]
	end
	for i=1,self.count do
		self[i] = self[i] / sum
	end
end

-- returns the data - centers vs counts - in a gnuplot text format
function Bin:getTextData()
	return self:getCenters():mapi(function(center,i)
		return center..'\t'..self[i]
	end):concat'\n'
end

return Bin
