package = "ext"
version = "dev-1"
source = {
	url = "git+https://github.com/thenumbernine/stat-lua"
}
description = {
	summary = "Stats calculator.",
	detailed = "Stats calculator.",
	homepage = "https://github.com/thenumbernine/stat-lua",
	license = "MIT"
}
dependencies = {
	"lua >= 5.1",
}
build = {
	type = "builtin",
	modules = {
		["stat.bin"] = "bin.lua",
		["stat"] = "stat.lua",
		["stat.set"] = "set.lua",
	}
}
