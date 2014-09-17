require "Cocos2d"
require "Cocos2dConstants"
require "DataModel"
local TowerFactory = require "TowerFactory"
local monsterClass = require "monsterClass"

local DesertScene = class("DesertScene",function()
    return cc.Scene:create()
end)

function DesertScene:create(sceneInfo)
    DataModel.clear()
    local scene = DesertScene.new()
    scene.isPause = false
    scene.READY = 1
    scene.COUNTDOWN = 2
    scene.CREATING = 3
    scene.PLAYING = 4
    scene.OVER = 5
    scene.gameMode =  scene.READY
    scene.wave = 1
    scene.sceneIndex = sceneInfo.sceneIndex
    scene.totalWave = sceneInfo.totalWave
    scene.allowTower = sceneInfo.allowTower
    scene.model = DataModel.getModel()
    scene.allowTower = {"tower_rocket.png","tower_shit.png","tower_sun.png"}
    scene.model.scene = scene
    local function onNodeEvent(event)
        if "enter" == event then
            scene:onEnter(sceneInfo)
        elseif "exit" == event then
            scene:onExit()
        end
    end
    scene:registerScriptHandler(onNodeEvent)
    return scene
end

function DesertScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
end

function DesertScene:onEnter(sceneInfo)
    local towerArr = self.model.towerArr
    local monsterArr = self.model.monsterArr
    local node = cc.Layer:create()
    self.rootNode = node
    self:addChild(node)
    
    self:createMap(sceneInfo.map)
    
    self:createTopPanel(sceneInfo.gold)
    
    self:createBuildPanel(sceneInfo.allowTower)
    
    self:createOverPanel()
    
    local obj = require("goddnessLayer")
    local goddnessLayer = obj:create()
    self.goddnessLayer = goddnessLayer
    node:addChild(goddnessLayer,10)
    local wayPoints = self.model.wayPoints
    self.goddnessLayer:createGoddness(wayPoints[#wayPoints])
    
    local function onUpdate(dt)
    	if self.gameMode == self.READY then
    	   self:countDown()   --进入场景时倒计时
        elseif self.gameMode == self.COUNTDOWN then
        
        elseif self.gameMode == self.CREATING then
            self:createMonsterWave()  --倒计时结束，开始产生怪物，或者是下一波来临，也要产生怪物
    	elseif self.gameMode == self.PLAYING then
            self:checkBullet()
        elseif self.gameMode == self.OVER then
            
    	end
    end
    
    self.rootNode:scheduleUpdateWithPriorityLua(onUpdate,1)
end

function DesertScene:onExit()
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.countDownID)
	self.rootNode:unscheduleUpdate()
	local towerArr = DataModel.getModel().towerArr
    for var=1, #towerArr do
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(towerArr[var].scheduleID)
	end
end

function DesertScene:createMap(mapName)
    local model = self.model
    local map = cc.TMXTiledMap:create(mapName)
    local mapLayer = map:getLayer("group")
    self.rootNode:addChild(map,2)
    local borobjects = map:getObjectGroup("bornPoint")
    local bornPoint = borobjects:getObject("bornPoint")
    local wayObject = map:getObjectGroup("wayPoints")
    local wayPoints = wayObject:getObjects()
    self.map = map
    model.bornPoint = bornPoint
    model.wayPoints = wayPoints
        
    local function onTouchBegan(touch , event)
        local panel = self.rootNode:getChildByName("levelUpPanel")
        if panel ~= nil then
            panel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,0),cc.CallFunc:create(function()
                panel:removeFromParent(true)
            end)))
            return
        end
        local towerArr = DataModel.getModel().towerArr
        local location = touch:getLocation()
        for var=1, #towerArr do
            local tower = towerArr[var]
            if cc.rectContainsPoint(towerArr[var]:getBoundingBox(),location) then
                tower:displayLevelUp()
                return
            end
        end
        local touchLocation = self:getMapCoord(location)
        local tile = mapLayer:getTileAt(touchLocation)
        local tilePosX ,tilePosY = tile:getPosition()
        tilePosX = tilePosX + tile:getContentSize().width/2
        tilePosY = tilePosY + tile:getContentSize().height/2
        local gid = mapLayer:getTileGIDAt(touchLocation)
        if gid~= nil then
            local prop = map:getPropertiesForGID(gid)
            if type(prop) == "table" then
                if prop["droppable"] == "1" then
                    print("建造防御塔")
                    self:displayBuildPanel(cc.p(tilePosX,tilePosY))
                    return
                end
            end
        end
    end

    local dispatcher = mapLayer:getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:setSwallowTouches(true)
    dispatcher:addEventListenerWithSceneGraphPriority(listener,mapLayer)
