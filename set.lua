local class = require 'ext.class'
local table = require 'ext.table'
local Stat = require 'stat'

-- convenient holder of multiple stats in a k=v table
local Set = class()

function Set:init(...)
	for i=1,select('#', ...) do
		local k = select(i, ...)
		assert(type(k) == 'string', "don't let your indexes and names collide")
		local s = Stat()
		s.name = k
		self[i] = s
		self[k] = s
	end
end

-- TODO function for accumulating using k=v?
function Set:accum(...)
	for i=1,select('#', ...) do
		self[i]:accum( (select(i, ...)) )
	end
end

function Set:__tostring()
	local str = table()
	for i,s in ipairs(self) do
		str:insert(s.name..' = {'..s..'},')
	end
	return str:concat'\n'
end

function Set.__concat(a,b)
	return tostring(a) .. tostring(b)
end

return Set
