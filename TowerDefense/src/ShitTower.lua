require "Cocos2d"
require "Cocos2dConstants"

local ShitTower = class("ShitTower",function()
    return cc.Sprite:create()
end)

function ShitTower:create(pos)
    local towerArr = DataModel.getModel().towerArr
    local monsterArr = DataModel.getModel().monsterArr
    local tower = ShitTower.new()
    tower.range = 120
    tower.level = 1
    tower.bulletSpeed = 400
    tower.damage = 1
    tower.slow = 0.5  --减速系数
    tower.slowTime = 3 --减速时间
    tower.attackInterval = 0.8
    tower.picName = "Shit%d1.png"
    tower.bulletPicName = "PShit%d2.png"
    tower.levelUpGold = {260,320,0}
    tower.sellGold = {128,256,352}
    tower.levelUpPicArr = {"upgrade_%s260.png","upgrade_%s320.png","upgrade_%s0_CN.png"}
    tower.sellPicArr = {"sell_128.png","sell_256.png","sell_352.png"}
    tower:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(tower.picName,tower.level)))
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

function ShitTower:fire(monsterPos)
    local bulletArr = DataModel.getModel().bulletArr
    local towerPos = cc.p(self:getPosition())
    local subPoint = cc.pSub(towerPos,monsterPos)
    local deg = math.deg(math.atan2(subPoint.y , subPoint.x))
    local normalVector = cc.pNormalize(subPoint)
    local range = self.range
    local overshotVector = cc.p(normalVector.x * range,normalVector.y * range)
    local offscreenPoint = cc.pSub(towerPos , overshotVector)
    local time = cc.pGetDistance(towerPos,offscreenPoint)/self.bulletSpeed
    local bullet = cc.Sprite:createWithSpriteFrameName(string.format(self.bulletPicName,self.level))
    bullet.damage = self.damage
    bullet.type = 3
    bullet.slow = self.slow
    bullet.slowTime = self.slowTime
    bullet:setRotation(180+90 - deg)
    bullet:setPosition(towerPos)

    local function removeBullet()
        bullet:removeFromParent(true)
        myTool.removeTableElement(bulletArr,bullet)
    end

    local seq = cc.Sequence:create(cc.MoveTo:create(time,offscreenPoint),cc.CallFunc:create(removeBullet))
    bullet:runAction(seq)
    self:getParent():addChild(bullet,10)
    table.insert(bulletArr,#bulletArr+1,bullet)
    bullet:retain()
end

function ShitTower:displayLevelUp()
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
        self.range = self.range + 50
        self.slow = self.slow - 0.1
        self:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(self.picName,self.level)))
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


return ShitTower