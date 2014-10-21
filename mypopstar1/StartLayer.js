//
// CleanerScoreScene class
//
var StartLayer = function () {
    cc.log("StartLayer");
    this.newGameBtn = this.newGameBtn || {};
};

StartLayer.prototype.onDidLoadFromCCB = function () {
    cc.log("onDidLoadFromCCB");
    if (sys.platform == 'browser') {
        this.onEnter();
    }
    else {
        this.rootNode.onEnter = function () {
            this.controller.onEnter();
        };
    }

    this.rootNode.onExit = function () {
        this.controller.onExit();
    };
};

StartLayer.prototype.onEnter = function () {
    cc.log("onEnter");
    //if(sys.platform != 'browser' ){
        cc.StarParticle.create(this.rootNode , 200, 800  , "leaf_open");
        cc.StarParticle.create(this.rootNode , 600, 1150  , "leaf_open");
    //}
};

StartLayer.prototype.onExit = function () {
    cc.log("onExit");
};

StartLayer.prototype.newGameClicked = function(){
    cc.BuilderReader.runScene("" , "MainLayer");
};
