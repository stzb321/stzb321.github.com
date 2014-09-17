require "Cocos2d"
require "Cocos2dConstants"

local monsterClass = class("monsterClass",function()
    return cc.Sprite:create()
end)

function monsterClass:create(bornPoint,type)
    local monsterArr = DataModel.getModel().monsterArr
    local monster = monsterClass.new()
    local animation
    if type == 1 then
        monster.life = 3
        monster.speed = 150
        monster:setScale(0.5)
        monster.gold = 16
        animation = cc.AnimationCache:getInstance():getAnimation("monsterAnimation1")
    elseif type == 2 then
        monster.life = 4
        monster.speed = 130
        monster:setScale(0.5)
        monster.gold = 18
        animation = cc.AnimationCache:getInstance():getAnimation("monsterAnimation2")
    end
    monster:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
    monster:setPosition(cc.p(bornPoint["x"],bornPoint["y"]))
    monster:setVisible(false)
    table.insert(monsterArr,#monsterArr+1,monster)
    return monster
end

function monsterClass:boom(flag)
    local monsterArr = DataModel.getModel().monsterArr
    local scene = DataModel.getModel().scene
    local animate = cc.AnimationCache:getInstance():getAnimation("boom3")
    local pos = cc.p(self:getPosition())
    local sprite = cc.Sprite:createWithSpriteFrameName("a_002.png")
    sprite:setPosition(pos)
    local action = cc.Sequence:create(cc.Animate:create(animate) , cc.CallFunc:create(function() sprite:removeFromParent(true) end))
    sprite:runAction(action)
    self:getParent():addChild(sprite)
    if flag then
        local goldLabel = cc.Label:createWithTTF(string.format("+%d",self.gold),"fonts/Marker Felt.ttf",26)
        goldLabel:setColor(cc.c3b(255,255,0))
        goldLabel:setPosition(pos.x , pos.y + self:getContentSize().height/2)
        scene:addChild(goldLabel)
        local goldMove = cc.MoveBy:create(0.8,cc.p(0,100));
        local goldFade = cc.FadeOut:create(0.8);
        local goldCallback = cc.CallFunc:create(function()
            goldLabel:removeFromParent(true)
        end)
        goldLabel:runAction(cc.Sequence:create(cc.Spawn:create(goldMove,goldFade),goldCallback))
        scene:addGold(self.gold)
    end
    self:removeFromParent(true)
    myTool.removeTableElement(monsterArr , self)
    scene:checkMonsterArr()
end

function monsterClass:loseLife(damage)
	local life = self.life
	if life - damage <= 0 then
        self:boom(true)
    else
        self.life = life - damage
	end
end

return monsterClass