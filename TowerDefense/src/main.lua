
require "Cocos2d"

-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    
    cc.FileUtils:getInstance():addSearchPath("src")
    cc.FileUtils:getInstance():addSearchPath("res")
    cc.FileUtils:getInstance():addSearchPath("publish")
--    cc.Director:getInstance():getOpenGLView():setFrameSize(768,576)
    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1024, 768, cc.ResolutionPolicy.SHOW_ALL)
--    cc.Director:getInstance():setDisplayStats(false)
    --------------------------------------------------
    local SpriteFrameCache = cc.SpriteFrameCache:getInstance()
    SpriteFrameCache:addSpriteFrames("res/gameover0-hd.plist")
    SpriteFrameCache:addSpriteFrames("res/towers/TRocket-hd.plist")
    SpriteFrameCache:addSpriteFrames("towers/TShit-hd.plist")
    SpriteFrameCache:addSpriteFrames("towers/TSun-hd.plist")
    SpriteFrameCache:addSpriteFrames("Items00-hd.plist")
    SpriteFrameCache:addSpriteFrames("Items02.plist")
    SpriteFrameCache:addSpriteFrames("monster.plist")
    SpriteFrameCache:addSpriteFrames("res/wsparticle_p01.plist")
    SpriteFrameCache:addSpriteFrames("boss_bullet.plist")
    
    local arr = {'a','b','c','d'};
    for key, var in pairs(arr) do
        local animation = cc.Animation:create();
        animation:setDelayPerUnit(0.1);
        for i = 1 , 8 do
            local frame = string.format("%s_00%d.png",var,i)
            local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(frame);
            animation:addSpriteFrame(sp);
        end
        cc.AnimationCache:getInstance():addAnimation(animation,"boom"..key);
    end
    
    local animation1 = cc.Animation:create();
    animation1:setDelayPerUnit(0.2);
    local aniSp1 = cc.SpriteFrameCache:getInstance():getSpriteFrame("m_monster_g_0001.png");
    local aniSp2 = cc.SpriteFrameCache:getInstance():getSpriteFrame("m_monster_g_0002.png");
    local aniSp3 = cc.SpriteFrameCache:getInstance():getSpriteFrame("m_monster_g_0003.png");
    animation1:addSpriteFrame(aniSp1);
    animation1:addSpriteFrame(aniSp2);
    animation1:addSpriteFrame(aniSp3);
    cc.AnimationCache:getInstance():addAnimation(animation1,"monsterAnimation1");

    local animation2 = cc.Animation:create();
    animation2:setDelayPerUnit(0.3);
    local aniSp1 = cc.SpriteFrameCache:getInstance():getSpriteFrame("m_monster_g1_0001.png");
    local aniSp2 = cc.SpriteFrameCache:getInstance():getSpriteFrame("m_monster_g1_0002.png");
    local aniSp3 = cc.SpriteFrameCache:getInstance():getSpriteFrame("m_monster_g1_0003.png");
    animation2:addSpriteFrame(aniSp1);
    animation2:addSpriteFrame(aniSp2);
    animation2:addSpriteFrame(aniSp3);
    cc.AnimationCache:getInstance():addAnimation(animation2,"monsterAnimation2");
        
    for i=1, 3 do
        local animation = cc.Animation:create();
        animation:setDelayPerUnit(0.1);
    	for j=1, 5 do
            local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("PSun%d%d.png",i,j));
            animation:addSpriteFrame(sp);
    	end
        cc.AnimationCache:getInstance():addAnimation(animation,string.format("sunAnimation%d",i));
    end
    
    --------------------------------------------------
        
    --create scene 
    local scene = require("StartScene")
    local gameScene = scene.create()
    
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
