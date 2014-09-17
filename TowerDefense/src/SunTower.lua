require "Cocos2d"
require "Cocos2dConstants"

local SunTower = class("SunTower",function()
    return cc.Sprite:create()
end)

function SunTower:create(pos)
	local towerArr = DataModel.getModel().towerArr
    local monsterArr = DataModel.getModel().monsterArr
    local tower = SunTower.new()
    tower.range = 100
    tower.level = 1
    tower.bulletSpeed = 400
    tower.damage = 1
    tower.attackInterval = 1.2
    tower.picName = "Sun%d1.png"
    tower.facePicName = "Sun-1%d.png"
    tower.bulletPicName = "Rocket%d2.png"
    tower.levelUpGold = {260,320,0}
    tower.sellGold = {128,256,352}
    tower.levelUpPicArr = {"upgrade_%s260.png","upgrade_%s320.png","upgrade_%s0_CN.png"}
    tower.sellPicArr = {"sell_128.png","sell_256.png","sell_352.png"}
    tower:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(tower.picName,tower.level)))
    local size = tower:getContentSize()
    local face = cc.Sprite:createWithSpriteFrameName(string.format(tower.facePicName,tower.level))
    face:setName("face")
    face:setPosition(cc.p(size.width/2,size.height/2))
    tower:addChild(face)
    table.insert(towerArr,#towerArr+1,tower)
    tower:setPosition(pos)
    
    local function seekMonster()
        local isPause = DataModel.getModel().scene.isPause
        if not isPause then
            for i=1, #monsterArr do
                local monsterPos = cc.p(monsterArr[i]:getPosition())
                local distance = cc.pGetDistance(pos,monsterPos)
                if distance < tower.range then
                    tower:fire(monsterPos)
                    return;
                end
            end
        end
    end
    
    tower.scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(seekMonster,tower.attackInterval,false)
    return tower
end

function SunTower:fire(monsterPos)
    local monsterArr = DataModel.getModel().monsterArr
    local animate = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation(string.format("sunAnimation%d",self.level)))
    local sprite = cc.Sprite:create()
    sprite:setPosition(cc.p(self:getPosition()))
    
    local function checkBullet()
        for var=#monsterArr, 1, -1 do
            local monster = monsterArr[var]
            local towerPos = cc.p(self:getPosition())
            local distance = cc.pGetDistance(cc.p(monster:getPosition()),towerPos)
            if distance <= self.range then
                monster:loseLife(self.damage)
            end
        end
        sprite:removeFromParent(true)
    end
    
    local callback = cc.CallFunc:create(checkBullet)
    self:getParent():addChild(sprite,10)
    sprite:runAction(cc.Sequence:create(animate,callback))
end

function SunTower:displayLevelUp()
    local scene = DataModel.getModel().scene
    local levelupPanel = cc.Sprite:createWithSpriteFrameName("range_240.png")
    local size = levelupPanel:getContentSize()
    local pos = cc.p(self:getPosition())
    levelupPanel:setPosition(pos)
    levelupPanel:setScale(0)
    self:getParent():addChild(levelupPanel,20)
    levelupPanel:runAction(cc.ScaleTo:create(0.3,1))
    local symbol = ""
    local gold = scene:getGold()
    if gold < self.levelUpGold[self.level] and self.level < 3 then
        symbol = "-"
    end
    local levelUpMenu = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrameName(string.format(self.levelUpPicArr[self.level],symbol)),nil)
    local sellMenu = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrameName(self.sellPicArr[self.level]),nil)
    levelUpMenu:setPosition(0,size.height/4)
    sellMenu:setPosition(0,-size.height/4)

    local function levelUp()
        local scene = DataModel.getModel().scene
        scene:useGold(self.levelUpGold[self.level])
        self.level = self.level + 1
        self.damage = self.damage + 1
        self.range = self.range + 30
        self.attackInterval = self.attackInterval - 0.1
        self:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(self.picName,self.level)))
        self:getChildByName("face"):setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(self.facePicName,self.level)))
        levelupPanel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,0),cc.CallFunc:create(function()
            levelupPanel:removeFromParent(true)
        end)))
    end

    local sellGold = self.sellGold[self.level]
    local function sell()
        local towerArr = DataModel.getModel().towerArr
        local goldLabel = cc.Label:createWithTTF(string.format("+%d",sellGold),"fonts/Marker Felt.ttf",26)
        goldLabel:setColor(cc.c3b(255,255,0))
        goldLabel:setPosition(pos)
        scene:addChild(goldLabel)
        local goldMove = cc.MoveBy:create(0.8,cc.p(0,100));
        local goldFade = cc.FadeOut:create(0.8);
        local goldCallback = cc.CallFunc:create(function()
            goldLabel:removeFromParent(true)
        end)
        goldLabel:runAction(cc.Sequence:create(cc.Spawn:create(goldMove,goldFade),goldCallback))
        scene:addGold(sellGold)
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleID)
        self:removeFromParent(true)
        myTool.removeTableElement(towerArr,self)
        levelupPanel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,0),cc.CallFunc:create(function()
            levelupPanel:removeFromParent(true)
        end)))
    end

    if self.level < 3 and symbol ~= "-" then
        levelUpMenu:registerScriptTapHandler(levelUp)
    end
    sellMenu:registerScriptTapHandler(sell)
    local menu = cc.Menu:create(levelUpMenu,sellMenu)
    menu:setPosition(size.width/2 ,size.height/2)
    levelupPanel:setName("levelUpPanel")
    levelupPanel:addChild(menu)
end



return SunTower