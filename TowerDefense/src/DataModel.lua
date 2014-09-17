DataModel = {}

local monsterArr = {}

local towerArr = {}

local bulletArr = {}

local wayPoints = {}

local bornPoint = {}

local scene = nil

local sceneObj = {}

local data = {monsterArr = monsterArr , towerArr = towerArr , bulletArr = bulletArr , wayPoints = wayPoints , bornPoint = bornPoint , scene = scene , sceneObj = sceneObj}

function DataModel.getModel()
    return data
end

function DataModel.clear()
	monsterArr = {}
    towerArr = {}
    bulletArr = {}
    wayPoints = {}
    bornPoint = {}
    scene = nil
    sceneObj = {}
end
