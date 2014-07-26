/*
    开发常用函数库 V1.0
    @Author: oldman
    @Date: 2014-7-22 21:53
 */

var MyUtil = function(){};

/*
    获取X到Y之间的一个随机数
    X,Y必须是数字
    X不能为空,Y可以为空，Y为空时，返回的值为0~~~X
 */
MyUtil.prototype.randomXToY = function(x , y){
    if( x == null && y == null )
        throw "MyUtil error: randomXToY(x , y) --> x and y must not null!";
    if( x == null )
        throw "MyUtil error: randomXToY(x , y) --> x must not null!";
    if( x != null && isNaN(x) && y == null ){
        return Math.round(  x*Math.random() );
    }
    if( isNaN(x) || isNaN(y) ){
        throw "MyUtil error: randomXToY(x , y) --> x or y must be a number!";
    }
    return Math.round( (y - x)*Math.random() ) + x;
};

//数组函数拓展，判断数组中是否包含此元素
Array.prototype.contains = function (elem) {
    for (var i = 0; i < this.length; i++) {
        if (this[i] == elem) {
            return true;
        }
    }
    return false;
}

var myUtil = new MyUtil();