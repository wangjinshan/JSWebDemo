/**
 * Created by shange on 2017/4/8.
 */


function ShareSDK()
{
//    alert('kk');
//    初始化sdk
    this.initSDK = function()
    {
        //1,平台的参数
        var mobkey = 'iosv1101';
        var platformID = new PlatformID();
        //平台数组
        var platformArr = [platformID.platformID.WeChat,platformID.platformID.WeChatFavorites,platformID.platformID.WeChatMoments];
        //2,微信appkey
        var platformConfig = ["wx4868b35061f87885","64020361b8ec4c99936c0e3999a9f249"];
        //发送请求
        window.location.href = '&initSDK' + '&mobkey'+mobkey +'&platformArr'+ platformArr +'&platformConfig' + platformConfig;
    }
//    设置分享的参数
    this.share = function ()
    {
        var params = [
                      "&text:$$测试的文字",
                      "&image:$$http://www.mob.com/mob/img/navproducts_03.png",
                      "&title:$$测试的标题",
                      "&url:$$http://www.mob.com",
                      "&type:$$auto"];
        
        window.location.href ='share' + params;
    }
    this.login = function ()
    {
    window.location.href = 'login';
    }
  
//    回调方法的处理
    this.callBackData = function(data)
    {
//        动态创建动态添加数据中到html中
            var p1 = document.createElement('p');
            p1.id = 'myp';
            p1.innerText = data;
            document.body.appendChild(p1);
        
        var p2 = document.createElement('p');
        var json = JsonStringToObject(data);
        p2.innerText = json;
        document.body.appendChild(p2);
//       解析并显示
        var p3 = document.createElement('p');
        var json = JsonStringToObject(data);
        var uid = json.uid;
        var nick = json.nick;
        p3.innerText = uid;
        document.body.appendChild(p3);
    }
//    测试传递对象类型
    this.ajsTest = function ()
    {
        var backJson = {};
        var wjs =
        {
            "name":"主席",
            "age":"18",
            "LBS":1999
        };
        backJson["wjs"] = wjs;
        var wjsJson =  ObjectToJsonString(backJson);
        window.location.href ="ajstest://?"+wjsJson;    // 注意协议头必须是小写 大写将转换成小写
    }
}

var $sharesdk = new ShareSDK();

// SDK平台
var PlatformID = function PlatformID()
{
    this.platformID =
    {
        //       微信
        WeChat : 22,		    //WeChat Friends
        WeChatMoments : 23,	    //WeChat Timeline
        WeChatFavorites : 37,	//WeChat Favorited
    //  平台的总称
        WechatPlatform : 997   //Wechat Series
    }
};

/**
 * JSON字符串转换为对象
 * @param string        JSON字符串
 * @returns {Object}    转换后对象
 */
var JsonStringToObject = function (string)
{
    try
    {
        return eval("(" + string + ")");
    }
    catch (err)
    {
        return null;
    }
};

/**
 * 对象转JSON字符串
 * @param obj           对象
 * @returns {string}    JSON字符串
 */
var ObjectToJsonString = function (obj)
{
    var S = [];
    var J = null;
    
    var type = Object.prototype.toString.apply(obj);
    
    if (type === '[object Array]')
    {
        for (var i = 0; i < obj.length; i++)
        {
            S.push(ObjectToJsonString(obj[i]));
        }
        J = '[' + S.join(',') + ']';
    }
    else if (type === '[object Date]')
    {
        J = "new Date(" + obj.getTime() + ")";
    }
    else if (type === '[object RegExp]'
             || type === '[object Function]')
    {
        J = obj.toString();
    }
    else if (type === '[object Object]')
    {
        for (var key in obj)
        {
            var value = ObjectToJsonString(obj[key]);
            if (value != null)
            {
                S.push('"' + key + '":' + value);
            }
        }
        J = '{' + S.join(',') + '}';
    }
    else if (type === '[object String]')
    {
        J = '"' + obj.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '') + '"';
    }
    else if (type === '[object Number]')
    {
    J = obj;
    }
    else if (type === '[object Boolean]')
    {
    J = obj;
    }
    return J;
};
















