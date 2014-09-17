require "Cocos2d"
require "Cocos2dConstants"

local goddnessLayer = class("goddnessLayer",function()
    return cc.Layer:create()
end)

function goddnessLayer:create()
    local layer = goddnessLayer.new()
    
    local function onNodeEvent(event)
        if "enter" == event then
            layer:onEnter()
        end
    end
    layer:registerScriptHandler(onNodeEvent)
    return layer
end


function goddnessLayer:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
end

function goddnessLayer:onEnter()
    
end

function goddnessLayer:createGoddness(point)
    local goddness = cc.Sprite:create("crystal.png")
    self.goddness = goddness
    goddness:setPosition(point)
    goddness.life = 10
    goddness.isDead = false
    local hp = cc.Sprite:createWithSpriteFrameName(string.format("BossHP%d.png",goddness.life))
    self.hp = hp
    hp:setPosition(point.x , point.y + goddness:getContentSize().height/2 + 5)
    self:addChild(hp)
    self:addChild(goddness)
end

function goddnessLayer:loseLife()
    if not self.goddness.isDead then
       if self.goddness.life == 1 then
            self.goddness.isDead = true
            local scene = DataModel.getModel().scene
            scene:gameOver(true)
            local animate = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("boom1"))
            self.goddness:runAction(cc.Sequence:create(animate , cc.RemoveSelf:create()))
            self.hp:runAction(cc.RemoveSelf:create())
            return
        end
        self.goddness.life = self.goddness.life - 1
        self.hp:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("BossHP0%d.png",self.goddness.life)))
    end
end

return goddnessLayer