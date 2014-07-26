//
// CleanerScoreScene class
//
var starPic = { blue :"chuan1.png", green :"baichi.png", purple:"xiaoq.png", red:"wcm.png", yellow:"aresfly.png"};
var colorArr = ["blue" , "green" , "purple", "red", "yellow"];
var selectedStar = new Array();

var MainLayer = function () {
    this.starArray = null;
    this.rowNum = 10;
    this.colNum = 10;
    this.initHeight = 600;  //初始下落高度
    this.space = 5;
    this.starWH = 67;
};

MainLayer.prototype.onDidLoadFromCCB = function () {

    if (sys.platform == 'browser') {
        this.onEnter();
    }
    else {
        this.rootNode.onEnter = function () {
            this.controller.onEnter();
        };
    }

    this.rootNode.onTouchesBegan = function (touches, event)
    {
        this.controller.onTouchesBegan(touches, event);
        return true;
    };

    this.rootNode.onTouchesMoved = function (touches, event)
    {
        this.controller.onTouchesMoved(touches, event);
        return true;
    };
    this.rootNode.onTouchesEnded = function (touches, event)
    {
        this.controller.onTouchesEnded(touches, event);
        return true;
    };

    this.rootNode.setTouchEnabled(true);
};

MainLayer.prototype.onEnter = function () {
    cc.SpriteFrameCache.getInstance().addSpriteFrames("res/face_packer.plist");
    this.initStarTable();
    if( !this.checkDead ){
        cc.BuilderReader.runScene("","MainLayer");
    }
};

MainLayer.prototype.onUpdate = function () {

};

MainLayer.prototype.onExit = function () {

};

MainLayer.prototype.onTouchesBegan = function(touches, event){

};

MainLayer.prototype.onTouchesMoved = function(touches, event){

};

MainLayer.prototype.onTouchesEnded = function(touches, event){
    var pos = touches[0].getLocation();
    var star = this.checkPoint(this.starArray , pos);
//    if( star != null ){
//        star.setScale(1.1);
//    }
    if( star != null ){
        if( selectedStar.length > 1 && selectedStar.contains(star) ){
            this.destroyStar(selectedStar);
            selectedStar.length = 0;
        }else{
            if( selectedStar.length != 0 ){
                for( var x = 0 ; x < selectedStar.length ; x++ ){
                    selectedStar[x].setScale(1);
                }
                selectedStar.length = 0;
            }
            this.seekSameStar(star , selectedStar);
            if( selectedStar.length > 1 ){
                for( var x = 0 ; x < selectedStar.length ; x++ ){
                    selectedStar[x].setScale(1.1);
                }
            }
        }
    }
};

//初始化星星表格
MainLayer.prototype.initStarTable = function(){
    this.starArray = new Array();
    for( var i = 0 ; i < this.rowNum ; i ++ ){
        var rowArray = new Array();
        for( var j = 0 ; j < this.colNum ; j ++ ){
            var star = this.getRandomStar(i,j);
            if( star != null )
                rowArray[j] = star;
        }
        this.starArray[i] = rowArray;
    }
};

MainLayer.prototype.getRandomStar = function(rowIndex , colIndex){
    var color = colorArr[myUtil.randomXToY(0 , colorArr.length -1)];
    cc.log(starPic[color]);
    var sprite = cc.Sprite.createWithSpriteFrameName(starPic[color]);
    sprite.starData = { rowIndex : rowIndex , colIndex : colIndex , color: color };
    sprite.setAnchorPoint(cc.p(0.5,0.5));
    var x = ( colIndex +1 )*this.space + ( this.starWH * (colIndex + 1/2) ) ;
    var y = ( rowIndex +1 )*this.space + ( this.starWH * (rowIndex + 1/2) );
    sprite.setPosition(cc.p( x , y + this.initHeight ));
    var time = ( rowIndex +1 )/10;
    var move = cc.MoveBy.create(time , cc.p(0, -this.initHeight));
    sprite.runAction(move);
    this.rootNode.addChild(sprite);
    return sprite;
};

//检测是否死局,只比较当前星星的右边和上边
MainLayer.prototype.checkDead = function(){
    for( var i = 0 ; i < this.starArray.length ; i++ ){
        var row = this.starArray[i];
        for( var j = 0 ; j < row.length ; j ++){
            var sprite = row[j];
            var right = this.starArray[i][j+1];
            var top = this.starArray[i+1][j];
            if( right != null && right != undefined ){
                if( right.starData.color == sprite.starData.color ){
                    return false;
                }
            }
            if( top != null && top != undefined ){
                if( top.starData.color == sprite.starData.color ){
                    return true;
                }
            }
        }
    }
    cc.log("dead!");
    return true;
};

//判断一个位置是否在精灵元素上
MainLayer.prototype.checkPoint = function(array , point){
    for( var i = 0 ; i < array.length ; i++ ){
        var c = array[i];
        if( c == null )
            continue;
        if( c instanceof Array == true ){
            var p = this.checkPoint(c , point);
            if( p != null )
                return p;
        }else{
            var pos = c.getPosition();
            var rect = cc.rect(pos.x - this.starWH/2 , pos.y - this.starWH/2 ,this.starWH , this.starWH );
            if( cc.rectContainsPoint(rect , point) ){
                return c;
            }
        }
    }
};

