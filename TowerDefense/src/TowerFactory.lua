local RocketTower = require "RocketTower"
local SunTower = require "SunTower"
local ShitTower = require "ShitTower"
local TowerFactory = {}

function TowerFactory:getTower(id,pos)
    local tower
	if id == 1 or id == "1" then
	   
    elseif id == 2 or id == "2" then
        tower = RocketTower:create(pos)
    elseif id == 3 or id == "3" then
        tower = ShitTower:create(pos)
    elseif id == 4 or id == "4" then
        tower = SunTower:create(pos)
	end
	return tower
end

return TowerFactory