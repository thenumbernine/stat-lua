local class = require 'ext.class'
local math = require 'ext.math'
local table = require 'ext.table'

--[[
flags for this class:
calcStdDevManually = don't auto recalc stddev upon each accumulation
	so the user can just calc them once at the end of data accumulation
onlyFinite = set this to ignore non-finite numbers (infinity, nan)
--]]
local Stat = class()

function Stat:init()
	self.min = math.huge
	self.max = -math.huge
	self.avg = 0
	self.sqavg = 0
	self.stddev = 0
	self.count = 0
end

-- calculate average of squares from the average and stddev
function Stat:calcSqAvg()
	self.sqavg = self.stddev * self.stddev + self.avg * self.avg
end

-- calculate the stddev from the average and the average of squares
function Stat:calcStdDev()
	self.stddev = math.sqrt(self.sqavg - self.avg * self.avg)
end

--[[
v = the value
--]]
function Stat:accum(v)
	if self.onlyFinite and not math.isfinite(v) then return end
	if Stat:isa(v) then
		self.count = self.count + v.count
		local changeRatio = v.count / self.count
		self.min = math.min(self.min, v.min)
		self.max = math.max(self.max, v.max)
		self.avg = self.avg + (v.avg - self.avg) * changeRatio
		self.sqavg = self.sqavg + (v.sqavg - self.sqavg) * changeRatio
		if not self.calcStdDevManually then
			self:calcStdDev()
		end
	elseif type(v) == 'number' then
		self.count = self.count + 1
		self.min = math.min(self.min, v)
		self.max = math.max(self.max, v)
		self.avg = self.avg + (v - self.avg) / self.count
		self.sqavg = self.sqavg + (v * v - self.sqavg) / self.count
		if not self.calcStdDevManually then
			self:calcStdDev()
		end
	else
		error("don't know how to accumulate this object")
	end
end

function Stat:__tostring()
	local s = table()
	for _,k in ipairs{'min', 'max', 'avg', 'sqavg', 'stddev', 'count'} do
		s:insert(k..' = '..self[k])
	end
	return s:concat', '
end

function Stat.__concat(a,b)
	return tostring(a) .. tostring(b)
end

return Stat