end

function DesertScene:createTopPanel(gold)
	local topPanel = ccs.GUIReader:getInstance():widgetFromJsonFile("publish/topPanel_1.json")
    local size = topPanel:getContentSize()
    topPanel:setPosition(cc.p((self.origin.x+self.visibleSize.width - size.width) /2,self.origin.y+self.visibleSize.height - size.height))
    self.goldLabel = ccui.Helper:seekWidgetByName(topPanel,"goldLabel")
    self.waveLabel = ccui.Helper:seekWidgetByName(topPanel,"waveLabel")
    self.menuBtn = ccui.Helper:seekWidgetByName(topPanel,"menuBtn")
    self.startBtn = ccui.Helper:seekWidgetByName(topPanel,"startBtn")
    self.pauseBtn = ccui.Helper:seekWidgetByName(topPanel,"pauseBtn")
    self.goldLabel:setString(gold)
    
    local function back()
        local obj = require("StartScene")
        local scene = obj:create()
    --    local tranScene = cc.TransitionZoomFlipAngular:create(1, scene, cc.TRANSITION_ORIENTATION_RIGHT_OVER )
        cc.Director:getInstance():replaceScene(scene)
    end
    self.menuBtn:addTouchEventListener(back)
    self.waveLabel:setString(string.format("%d/%d",self.wave,self.totalWave))
    
    local function pause()
        self.isPause = true
    	local actionManager = cc.Director:getInstance():getActionManager()
    	local monsterArr = DataModel.getModel().monsterArr
        for var=1, #monsterArr do
            actionManager:pauseTarget(monsterArr[var])
    	end
        self.startBtn:setVisible(true)
    	self.pauseBtn:setVisible(false)
    end
    self.pauseBtn:addTouchEventListener(pause)
    
    local function resume()
        self.isPause = false
        local actionManager = cc.Director:getInstance():getActionManager()
        local monsterArr = DataModel.getModel().monsterArr
        for var=1, #monsterArr do
            actionManager:resumeTarget(monsterArr[var])
        end
        self.startBtn:setVisible(false)
        self.pauseBtn:setVisible(true)
    end
    self.startBtn:addTouchEventListener(resume)
    self:addChild(topPanel,200)
end

function DesertScene:createBuildPanel(obj)
	local buildPanel = cc.Sprite:createWithSpriteFrameName("select_01.png")
    local size = buildPanel:getContentSize()
	local menu = cc.Menu:create()
	menu:setName("menu")
	local function createTower(param,target)
	    if not target.disable then
            local pos = cc.p(buildPanel:getPosition())
            local tower = TowerFactory:getTower(target.id,pos)
            self.rootNode:addChild(tower,1000)
            buildPanel:runAction(cc.ScaleTo:create(0.2,0))
            self:useGold(target.gold)
	    end
	end
    for var=1, #obj do
		local towerObj = obj[var]
        local item = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrameName(string.format(towerObj["icon"],1)),nil)
        item.icon = towerObj["icon"]
        item.id = towerObj["id"]
        item.gold = towerObj["gold"]
        item:setPosition(0,0)
        item:registerScriptTapHandler(createTower)
        menu:addChild(item)
	end
	menu:alignItemsHorizontally()
    menu:setPosition(size.width/2,size.height+30)
	buildPanel:addChild(menu)
	buildPanel:setPosition(100,100)
    self.rootNode:addChild(buildPanel,100)
	buildPanel:setScale(0)
    buildPanel:setName("buildPanel")
    self.buildPanel = buildPanel
