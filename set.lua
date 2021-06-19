local class = require 'ext.class'
local table = require 'ext.table'
local Stat = require 'stat'

-- convenient holder of multiple stats in a k=v table
local Set = class()

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
		str:insert(stat.name..' = {'..stat..'},')
	end
	return str:concat'\n'
end

return Set
