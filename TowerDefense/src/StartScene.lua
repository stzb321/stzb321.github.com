require "Cocos2d"
require "Cocos2dConstants"
require "myTool"
require "DataModel"

local StartScene = class("StartScene",function()
    return cc.Scene:create()
end)

function StartScene.create()
    local scene = StartScene.new()
    local function onNodeEvent(event)
        if "enter" == event then
            scene:onEnter()
        end
    end
    scene:registerScriptHandler(onNodeEvent)
    return scene
end


function StartScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
end

function StartScene:onEnter()
    local sceneStr = cc.FileUtils:getInstance():getStringFromFile("res/guanqia.json");
    local sceneObj = json.decode(sceneStr,1)
    DataModel.getModel().sceneObj = sceneObj
    self.maxInex = #sceneObj
    self.curIndex = 1
    local node = ccs.SceneReader:getInstance():createNodeWithSceneFile("publish/startScene.json");
    self:addChild(node)
    
    local startUI_panel = node:getChildByTag(10013):getChildByTag(1)
    self.startBtn = ccui.Helper:seekWidgetByName(startUI_panel,"startBtn")
    self.exitBtn = ccui.Helper:seekWidgetByName(startUI_panel,"exitBtn")
    self.leftBtn = ccui.Helper:seekWidgetByName(startUI_panel,"leftBtn")
    self.rightBtn = ccui.Helper:seekWidgetByName(startUI_panel,"rightBtn")
    self.ScrollView = ccui.Helper:seekWidgetByName(startUI_panel,"ScrollView")
    self.ScrollView:setInnerContainerSize(cc.size(#sceneObj*200,200))
    self.ScrollView:setTouchEnabled(false)
    self.ScrollView:setClippingEnabled(true)
    self.sceneIndex = 0
    
    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            
        elseif eventType == ccui.TouchEventType.moved then
            
        elseif eventType == ccui.TouchEventType.ended then
            local obj = require("DesertScene")
            local scene = obj:create(sceneObj[self.curIndex])
       --     local tranScene = cc.TransitionZoomFlipAngular:create(1, scene, cc.TRANSITION_ORIENTATION_LEFT_OVER )
            cc.Director:getInstance():replaceScene(scene)
        elseif eventType == ccui.TouchEventType.canceled then
            
        end
    end
    self.startBtn:addTouchEventListener(touchEvent)

    for i=1, #sceneObj do
        local obj = sceneObj[i]
        local sprite = cc.Sprite:create(obj.src,cc.rect(0,0,obj.width,obj.height))
        sprite:setAnchorPoint(0,0)
        sprite:setPosition((i-1)*obj.width,0)
        self.ScrollView:addChild(sprite)
    end
    local function leftFun(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self.ScrollView:scrollToPercentHorizontal(0,1,true)
            if self.curIndex > 1 then
                self.curIndex  = self.curIndex - 1
            end
        end
    end
    
    local function rightFun(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self.ScrollView:scrollToPercentHorizontal(100,1,true)
            if self.curIndex < self.maxInex then
                self.curIndex  = self.curIndex + 1
            end
        end
    end
    
    local function exitFun()
        cc.Director:getInstance():endToLua()
    end
    self.leftBtn:addTouchEventListener(leftFun)
    self.rightBtn:addTouchEventListener(rightFun)
    self.exitBtn:addTouchEventListener(exitFun)
end

return StartScene