end


function DesertScene:createOverPanel()
    local overPanel = ccs.GUIReader:getInstance():widgetFromJsonFile("publish/gameOver_1.json")
    self.selectSceneBtn = ccui.Helper:seekWidgetByName(overPanel,"selectSceneBtn")
    self.retryBtn = ccui.Helper:seekWidgetByName(overPanel,"retryBtn")
    self.waveLabel1 = ccui.Helper:seekWidgetByName(overPanel,"waveLabel1")
    self.waveLabel2 = ccui.Helper:seekWidgetByName(overPanel,"waveLabel2")
    self.honor = ccui.Helper:seekWidgetByName(overPanel,"honor")
    self.waveCount = ccui.Helper:seekWidgetByName(overPanel,"waveCount")
    self.loseImg = ccui.Helper:seekWidgetByName(overPanel,"loseImg")
    local size = overPanel:getContentSize()
    overPanel:setPosition(cc.p(self.origin.x + self.visibleSize.width/2 - size.width/2 , self.origin.y - size.height))
    overPanel:setVisible(false)
    self.overPanel = overPanel
    self:addChild(overPanel,1000)
    
    
    local function retry(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local obj = require("DesertScene")
            local scene = obj:create(DataModel.getModel().sceneObj[self.sceneIndex])
            cc.Director:getInstance():replaceScene(scene)
        end
    end
    self.retryBtn:addTouchEventListener(retry)
    
    local function select(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local scene = require("StartScene")
            local gameScene = scene.create()
            cc.Director:getInstance():replaceScene(gameScene)
        end
    end
    self.selectSceneBtn:addTouchEventListener(select)
end

function DesertScene:displayBuildPanel(pos)
    local panel = self.buildPanel
    local menus = self.buildPanel:getChildByName("menu"):getChildren()
    local curGold = self:getGold()
    for key, menu in ipairs(menus) do
        local iconNum = 1
        local disable = false
        if menu["gold"] > curGold then
            iconNum = 0
            disable = true
        end
        menu:setNormalImage(cc.Sprite:createWithSpriteFrameName(string.format(menu.icon,iconNum)))
        menu.disable = disable
    end
    local scale = 0
    if panel:getScale() ~= 1 then
        panel:setPosition(pos)
        scale = 1
    end
    panel:runAction(cc.ScaleTo:create(0.2,scale))
end

function DesertScene:addGold(gold)
    local goldLabel = self.goldLabel
    local curGold = tonumber(goldLabel:getString())
    goldLabel:setString(curGold+gold)
end

function DesertScene:useGold(gold)
    local goldLabel = self.goldLabel
    local curGold = tonumber(goldLabel:getString())
    goldLabel:setString(curGold-gold)
end

function DesertScene:getGold()
    return tonumber(self.goldLabel:getString())
end

function DesertScene:createMonsterWave()
    local model = self.model
    local monsterArr = model.monsterArr
    local bornPoint = model.bornPoint
    local wayPoints = model.wayPoints
	local count = self.wave * 2 + 1
    local actionManager = cc.Director:getInstance():getActionManager()
    for var=1, count do
        local monster = monsterClass:create(bornPoint,self.wave%2+1)
        monster.life = self.wave + 1
        local actionTable = {}
        for i=1, #wayPoints do
            local distance = nil;
            local speed = monster.speed
            if i == 1 then
                distance = cc.pGetDistance(cc.p(bornPoint["x"],bornPoint["y"]),cc.p(wayPoints[1]["x"],wayPoints[1]["y"]))
            else
                distance = cc.pGetDistance(cc.p(wayPoints[i]["x"],wayPoints[i]["y"]) , cc.p(wayPoints[i-1]["x"],wayPoints[i-1]["y"]))
            end
            local moveAction = cc.MoveTo:create(distance/speed,cc.p(wayPoints[i]["x"],wayPoints[i]["y"]))
            table.insert(actionTable,#actionTable+1,moveAction)
        end
        local seq = cc.Sequence:create(actionTable)
        local callback1 = cc.CallFunc:create(function()
            monster:setVisible(true)
        end)
        local callback2 = cc.CallFunc:create(function() monster:boom(false); self.goddnessLayer:loseLife(); end)
        local finalAction = cc.Speed:create(cc.Sequence:create(cc.DelayTime:create(var*0.4), callback1 ,seq , callback2),1)
        finalAction:setTag(888)
        self:addChild(monster)
        actionManager:addAction(finalAction,monster,true)
	end
    self.gameMode = self.PLAYING
end

function DesertScene:getMapCoord(point)
    local tileSize = self.map:getTileSize()
    local touchLocation = cc.p(math.floor(point.x/tileSize.width) , math.floor((self.visibleSize.height - point.y)/tileSize.height))
    return touchLocation
end

function DesertScene:countDown()
	self.gameMode =  self.COUNTDOWN
	local flag = 3
	local function changeGameMode()
	    local picName = string.format("countdown_0%d.png",flag)
	    flag = flag - 1
        local sprite = cc.Sprite:createWithSpriteFrameName(picName)
        sprite:setScale(2)
        sprite:setPosition(self.visibleSize.width/2,self.visibleSize.height/2)
        self:addChild(sprite,100)
        local fadeOut = cc.FadeOut:create(1)
        local seq = cc.Sequence:create(fadeOut,cc.CallFunc:create(function()
            sprite:removeFromParent(true)
            if flag == -1 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.countDownID)
                self.gameMode = self.CREATING
            end
        end))
        sprite:runAction(seq)
	end
    self.countDownID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(changeGameMode,1,false)
end

--[[
    检测怪物是否全部死了，是的话进入下一波
--]]
function DesertScene:checkMonsterArr()
    local monsterArr = self.model.monsterArr
	if #monsterArr == 0 then
        if self.wave == self.totalWave then
            print("胜利")
            self:gameOver(false)
            return
        end
	   self.wave = self.wave + 1
	   local scheduleID
	   
	   local function nextWave()
          print(string.format("进入第%d波",self.wave))
          self.waveLabel:setString(string.format("%d/%d",self.wave,self.totalWave))
          self.gameMode = self.CREATING
          cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
	   end
       scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(nextWave,1,false)
	end
end

function DesertScene:checkBullet()
	local bulletArr = self.model.bulletArr
    local monsterArr = self.model.monsterArr
    for i=#bulletArr, 1 , -1 do
        local bullet = bulletArr[i]
    	for j=#monsterArr , 1 , -1 do
            local monster = monsterArr[j]
            local monsterBox = monster:getBoundingBox()
            local bulletBox = bullet:getBoundingBox()
            if monster ~= nil and bullet ~= nil and cc.rectIntersectsRect(monsterBox,bulletBox) then
                if bullet.type == 3 then
                    local slowAction = cc.Director:getInstance():getActionManager():getActionByTag(888,monster)
                    if slowAction and slowAction:getSpeed() == 1 then
                        slowAction:setSpeed(bullet.slow)
                        local callback = cc.CallFunc:create(function()
                            slowAction:setSpeed(1)
                        end)
                        monster:runAction(cc.Sequence:create(cc.DelayTime:create(bullet.slowTime ),callback))
                    end
                end
                monster:loseLife(bullet.damage)
                bullet:removeFromParent(true)
                table.remove(bulletArr,i)
    	   end
    	end
    end
end

function DesertScene:gameOver(flag)
    self.rootNode:unscheduleUpdate()
	self.gameMode = self.OVER
	if flag then
       self.loseImg:setVisible(flag)
       self.honor:setVisible(not flag)
	end
	self.waveCount:setString(self.totalWave)
    local w = math.modf(self.wave/10)
    self.waveLabel1:setString(w)
    self.waveLabel2:setString(self.wave%10)
	self.overPanel:setVisible(true)
    local size = self.overPanel:getContentSize()
    self.overPanel:runAction(cc.MoveTo:create(1,cc.p(self.origin.x + self.visibleSize.width/2 - size.width/2 , self.origin.y + self.visibleSize.height/2 - size.height/2)))
end

return DesertScene