//寻找相邻相同的星星,递归调用
MainLayer.prototype.seekSameStar = function(star , arr){
    var rowIndex = star.starData.rowIndex,
        colIndex = star.starData.colIndex,
        color = star.starData.color;
    var leftStar = this.starArray[rowIndex][colIndex-1],
        rightStar = this.starArray[rowIndex][colIndex+1],
        topStar ,
        downStar;
    if( !arr.contains(star) ){
        arr.push(star);
    }
    rowIndex +1 >= this.starArray.length ? topStar = undefined : topStar = this.starArray[rowIndex+1][colIndex];  //是否超出边界检测
    rowIndex -1 < 0 ? downStar = undefined : downStar = this.starArray[rowIndex-1][colIndex];  //是否超出边界检测
    if( leftStar && leftStar.starData.color == color ){
        if( !arr.contains(leftStar) ){
            arr.push(leftStar);
            this.seekSameStar(leftStar , arr);
        }
    }
    if( rightStar && rightStar.starData.color == color ){
        if( !arr.contains(rightStar) ){
            arr.push(rightStar);
            this.seekSameStar(rightStar , arr);
        }
    }
    if( topStar && topStar.starData.color == color ){
        if( !arr.contains(topStar) ){
            arr.push(topStar);
            this.seekSameStar(topStar , arr);
        }
    }
    if( downStar && downStar.starData.color == color ){
        if( !arr.contains(downStar) ){
            arr.push(downStar);
            this.seekSameStar(downStar , arr);
        }
    }

};

//消灭星星
MainLayer.prototype.destroyStar = function (sameArr) {
    for( var i = 0 ; i < sameArr.length ; i++){
        var sprite = sameArr[i],
            pos = sprite.getPosition(),  //这里出错了，估计是数组里存在相同的元素
            x = pos.x,
            y = pos.y,
            rowIndex = sprite.starData.rowIndex,
            colIndex = sprite.starData.colIndex;
        var particle = cc.StarParticle.create(this.rootNode , x, y  , "spark");
        //闭包回调，不闭包的话会只清除for循环的最后一个粒子
        (function(par){
            var callbackFun = cc.CallFunc.create(function(){
                //    particle.removeFromParent();
                par.cleanuped = true;
                par.removeFromParent(true);
            });
            var seq = cc.Sequence.create(cc.DelayTime.create(0.8) , callbackFun);
            par.runAction(seq);
        })(particle);
        this.rootNode.removeChild(sprite);
        this.starArray[rowIndex][colIndex] = -1;  //消除标识
    }
    this.fallStar();
//    this.print();
};

//消除星星后粒子下落
MainLayer.prototype.fallStar = function(){
    var nullCol = new Array(); //被消灭完的一列,后面的列需要合并到前面
    for( var i = 0 ; i < this.colNum ; i++ ){
        var count = 0;  //这一列需要下落多少个单位
        var starNum = 0; //这一列星星的个数
        for( var j = 0 ; j < this.rowNum ; j++ ){
            var star = this.starArray[j][i];
            if( star == null )
                continue;
            if( star == -1 ){
                count++ ;
            }else{
                starNum++;
                if( count != 0 ){
                    var move = cc.MoveBy.create(0.3 , cc.p(0, count*(-this.starWH - this.space)));
                    if( star == null && star == -1 ){
                        cc.log("nullstar is in row:"+j+" , col:"+i);
                    }
                    star.runAction(move);
                    this.starArray[j-count][i] = star;
                    star.starData.colIndex = i;
                    star.starData.rowIndex = j-count;
                }
            }
        }
       // cc.log(starNum);
        for( var x = 1 ; x <= this.colNum - starNum ; x++  ){
            this.starArray[this.rowNum - x][i] = null;
        }
        if( starNum == 0 ){  //当前列已经见底了
            nullCol.push(i);
        }
    }
    if( nullCol.length > 0 ){  //需要向左合并
        var firstCol = nullCol[0];
        for( var a = firstCol+1 ; a < this.colNum ; a++ ){
            if( !nullCol.contains(a) && this.starArray[0][a] == -1 && this.starArray[0][a] == null ){
                continue;
            }
            var count = 0;
            for( var b = 0 ; b < nullCol.length ; b++ ){
                if( a > nullCol[b] ){
                    count ++;
                }
            }
            for( var c = 0 ; c < this.rowNum ; c++ ){
                var star = this.starArray[c][a];
                if( star != -1 && star != null ){
                    var move = cc.MoveBy.create(1,cc.p(count*(-this.starWH - this.space) , 0));
                    star.runAction(move);
                    star.starData.colIndex = star.starData.colIndex - count;
                    this.starArray[c][a-count] = star;
                    this.starArray[c][a] = null;
                }
            }
        }
    }
};

MainLayer.prototype.print = function(){
    var p = "   ";
    for( var i = this.starArray.length -1 ; i >= 0 ; i-- ){
        var row = this.starArray[i];
        var s = "";
        for( var j = 0 ; j < row.length ; j++ ){
            var star = row[j];
        //    star != null ? s+= star.starData.color+p : s+= "     "+p;
            star != null ? s+= "xxxxx"+p : s+= "11111"+p;
        //    star != -1 ? s+= "xxxxx"+p : s+= "-1-1-"+p;
        }
        cc.log(s);
    }
    cc.log(" ");
    cc.log(" ");
};

//暂停游戏
MainLayer.prototype.pauseClicked = function(){
    cc.BuilderReader.runScene("","MainLayer");
};