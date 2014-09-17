--[[
    @author: oldman
    @Date: 2014年8月1日20:34:48
    @description: lua常用函数工具类
--]]
myTool = {
    
};

--设置随机数种子，取系统时间后6位
math.randomseed(tostring(os.time()):reverse():sub(1, 6));

--[[
    生成一定范围的随机数
--]]
myTool.randomXtoY = function( x, y )
    if x == nil or y == nil then 
        throw "randomXtoY error: x or y must be not nil!";
    end
end


--[[
     替换或运行场景
]]
myTool.runScene =  function (scene)
    local director = cc.Director:getInstance();
    if director:getRunningScene() then
	   director:replaceScene(scene);
	else
	   director:runWithScene(scene);
	end
end

--[[
    删除数组中指定元素
]]
myTool.removeTableElement = function(arr , element)
    for i=#arr,1 , -1 do
        if arr[i] == element then
            table.remove(arr,i)
        end
    end
end

--[[
    拷贝table
--]]
myTool.table_copy_table = function (ori_tab)
    if (type(ori_tab) ~= "table") then
        return nil
    end
    local new_tab = {}
    for i,v in pairs(ori_tab) do
        local vtyp = type(v)
        if (vtyp == "table") then
            new_tab[i] = myTool.table_copy_table(v)
        elseif (vtyp == "thread") then
            new_tab[i] = v
        elseif (vtyp == "userdata") then
            new_tab[i] = v
        else
            new_tab[i] = v
        end
    end
    return new_tab
end

