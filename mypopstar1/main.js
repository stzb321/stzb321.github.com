if (sys.platform == 'browser') {
    var require = function (file) {
        var d = document;
        var s = d.createElement('script');
        s.src = file;
        d.body.appendChild(s);
    }
} else {
    require("jsb.js");
}

cc.debug = function (msg) {
    cc.log(msg);
}

cc.BuilderReader.replaceScene = function (path, ccbName) {
    var scene = cc.BuilderReader.loadAsSceneFrom(path, ccbName);
    cc.Director.getInstance().replaceScene(scene);
    return scene;
}

cc.BuilderReader.loadAsScene = function (file, owner, parentSize) {
    var node = cc.BuilderReader.load(file, owner, parentSize);
    var scene = cc.Scene.create();
    scene.addChild(node);
    return scene;
};

cc.BuilderReader.loadAsSceneFrom = function (path, ccbName)
{
    if (path && path.length > 0) {
        cc.BuilderReader.setResourcePath(path + "/");
        return cc.BuilderReader.loadAsScene(path + "/" + ccbName);
    }
    else {
        return cc.BuilderReader.loadAsScene(ccbName);
    }
}

cc.BuilderReader.loadAsNodeFrom = function (path, ccbName, owner)
{
    if (path && path.length > 0) {
        cc.BuilderReader.setResourcePath(path + "/");
        return cc.BuilderReader.load(path + "/" + ccbName, owner);
    }
    else {
        return cc.BuilderReader.load(ccbName, owner);
    }
}

cc.BuilderReader.runScene = function (module, name) {
    var director = cc.Director.getInstance();
    var scene = cc.BuilderReader.loadAsSceneFrom(module, name);
    var runningScene = director.getRunningScene();
    if (runningScene === null) {
        //cc.log("runWithScene");
        director.runWithScene(scene);
    }
    else {
        //cc.log("replaceScene");
        director.replaceScene(scene);
    }
}

var ccb_resources = [
    {src: "res/bg_main.png"},
    {src: "res/star_packer.plist"},
    {src: "res/face_packer.plist"},

    {src: "res/particles/leaf_open.plist"},
    {src: "res/particles/quanquan.plist"},
    {src: "res/particles/spark.plist"},
    {src: "res/particles/fire.png"},
    {src: "res/particles/star1d.png"},
    {src: "res/particles/star2d.png"},
    {src: "res/particles/star3d.png"},
    {src: "res/particles/star4d.png"},
    {src: "res/particles/star5d.png"},

    {src: "res/fonts/bitmapFontTest.png"},
    {src: "res/fonts/character.png"},
    {src: "res/fonts/highscore.png"},
    {src: "res/fonts/s_number_member_small.fnt"},
    {src: "res/fonts/s_number_member_small.png"},
    {src: "res/fonts/s_number_score.fnt"},
    {src: "res/fonts/s_number_score.png"},
    {src: "res/fonts/highscore.png"},
    {src: "res/fonts/titleinfo.fnt"}
];

require("StartLayer.js");
require("MainLayer.js");
require("MyUtil.js");

cc.StarParticle = {};
cc.StarParticle.create = function (node, x, y, name)
{
    var particle = cc.ParticleSystem.create("res/particles/" + name + ".plist");
    particle.setAnchorPoint(cc.p(0.5, 0.5));
    particle.setPosition(cc.p(x, y));
    particle.setZOrder(120);
    node.addChild(particle);
    return particle;
};


if (sys.platform == 'browser') {
    cc.log("Cocos2dXApplication");
    var Cocos2dXApplication = cc.Application.extend({
        config: document['ccConfig'],
        ctor: function () {
            this._super();
            cc.COCOS2D_DEBUG = this.config['COCOS2D_DEBUG'];
            cc.initDebugSetting();
            cc.setup(this.config['tag']);
            cc.AppController.shareAppController().didFinishLaunchingWithOptions();
        },
        applicationDidFinishLaunching: function () {
            var director = cc.Director.getInstance();
            // director->enableRetinaDisplay(true);
            // director.setDisplayStats(this.config['showFPS']);
            // set FPS. the default value is 1.0/60 if you don't call this
            director.setAnimationInterval(1.0 / this.config['frameRate']);
            var glView= director.getOpenGLView();
            glView.setDesignResolutionSize(720,1280,cc.RESOLUTION_POLICY.SHOW_ALL);
            cc.Loader.preload(ccb_resources, function () {
                cc.BuilderReader.runScene("", "StartLayer");
            }, this);
            return true;
        }
    });
    var myApp = new Cocos2dXApplication();
    cc.log("myApp");
} else {
    cc.BuilderReader.runScene("", "StartLayer");
}

/*******************常用函数*********************/
