local class = require 'ext.class'

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
	if Stat:isa(v) then
		self.count = self.count + v.count
		local changeRatio = v.count / self.count
		self.min = math.min(self.min, v.min)
		self.max = math.max(self.max, v.max)
		self.avg = self.avg + (v.avg - self.avg) * changeRatio
		-- should calc stddev be done manually, for performance?
		-- or a flag for automatically doing it?
		-- same, flag for automatically accumulating the average-of-squares ?
		self.sqavg = self.sqavg + (v.sqavg - self.sqavg) * changeRatio
		self:calcStdDev()
	elseif type(v) == 'number' then
		self.count = self.count + 1
		self.min = math.min(self.min, v)
		self.max = math.max(self.max, v)
		self.avg = self.avg + (v - self.avg) / self.count
		-- same questions as above
		self.sqavg = self.sqavg + (v * v - self.sqavg) / self.count
		self:calcStdDev()
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

-- convenient holder of multiple stats in a k=v table
local Set = class()

local table = require 'ext.table'
function Set:init(...)
	self.stats = table()
	for i=1,select('#', ...) do
		self.stats[i] = Stat()
		self.stats[i].name = select(i, ...)
	end
end

function Set:accum(...)
	for i=1,select('#', ...) do
		self.stats[i]:accum( (select(i, ...)) )
	end
end

function Set:__tostring()
	local str = table()
	for _,stat in ipairs(self.stats) do
		str:insert(stat.name..' = '..stat)
	end
	return str:concat'\n'
end

Stat.Set = Set

return Stat
