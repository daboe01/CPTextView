var ObjectiveJ={};
(function(_1,_2){
if(!Object.create){
Object.create=function(o){
if(arguments.length>1){
throw new Error("Object.create implementation only accepts the first parameter.");
}
function F(){
};
F.prototype=o;
return new F();
};
}
if(!Object.keys){
Object.keys=(function(){
var _3=Object.prototype.hasOwnProperty,_4=!({toString:null}).propertyIsEnumerable("toString"),_5=["toString","toLocaleString","valueOf","hasOwnProperty","isPrototypeOf","propertyIsEnumerable","constructor"],_6=_5.length;
return function(_7){
if(typeof _7!=="object"&&typeof _7!=="function"||_7===null){
throw new TypeError("Object.keys called on non-object");
}
var _8=[];
for(var _9 in _7){
if(_3.call(_7,_9)){
_8.push(_9);
}
}
if(_4){
for(var i=0;i<_6;i++){
if(_3.call(_7,_5[i])){
_8.push(_5[i]);
}
}
}
return _8;
};
})();
}
if(!Array.prototype.indexOf){
Array.prototype.indexOf=function(_a){
"use strict";
if(this===null){
throw new TypeError();
}
var t=new Object(this),_b=t.length>>>0;
if(_b===0){
return -1;
}
var n=0;
if(arguments.length>1){
n=Number(arguments[1]);
if(n!=n){
n=0;
}else{
if(n!==0&&n!=Infinity&&n!=-Infinity){
n=(n>0||-1)*Math.floor(Math.abs(n));
}
}
}
if(n>=_b){
return -1;
}
var k=n>=0?n:Math.max(_b-Math.abs(n),0);
for(;k<_b;k++){
if(k in t&&t[k]===_a){
return k;
}
}
return -1;
};
}
if(!this.JSON){
JSON={};
}
(function(){
function f(n){
return n<10?"0"+n:n;
};
if(typeof Date.prototype.toJSON!=="function"){
Date.prototype.toJSON=function(_c){
return this.getUTCFullYear()+"-"+f(this.getUTCMonth()+1)+"-"+f(this.getUTCDate())+"T"+f(this.getUTCHours())+":"+f(this.getUTCMinutes())+":"+f(this.getUTCSeconds())+"Z";
};
String.prototype.toJSON=Number.prototype.toJSON=Boolean.prototype.toJSON=function(_d){
return this.valueOf();
};
}
var cx=new RegExp("[\\u0000\\u00ad\\u0600-\\u0604\\u070f\\u17b4\\u17b5\\u200c-\\u200f\\u2028-\\u202f\\u2060-\\u206f\\ufeff\\ufff0-\\uffff]","g");
var _e=new RegExp("[\\\\\\\"\\x00-\\x1f\\x7f-\\x9f\\u00ad\\u0600-\\u0604\\u070f\\u17b4\\u17b5\\u200c-\\u200f\\u2028-\\u202f\\u2060-\\u206f\\ufeff\\ufff0-\\uffff]","g");
var _f,_10,_11={"\b":"\\b","\t":"\\t","\n":"\\n","\f":"\\f","\r":"\\r","\"":"\\\"","\\":"\\\\"},rep;
function _12(_13){
_e.lastIndex=0;
return _e.test(_13)?"\""+_13.replace(_e,function(a){
var c=_11[a];
return typeof c==="string"?c:"\\u"+("0000"+a.charCodeAt(0).toString(16)).slice(-4);
})+"\"":"\""+_13+"\"";
};
function str(key,_14){
var i,k,v,_15,_16=_f,_17,_18=_14[key];
if(_18&&typeof _18==="object"&&typeof _18.toJSON==="function"){
_18=_18.toJSON(key);
}
if(typeof rep==="function"){
_18=rep.call(_14,key,_18);
}
switch(typeof _18){
case "string":
return _12(_18);
case "number":
return isFinite(_18)?String(_18):"null";
case "boolean":
case "null":
return String(_18);
case "object":
if(!_18){
return "null";
}
_f+=_10;
_17=[];
if(Object.prototype.toString.apply(_18)==="[object Array]"){
_15=_18.length;
for(i=0;i<_15;i+=1){
_17[i]=str(i,_18)||"null";
}
v=_17.length===0?"[]":_f?"[\n"+_f+_17.join(",\n"+_f)+"\n"+_16+"]":"["+_17.join(",")+"]";
_f=_16;
return v;
}
if(rep&&typeof rep==="object"){
_15=rep.length;
for(i=0;i<_15;i+=1){
k=rep[i];
if(typeof k==="string"){
v=str(k,_18);
if(v){
_17.push(_12(k)+(_f?": ":":")+v);
}
}
}
}else{
for(k in _18){
if(Object.hasOwnProperty.call(_18,k)){
v=str(k,_18);
if(v){
_17.push(_12(k)+(_f?": ":":")+v);
}
}
}
}
v=_17.length===0?"{}":_f?"{\n"+_f+_17.join(",\n"+_f)+"\n"+_16+"}":"{"+_17.join(",")+"}";
_f=_16;
return v;
}
};
if(typeof JSON.stringify!=="function"){
JSON.stringify=function(_19,_1a,_1b){
var i;
_f="";
_10="";
if(typeof _1b==="number"){
for(i=0;i<_1b;i+=1){
_10+=" ";
}
}else{
if(typeof _1b==="string"){
_10=_1b;
}
}
rep=_1a;
if(_1a&&typeof _1a!=="function"&&(typeof _1a!=="object"||typeof _1a.length!=="number")){
throw new Error("JSON.stringify");
}
return str("",{"":_19});
};
}
if(typeof JSON.parse!=="function"){
JSON.parse=function(_1c,_1d){
var j;
function _1e(_1f,key){
var k,v,_20=_1f[key];
if(_20&&typeof _20==="object"){
for(k in _20){
if(Object.hasOwnProperty.call(_20,k)){
v=_1e(_20,k);
if(v!==_2f){
_20[k]=v;
}else{
delete _20[k];
}
}
}
}
return _1d.call(_1f,key,_20);
};
cx.lastIndex=0;
if(cx.test(_1c)){
_1c=_1c.replace(cx,function(a){
return "\\u"+("0000"+a.charCodeAt(0).toString(16)).slice(-4);
});
}
if(/^[\],:{}\s]*$/.test(_1c.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,"@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,"]").replace(/(?:^|:|,)(?:\s*\[)+/g,""))){
j=eval("("+_1c+")");
return typeof _1d==="function"?_1e({"":j},""):j;
}
throw new SyntaxError("JSON.parse");
};
}
}());
var _21=/([^%]+|%(?:\d+\$)?[\+\-\ \#0]*[0-9\*]*(.[0-9\*]+)?[hlL]?[cbBdieEfgGosuxXpn%@])/g,_22=/(%)(?:(\d+)\$)?([\+\-\ \#0]*)([0-9\*]*)((?:.[0-9\*]+)?)([hlL]?)([cbBdieEfgGosuxXpn%@])/;
_2.sprintf=function(_23){
var _23=arguments[0],_24=_23.match(_21),_25=0,_26="",arg=1;
for(var i=0;i<_24.length;i++){
var t=_24[i];
if(_23.substring(_25,_25+t.length)!==t){
return _26;
}
_25+=t.length;
if(t.charAt(0)!=="%"){
_26+=t;
}else{
if(t==="%%"){
_26+="%";
}else{
var _27=t.match(_22);
if(_27.length!==8||_27[0]!==t){
return _26;
}
var _28=_27[1],_29=_27[2],_2a=_27[3],_2b=_27[4],_2c=_27[5],_2d=_27[6],_2e=_27[7];
if(_29===_2f||_29===null||_29===""){
_29=arg++;
}else{
_29=Number(_29);
}
var _30=null;
if(_2b=="*"){
_30=arguments[_29];
}else{
if(_2b!==""){
_30=Number(_2b);
}
}
var _31=null;
if(_2c===".*"){
_31=arguments[_29];
}else{
if(_2c!==""){
_31=Number(_2c.substring(1));
}
}
var _32=(_2a.indexOf("-")>=0),_33=(_2a.indexOf("0")>=0),_34="";
if(/[bBdiufeExXo]/.test(_2e)){
var num=Number(arguments[_29]),_35="";
if(num<0){
_35="-";
}else{
if(_2a.indexOf("+")>=0){
_35="+";
}else{
if(_2a.indexOf(" ")>=0){
_35=" ";
}
}
}
if(_2e==="d"||_2e==="i"||_2e==="u"){
var _36=String(Math.abs(Math.floor(num)));
_34=_37(_35,"",_36,"",_30,_32,_33);
}
if(_2e=="f"){
var _36=String((_31!==null)?Math.abs(num).toFixed(_31):Math.abs(num)),_38=(_2a.indexOf("#")>=0&&_36.indexOf(".")<0)?".":"";
_34=_37(_35,"",_36,_38,_30,_32,_33);
}
if(_2e==="e"||_2e==="E"){
var _36=String(Math.abs(num).toExponential(_31!==null?_31:21)),_38=(_2a.indexOf("#")>=0&&_36.indexOf(".")<0)?".":"";
_34=_37(_35,"",_36,_38,_30,_32,_33);
}
if(_2e=="x"||_2e=="X"){
var _36=String(Math.abs(num).toString(16));
var _39=(_2a.indexOf("#")>=0&&num!=0)?"0x":"";
_34=_37(_35,_39,_36,"",_30,_32,_33);
}
if(_2e=="b"||_2e=="B"){
var _36=String(Math.abs(num).toString(2));
var _39=(_2a.indexOf("#")>=0&&num!=0)?"0b":"";
_34=_37(_35,_39,_36,"",_30,_32,_33);
}
if(_2e=="o"){
var _36=String(Math.abs(num).toString(8));
var _39=(_2a.indexOf("#")>=0&&num!=0)?"0":"";
_34=_37(_35,_39,_36,"",_30,_32,_33);
}
if(/[A-Z]/.test(_2e)){
_34=_34.toUpperCase();
}else{
_34=_34.toLowerCase();
}
}else{
var _34="";
if(_2e==="%"){
_34="%";
}else{
if(_2e==="c"){
_34=String(arguments[_29]).charAt(0);
}else{
if(_2e==="s"||_2e==="@"){
_34=String(arguments[_29]);
}else{
if(_2e==="p"||_2e==="n"){
_34="";
}
}
}
}
_34=_37("","",_34,"",_30,_32,false);
}
_26+=_34;
}
}
}
return _26;
};
function _37(_3a,_3b,_3c,_3d,_3e,_3f,_40){
var _41=(_3a.length+_3b.length+_3c.length+_3d.length);
if(_3f){
return _3a+_3b+_3c+_3d+pad(_3e-_41," ");
}else{
if(_40){
return _3a+_3b+pad(_3e-_41,"0")+_3c+_3d;
}else{
return pad(_3e-_41," ")+_3a+_3b+_3c+_3d;
}
}
};
function pad(n,ch){
return Array(MAX(0,n)+1).join(ch);
};
CPLogDisable=false;
var _42="Cappuccino";
var _43=["fatal","error","warn","info","debug","trace"];
var _44=_43[3];
var _45={};
for(var i=0;i<_43.length;i++){
_45[_43[i]]=i;
}
var _46={};
CPLogRegister=function(_47,_48,_49){
CPLogRegisterRange(_47,_43[0],_48||_43[_43.length-1],_49);
};
CPLogRegisterRange=function(_4a,_4b,_4c,_4d){
var min=_45[_4b];
var max=_45[_4c];
if(min!==_2f&&max!==_2f&&min<=max){
for(var i=min;i<=max;i++){
CPLogRegisterSingle(_4a,_43[i],_4d);
}
}
};
CPLogRegisterSingle=function(_4e,_4f,_50){
if(!_46[_4f]){
_46[_4f]=[];
}
for(var i=0;i<_46[_4f].length;i++){
if(_46[_4f][i][0]===_4e){
_46[_4f][i][1]=_50;
return;
}
}
_46[_4f].push([_4e,_50]);
};
CPLogUnregister=function(_51){
for(var _52 in _46){
for(var i=0;i<_46[_52].length;i++){
if(_46[_52][i][0]===_51){
_46[_52].splice(i--,1);
}
}
}
};
function _53(_54,_55,_56){
if(_56==_2f){
_56=_42;
}
if(_55==_2f){
_55=_44;
}
var _57=(typeof _54[0]=="string"&&_54.length>1)?_2.sprintf.apply(null,_54):String(_54[0]);
if(_46[_55]){
for(var i=0;i<_46[_55].length;i++){
var _58=_46[_55][i];
_58[0](_57,_55,_56,_58[1]);
}
}
};
CPLog=function(){
_53(arguments);
};
for(var i=0;i<_43.length;i++){
CPLog[_43[i]]=(function(_59){
return function(){
_53(arguments,_59);
};
})(_43[i]);
}
var _5a=function(_5b,_5c,_5d){
var now=new Date(),_5e;
if(_5c===null){
_5c="";
}else{
_5c=_5c||"info";
_5c="["+CPLogColorize(_5c,_5c)+"]";
}
_5d=_5d||"";
if(_5d&&_5c){
_5d+=" ";
}
_5e=_5d+_5c;
if(_5e){
_5e+=": ";
}
if(typeof _2.sprintf=="function"){
return _2.sprintf("%4d-%02d-%02d %02d:%02d:%02d.%03d %s%s",now.getFullYear(),now.getMonth()+1,now.getDate(),now.getHours(),now.getMinutes(),now.getSeconds(),now.getMilliseconds(),_5e,_5b);
}else{
return now+" "+_5e+": "+_5b;
}
};
CPLogConsole=function(_5f,_60,_61,_62){
if(typeof console!="undefined"){
var _63=(_62||_5a)(_5f,_60,_61),_64={"fatal":"error","error":"error","warn":"warn","info":"info","debug":"debug","trace":"debug"}[_60];
if(_64&&console[_64]){
console[_64](_63);
}else{
if(console.log){
console.log(_63);
}
}
}
};
CPLogColorize=function(_65,_66){
return _65;
};
CPLogAlert=function(_67,_68,_69,_6a){
if(typeof alert!="undefined"&&!CPLogDisable){
var _6b=(_6a||_5a)(_67,_68,_69);
CPLogDisable=!confirm(_6b+"\n\n(Click cancel to stop log alerts)");
}
};
var _6c=null;
CPLogPopup=function(_6d,_6e,_6f,_70){
try{
if(CPLogDisable||window.open==_2f){
return;
}
if(!_6c||!_6c.document){
_6c=window.open("","_blank","width=600,height=400,status=no,resizable=yes,scrollbars=yes");
if(!_6c){
CPLogDisable=!confirm(_6d+"\n\n(Disable pop-up blocking for CPLog window; Click cancel to stop log alerts)");
return;
}
_71(_6c);
}
var _72=_6c.document.createElement("div");
_72.setAttribute("class",_6e||"fatal");
var _73=(_70||_5a)(_6d,_70?_6e:null,_6f);
_72.appendChild(_6c.document.createTextNode(_73));
_6c.log.appendChild(_72);
if(_6c.focusEnabled.checked){
_6c.focus();
}
if(_6c.blockEnabled.checked){
_6c.blockEnabled.checked=_6c.confirm(_73+"\nContinue blocking?");
}
if(_6c.scrollEnabled.checked){
_6c.scrollToBottom();
}
}
catch(e){
}
};
var _74="<style type=\"text/css\" media=\"screen\"> body{font:10px Monaco,Courier,\"Courier New\",monospace,mono;padding-top:15px;} div > .fatal,div > .error,div > .warn,div > .info,div > .debug,div > .trace{display:none;overflow:hidden;white-space:pre;padding:0px 5px 0px 5px;margin-top:2px;-moz-border-radius:5px;-webkit-border-radius:5px;} div[wrap=\"yes\"] > div{white-space:normal;} .fatal{background-color:#ffb2b3;} .error{background-color:#ffe2b2;} .warn{background-color:#fdffb2;} .info{background-color:#e4ffb2;} .debug{background-color:#a0e5a0;} .trace{background-color:#99b9ff;} .enfatal .fatal,.enerror .error,.enwarn .warn,.eninfo .info,.endebug .debug,.entrace .trace{display:block;} div#header{background-color:rgba(240,240,240,0.82);position:fixed;top:0px;left:0px;width:100%;border-bottom:1px solid rgba(0,0,0,0.33);text-align:center;} ul#enablers{display:inline-block;margin:1px 15px 0 15px;padding:2px 0 2px 0;} ul#enablers li{display:inline;padding:0px 5px 0px 5px;margin-left:4px;-moz-border-radius:5px;-webkit-border-radius:5px;} [enabled=\"no\"]{opacity:0.25;} ul#options{display:inline-block;margin:0 15px 0px 15px;padding:0 0px;} ul#options li{margin:0 0 0 0;padding:0 0 0 0;display:inline;} </style>";
function _71(_75){
var doc=_75.document;
doc.writeln("<html><head><title></title>"+_74+"</head><body></body></html>");
doc.title=_42+" Run Log";
var _76=doc.getElementsByTagName("head")[0];
var _77=doc.getElementsByTagName("body")[0];
var _78=window.location.protocol+"//"+window.location.host+window.location.pathname;
_78=_78.substring(0,_78.lastIndexOf("/")+1);
var div=doc.createElement("div");
div.setAttribute("id","header");
_77.appendChild(div);
var ul=doc.createElement("ul");
ul.setAttribute("id","enablers");
div.appendChild(ul);
for(var i=0;i<_43.length;i++){
var li=doc.createElement("li");
li.setAttribute("id","en"+_43[i]);
li.setAttribute("class",_43[i]);
li.setAttribute("onclick","toggle(this);");
li.setAttribute("enabled","yes");
li.appendChild(doc.createTextNode(_43[i]));
ul.appendChild(li);
}
var ul=doc.createElement("ul");
ul.setAttribute("id","options");
div.appendChild(ul);
var _79={"focus":["Focus",false],"block":["Block",false],"wrap":["Wrap",false],"scroll":["Scroll",true],"close":["Close",true]};
for(o in _79){
var li=doc.createElement("li");
ul.appendChild(li);
_75[o+"Enabled"]=doc.createElement("input");
_75[o+"Enabled"].setAttribute("id",o);
_75[o+"Enabled"].setAttribute("type","checkbox");
if(_79[o][1]){
_75[o+"Enabled"].setAttribute("checked","checked");
}
li.appendChild(_75[o+"Enabled"]);
var _7a=doc.createElement("label");
_7a.setAttribute("for",o);
_7a.appendChild(doc.createTextNode(_79[o][0]));
li.appendChild(_7a);
}
_75.log=doc.createElement("div");
_75.log.setAttribute("class","enerror endebug enwarn eninfo enfatal entrace");
_77.appendChild(_75.log);
_75.toggle=function(_7b){
var _7c=(_7b.getAttribute("enabled")=="yes")?"no":"yes";
_7b.setAttribute("enabled",_7c);
if(_7c=="yes"){
_75.log.className+=" "+_7b.id;
}else{
_75.log.className=_75.log.className.replace(new RegExp("[\\s]*"+_7b.id,"g"),"");
}
};
_75.scrollToBottom=function(){
_75.scrollTo(0,_77.offsetHeight);
};
_75.wrapEnabled.addEventListener("click",function(){
_75.log.setAttribute("wrap",_75.wrapEnabled.checked?"yes":"no");
},false);
_75.addEventListener("keydown",function(e){
var e=e||_75.event;
if(e.keyCode==75&&(e.ctrlKey||e.metaKey)){
while(_75.log.firstChild){
_75.log.removeChild(_75.log.firstChild);
}
e.preventDefault();
}
},"false");
window.addEventListener("unload",function(){
if(_75&&_75.closeEnabled&&_75.closeEnabled.checked){
CPLogDisable=true;
_75.close();
}
},false);
_75.addEventListener("unload",function(){
if(!CPLogDisable){
CPLogDisable=!confirm("Click cancel to stop logging");
}
},false);
};
CPLogDefault=(typeof window==="object"&&window.console)?CPLogConsole:CPLogPopup;
var _2f;
if(typeof window!=="undefined"){
window.setNativeTimeout=window.setTimeout;
window.clearNativeTimeout=window.clearTimeout;
window.setNativeInterval=window.setInterval;
window.clearNativeInterval=window.clearInterval;
}
NO=false;
YES=true;
nil=null;
Nil=null;
NULL=null;
ABS=Math.abs;
ASIN=Math.asin;
ACOS=Math.acos;
ATAN=Math.atan;
ATAN2=Math.atan2;
SIN=Math.sin;
COS=Math.cos;
TAN=Math.tan;
EXP=Math.exp;
POW=Math.pow;
CEIL=Math.ceil;
FLOOR=Math.floor;
ROUND=Math.round;
MIN=Math.min;
MAX=Math.max;
RAND=Math.random;
SQRT=Math.sqrt;
E=Math.E;
LN2=Math.LN2;
LN10=Math.LN10;
LOG=Math.log;
LOG2E=Math.LOG2E;
LOG10E=Math.LOG10E;
PI=Math.PI;
PI2=Math.PI*2;
PI_2=Math.PI/2;
SQRT1_2=Math.SQRT1_2;
SQRT2=Math.SQRT2;
function _7d(_7e){
this._eventListenersForEventNames={};
this._owner=_7e;
};
_7d.prototype.addEventListener=function(_7f,_80){
var _81=this._eventListenersForEventNames;
if(!_82.call(_81,_7f)){
var _83=[];
_81[_7f]=_83;
}else{
var _83=_81[_7f];
}
var _84=_83.length;
while(_84--){
if(_83[_84]===_80){
return;
}
}
_83.push(_80);
};
_7d.prototype.removeEventListener=function(_85,_86){
var _87=this._eventListenersForEventNames;
if(!_82.call(_87,_85)){
return;
}
var _88=_87[_85],_89=_88.length;
while(_89--){
if(_88[_89]===_86){
return _88.splice(_89,1);
}
}
};
_7d.prototype.dispatchEvent=function(_8a){
var _8b=_8a.type,_8c=this._eventListenersForEventNames;
if(_82.call(_8c,_8b)){
var _8d=this._eventListenersForEventNames[_8b],_8e=0,_8f=_8d.length;
for(;_8e<_8f;++_8e){
_8d[_8e](_8a);
}
}
var _90=(this._owner||this)["on"+_8b];
if(_90){
_90(_8a);
}
};
var _91=0,_92=null,_93=[];
function _94(_95){
var _96=_91;
if(_92===null){
window.setNativeTimeout(function(){
var _97=_93,_98=0,_99=_93.length;
++_91;
_92=null;
_93=[];
for(;_98<_99;++_98){
_97[_98]();
}
},0);
}
return function(){
var _9a=arguments;
if(_91>_96){
_95.apply(this,_9a);
}else{
_93.push(function(){
_95.apply(this,_9a);
});
}
};
};
var _9b=null;
if(window.XMLHttpRequest){
_9b=window.XMLHttpRequest;
}else{
if(window.ActiveXObject!==_2f){
var _9c=["Msxml2.XMLHTTP.3.0","Msxml2.XMLHTTP.6.0"],_9d=_9c.length;
while(_9d--){
try{
var _9e=_9c[_9d];
new ActiveXObject(_9e);
_9b=function(){
return new ActiveXObject(_9e);
};
break;
}
catch(anException){
}
}
}
}
CFHTTPRequest=function(){
this._isOpen=false;
this._requestHeaders={};
this._mimeType=null;
this._eventDispatcher=new _7d(this);
this._nativeRequest=new _9b();
this._withCredentials=false;
this._timeout=60000;
var _9f=this;
this._stateChangeHandler=function(){
_b8(_9f);
};
this._timeoutHandler=function(){
_b6(_9f);
};
this._nativeRequest.onreadystatechange=this._stateChangeHandler;
this._nativeRequest.ontimeout=this._timeoutHandler;
if(CFHTTPRequest.AuthenticationDelegate!==nil){
this._eventDispatcher.addEventListener("HTTP403",function(){
CFHTTPRequest.AuthenticationDelegate(_9f);
});
}
};
CFHTTPRequest.UninitializedState=0;
CFHTTPRequest.LoadingState=1;
CFHTTPRequest.LoadedState=2;
CFHTTPRequest.InteractiveState=3;
CFHTTPRequest.CompleteState=4;
CFHTTPRequest.AuthenticationDelegate=nil;
CFHTTPRequest.prototype.status=function(){
try{
return this._nativeRequest.status||0;
}
catch(anException){
return 0;
}
};
CFHTTPRequest.prototype.statusText=function(){
try{
return this._nativeRequest.statusText||"";
}
catch(anException){
return "";
}
};
CFHTTPRequest.prototype.readyState=function(){
return this._nativeRequest.readyState;
};
CFHTTPRequest.prototype.success=function(){
var _a0=this.status();
if(_a0>=200&&_a0<300){
return YES;
}
return _a0===0&&this.responseText()&&this.responseText().length;
};
CFHTTPRequest.prototype.responseXML=function(){
var _a1=this._nativeRequest.responseXML;
if(_a1&&(_9b===window.XMLHttpRequest)&&_a1.documentRoot){
return _a1;
}
return _a2(this.responseText());
};
CFHTTPRequest.prototype.responsePropertyList=function(){
var _a3=this.responseText();
if(CFPropertyList.sniffedFormatOfString(_a3)===CFPropertyList.FormatXML_v1_0){
return CFPropertyList.propertyListFromXML(this.responseXML());
}
return CFPropertyList.propertyListFromString(_a3);
};
CFHTTPRequest.prototype.responseText=function(){
return this._nativeRequest.responseText;
};
CFHTTPRequest.prototype.setRequestHeader=function(_a4,_a5){
this._requestHeaders[_a4]=_a5;
};
CFHTTPRequest.prototype.getResponseHeader=function(_a6){
return this._nativeRequest.getResponseHeader(_a6);
};
CFHTTPRequest.prototype.setTimeout=function(_a7){
this._timeout=_a7;
if(this._isOpen){
this._nativeRequest.timeout=_a7;
}
};
CFHTTPRequest.prototype.getTimeout=function(_a8){
return this._timeout;
};
CFHTTPRequest.prototype.getAllResponseHeaders=function(){
return this._nativeRequest.getAllResponseHeaders();
};
CFHTTPRequest.prototype.overrideMimeType=function(_a9){
this._mimeType=_a9;
};
CFHTTPRequest.prototype.open=function(_aa,_ab,_ac,_ad,_ae){
var _af;
this._isOpen=true;
this._URL=_ab;
this._async=_ac;
this._method=_aa;
this._user=_ad;
this._password=_ae;
requestReturnValue=this._nativeRequest.open(_aa,_ab,_ac,_ad,_ae);
if(this._async){
this._nativeRequest.withCredentials=this._withCredentials;
this._nativeRequest.timeout=this._timeout;
}
return requestReturnValue;
};
CFHTTPRequest.prototype.send=function(_b0){
if(!this._isOpen){
delete this._nativeRequest.onreadystatechange;
delete this._nativeRequest.ontimeout;
this._nativeRequest.open(this._method,this._URL,this._async,this._user,this._password);
this._nativeRequest.ontimeout=this._timeoutHandler;
this._nativeRequest.onreadystatechange=this._stateChangeHandler;
}
for(var i in this._requestHeaders){
if(this._requestHeaders.hasOwnProperty(i)){
this._nativeRequest.setRequestHeader(i,this._requestHeaders[i]);
}
}
if(this._mimeType&&"overrideMimeType" in this._nativeRequest){
this._nativeRequest.overrideMimeType(this._mimeType);
}
this._isOpen=false;
try{
return this._nativeRequest.send(_b0);
}
catch(anException){
this._eventDispatcher.dispatchEvent({type:"failure",request:this});
}
};
CFHTTPRequest.prototype.abort=function(){
this._isOpen=false;
return this._nativeRequest.abort();
};
CFHTTPRequest.prototype.addEventListener=function(_b1,_b2){
this._eventDispatcher.addEventListener(_b1,_b2);
};
CFHTTPRequest.prototype.removeEventListener=function(_b3,_b4){
this._eventDispatcher.removeEventListener(_b3,_b4);
};
CFHTTPRequest.prototype.setWithCredentials=function(_b5){
this._withCredentials=_b5;
if(this._isOpen&&this._async){
this._nativeRequest.withCredentials=_b5;
}
};
CFHTTPRequest.prototype.withCredentials=function(){
return this._withCredentials;
};
CFHTTPRequest.prototype.isTimeoutRequest=function(){
return !this.success()&&!this._nativeRequest.response&&!this._nativeRequest.responseText&&!this._nativeRequest.responseType&&!this._nativeRequest.responseURL&&!this._nativeRequest.responseXML;
};
function _b6(_b7){
_b7._eventDispatcher.dispatchEvent({type:"timeout",request:_b7});
};
function _b8(_b9){
var _ba=_b9._eventDispatcher,_bb=["uninitialized","loading","loaded","interactive","complete"];
_ba.dispatchEvent({type:"readystatechange",request:_b9});
if(_bb[_b9.readyState()]==="complete"){
var _bc="HTTP"+_b9.status();
_ba.dispatchEvent({type:_bc,request:_b9});
var _bd=_b9.success()?"success":"failure";
_ba.dispatchEvent({type:_bd,request:_b9});
_ba.dispatchEvent({type:_bb[_b9.readyState()],request:_b9});
}else{
_ba.dispatchEvent({type:_bb[_b9.readyState()],request:_b9});
}
};
function _be(_bf,_c0,_c1,_c2){
var _c3=new CFHTTPRequest();
if(_bf.pathExtension()==="plist"){
_c3.overrideMimeType("text/xml");
}
var _c4=0,_c5=null;
function _c6(_c7){
_c2(_c7.loaded-_c4);
_c4=_c7.loaded;
};
function _c8(_c9){
if(_c2&&_c5===null){
_c2(_c9.request.responseText().length);
}
_c0(_c9);
};
if(_2.asyncLoader){
_c3.onsuccess=_94(_c8);
_c3.onfailure=_94(_c1);
}else{
_c3.onsuccess=_c8;
_c3.onfailure=_c1;
}
if(_c2){
var _ca=true;
if(document.all){
_ca=!!window.atob;
}
if(_ca){
try{
_c5=_2.asyncLoader?_94(_c6):_c6;
_c3._nativeRequest.onprogress=_c5;
}
catch(anException){
_c5=null;
}
}
}
_c3.open("GET",_bf.absoluteString(),_2.asyncLoader);
_c3.send("");
};
_2.asyncLoader=YES;
_2.Asynchronous=_94;
_2.determineAndDispatchHTTPRequestEvents=_b8;
var _cb=0;
objj_generateObjectUID=function(){
return _cb++;
};
CFPropertyList=function(){
this._UID=objj_generateObjectUID();
};
CFPropertyList.DTDRE=/^\s*(?:<\?\s*xml\s+version\s*=\s*\"1.0\"[^>]*\?>\s*)?(?:<\!DOCTYPE[^>]*>\s*)?/i;
CFPropertyList.XMLRE=/^\s*(?:<\?\s*xml\s+version\s*=\s*\"1.0\"[^>]*\?>\s*)?(?:<\!DOCTYPE[^>]*>\s*)?<\s*plist[^>]*\>/i;
CFPropertyList.FormatXMLDTD="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">";
CFPropertyList.Format280NorthMagicNumber="280NPLIST";
CFPropertyList.FormatOpenStep=1,CFPropertyList.FormatXML_v1_0=100,CFPropertyList.FormatBinary_v1_0=200,CFPropertyList.Format280North_v1_0=-1000;
CFPropertyList.sniffedFormatOfString=function(_cc){
if(_cc.match(CFPropertyList.XMLRE)){
return CFPropertyList.FormatXML_v1_0;
}
if(_cc.substr(0,CFPropertyList.Format280NorthMagicNumber.length)===CFPropertyList.Format280NorthMagicNumber){
return CFPropertyList.Format280North_v1_0;
}
return NULL;
};
CFPropertyList.dataFromPropertyList=function(_cd,_ce){
var _cf=new CFMutableData();
_cf.setRawString(CFPropertyList.stringFromPropertyList(_cd,_ce));
return _cf;
};
CFPropertyList.stringFromPropertyList=function(_d0,_d1){
if(!_d1){
_d1=CFPropertyList.Format280North_v1_0;
}
var _d2=_d3[_d1];
return _d2["start"]()+_d4(_d0,_d2)+_d2["finish"]();
};
function _d4(_d5,_d6){
var _d7=typeof _d5,_d8=_d5.valueOf(),_d9=typeof _d8;
if(_d7!==_d9){
_d7=_d9;
_d5=_d8;
}
if(_d5===YES||_d5===NO){
_d7="boolean";
}else{
if(_d7==="number"){
if(FLOOR(_d5)===_d5&&(""+_d5).indexOf("e")==-1){
_d7="integer";
}else{
_d7="real";
}
}else{
if(_d7!=="string"){
if(_d5.slice){
_d7="array";
}else{
_d7="dictionary";
}
}
}
}
return _d6[_d7](_d5,_d6);
};
var _d3={};
_d3[CFPropertyList.FormatXML_v1_0]={"start":function(){
return CFPropertyList.FormatXMLDTD+"<plist version = \"1.0\">";
},"finish":function(){
return "</plist>";
},"string":function(_da){
return "<string>"+_db(_da)+"</string>";
},"boolean":function(_dc){
return _dc?"<true/>":"<false/>";
},"integer":function(_dd){
return "<integer>"+_dd+"</integer>";
},"real":function(_de){
return "<real>"+_de+"</real>";
},"array":function(_df,_e0){
var _e1=0,_e2=_df.length,_e3="<array>";
for(;_e1<_e2;++_e1){
_e3+=_d4(_df[_e1],_e0);
}
return _e3+"</array>";
},"dictionary":function(_e4,_e5){
var _e6=_e4._keys,_9d=0,_e7=_e6.length,_e8="<dict>";
for(;_9d<_e7;++_9d){
var key=_e6[_9d];
_e8+="<key>"+key+"</key>";
_e8+=_d4(_e4.valueForKey(key),_e5);
}
return _e8+"</dict>";
}};
var _e9="A",_ea="D",_eb="f",_ec="d",_ed="S",_ee="T",_ef="F",_f0="K",_f1="E";
_d3[CFPropertyList.Format280North_v1_0]={"start":function(){
return CFPropertyList.Format280NorthMagicNumber+";1.0;";
},"finish":function(){
return "";
},"string":function(_f2){
return _ed+";"+_f2.length+";"+_f2;
},"boolean":function(_f3){
return (_f3?_ee:_ef)+";";
},"integer":function(_f4){
var _f5=""+_f4;
return _ec+";"+_f5.length+";"+_f5;
},"real":function(_f6){
var _f7=""+_f6;
return _eb+";"+_f7.length+";"+_f7;
},"array":function(_f8,_f9){
var _fa=0,_fb=_f8.length,_fc=_e9+";";
for(;_fa<_fb;++_fa){
_fc+=_d4(_f8[_fa],_f9);
}
return _fc+_f1+";";
},"dictionary":function(_fd,_fe){
var _ff=_fd._keys,_9d=0,_100=_ff.length,_101=_ea+";";
for(;_9d<_100;++_9d){
var key=_ff[_9d];
_101+=_f0+";"+key.length+";"+key;
_101+=_d4(_fd.valueForKey(key),_fe);
}
return _101+_f1+";";
}};
var _102="xml",_103="#document",_104="plist",_105="key",_106="dict",_107="array",_108="string",_109="date",_10a="true",_10b="false",_10c="real",_10d="integer",_10e="data";
var _10f=function(_110){
var text="",_9d=0,_111=_110.length;
for(;_9d<_111;++_9d){
var node=_110[_9d];
if(node.nodeType===3||node.nodeType===4){
text+=node.nodeValue;
}else{
if(node.nodeType!==8){
text+=_10f(node.childNodes);
}
}
}
return text;
};
var _112=function(_113,_114,_115){
var node=_113;
node=(node.firstChild);
if(node!==NULL&&((node.nodeType)===8||(node.nodeType)===3)){
while((node=(node.nextSibling))&&((node.nodeType)===8||(node.nodeType)===3)){
}
}
if(node){
return node;
}
if((String(_113.nodeName))===_107||(String(_113.nodeName))===_106){
_115.pop();
}else{
if(node===_114){
return NULL;
}
node=_113;
while((node=(node.nextSibling))&&((node.nodeType)===8||(node.nodeType)===3)){
}
if(node){
return node;
}
}
node=_113;
while(node){
var next=node;
while((next=(next.nextSibling))&&((next.nodeType)===8||(next.nodeType)===3)){
}
if(next){
return next;
}
var node=(node.parentNode);
if(_114&&node===_114){
return NULL;
}
_115.pop();
}
return NULL;
};
CFPropertyList.propertyListFromData=function(_116,_117){
return CFPropertyList.propertyListFromString(_116.rawString(),_117);
};
CFPropertyList.propertyListFromString=function(_118,_119){
if(!_119){
_119=CFPropertyList.sniffedFormatOfString(_118);
}
if(_119===CFPropertyList.FormatXML_v1_0){
return CFPropertyList.propertyListFromXML(_118);
}
if(_119===CFPropertyList.Format280North_v1_0){
return _11a(_118);
}
return NULL;
};
var _e9="A",_ea="D",_eb="f",_ec="d",_ed="S",_ee="T",_ef="F",_f0="K",_f1="E";
function _11a(_11b){
var _11c=new _11d(_11b),_11e=NULL,key="",_11f=NULL,_120=NULL,_121=[],_122=NULL;
while(_11e=_11c.getMarker()){
if(_11e===_f1){
_121.pop();
continue;
}
var _123=_121.length;
if(_123){
_122=_121[_123-1];
}
if(_11e===_f0){
key=_11c.getString();
_11e=_11c.getMarker();
}
switch(_11e){
case _e9:
_11f=[];
_121.push(_11f);
break;
case _ea:
_11f=new CFMutableDictionary();
_121.push(_11f);
break;
case _eb:
_11f=parseFloat(_11c.getString());
break;
case _ec:
_11f=parseInt(_11c.getString(),10);
break;
case _ed:
_11f=_11c.getString();
break;
case _ee:
_11f=YES;
break;
case _ef:
_11f=NO;
break;
default:
throw new Error("*** "+_11e+" marker not recognized in Plist.");
}
if(!_120){
_120=_11f;
}else{
if(_122){
if(_122.slice){
_122.push(_11f);
}else{
_122.setValueForKey(key,_11f);
}
}
}
}
return _120;
};
function _db(_124){
return _124.replace(/&/g,"&amp;").replace(/"/g,"&quot;").replace(/'/g,"&apos;").replace(/</g,"&lt;").replace(/>/g,"&gt;");
};
function _125(_126){
return _126.replace(/&quot;/g,"\"").replace(/&apos;/g,"'").replace(/&lt;/g,"<").replace(/&gt;/g,">").replace(/&amp;/g,"&");
};
function _a2(_127){
if(window.DOMParser){
return (new window.DOMParser().parseFromString(_127,"text/xml").documentElement);
}else{
if(window.ActiveXObject){
XMLNode=new ActiveXObject("Microsoft.XMLDOM");
var _128=_127.match(CFPropertyList.DTDRE);
if(_128){
_127=_127.substr(_128[0].length);
}
XMLNode.loadXML(_127);
return XMLNode;
}
}
return NULL;
};
CFPropertyList.propertyListFromXML=function(_129){
var _12a=_129;
if(_129.valueOf&&typeof _129.valueOf()==="string"){
_12a=_a2(_129);
}
while(((String(_12a.nodeName))===_103)||((String(_12a.nodeName))===_102)){
_12a=(_12a.firstChild);
if(_12a!==NULL&&((_12a.nodeType)===8||(_12a.nodeType)===3)){
while((_12a=(_12a.nextSibling))&&((_12a.nodeType)===8||(_12a.nodeType)===3)){
}
}
}
if(((_12a.nodeType)===10)){
while((_12a=(_12a.nextSibling))&&((_12a.nodeType)===8||(_12a.nodeType)===3)){
}
}
if(!((String(_12a.nodeName))===_104)){
return NULL;
}
var key="",_12b=NULL,_12c=NULL,_12d=_12a,_12e=[],_12f=NULL;
while(_12a=_112(_12a,_12d,_12e)){
var _130=_12e.length;
if(_130){
_12f=_12e[_130-1];
}
if((String(_12a.nodeName))===_105){
key=(_12a.textContent||(_12a.textContent!==""&&_10f([_12a])));
while((_12a=(_12a.nextSibling))&&((_12a.nodeType)===8||(_12a.nodeType)===3)){
}
}
switch(String((String(_12a.nodeName)))){
case _107:
_12b=[];
_12e.push(_12b);
break;
case _106:
_12b=new CFMutableDictionary();
_12e.push(_12b);
break;
case _10c:
_12b=parseFloat((_12a.textContent||(_12a.textContent!==""&&_10f([_12a]))));
break;
case _10d:
_12b=parseInt((_12a.textContent||(_12a.textContent!==""&&_10f([_12a]))),10);
break;
case _108:
if((_12a.getAttribute("type")==="base64")){
_12b=(_12a.firstChild)?CFData.decodeBase64ToString((_12a.textContent||(_12a.textContent!==""&&_10f([_12a])))):"";
}else{
_12b=_125((_12a.firstChild)?(_12a.textContent||(_12a.textContent!==""&&_10f([_12a]))):"");
}
break;
case _109:
var _131=Date.parseISO8601((_12a.textContent||(_12a.textContent!==""&&_10f([_12a]))));
_12b=isNaN(_131)?new Date():new Date(_131);
break;
case _10a:
_12b=YES;
break;
case _10b:
_12b=NO;
break;
case _10e:
_12b=new CFMutableData();
var _132=(_12a.firstChild)?CFData.decodeBase64ToArray((_12a.textContent||(_12a.textContent!==""&&_10f([_12a]))),YES):[];
_12b.setBytes(_132);
break;
default:
throw new Error("*** "+(String(_12a.nodeName))+" tag not recognized in Plist.");
}
if(!_12c){
_12c=_12b;
}else{
if(_12f){
if(_12f.slice){
_12f.push(_12b);
}else{
_12f.setValueForKey(key,_12b);
}
}
}
}
return _12c;
};
kCFPropertyListOpenStepFormat=CFPropertyList.FormatOpenStep;
kCFPropertyListXMLFormat_v1_0=CFPropertyList.FormatXML_v1_0;
kCFPropertyListBinaryFormat_v1_0=CFPropertyList.FormatBinary_v1_0;
kCFPropertyList280NorthFormat_v1_0=CFPropertyList.Format280North_v1_0;
CFPropertyListCreate=function(){
return new CFPropertyList();
};
CFPropertyListCreateFromXMLData=function(data){
return CFPropertyList.propertyListFromData(data,CFPropertyList.FormatXML_v1_0);
};
CFPropertyListCreateXMLData=function(_133){
return CFPropertyList.dataFromPropertyList(_133,CFPropertyList.FormatXML_v1_0);
};
CFPropertyListCreateFrom280NorthData=function(data){
return CFPropertyList.propertyListFromData(data,CFPropertyList.Format280North_v1_0);
};
CFPropertyListCreate280NorthData=function(_134){
return CFPropertyList.dataFromPropertyList(_134,CFPropertyList.Format280North_v1_0);
};
CPPropertyListCreateFromData=function(data,_135){
return CFPropertyList.propertyListFromData(data,_135);
};
CPPropertyListCreateData=function(_136,_137){
return CFPropertyList.dataFromPropertyList(_136,_137);
};
CFDictionary=function(_138){
this._keys=[];
this._count=0;
this._buckets={};
this._UID=objj_generateObjectUID();
};
var _139=Array.prototype.indexOf,_82=Object.prototype.hasOwnProperty;
CFDictionary.prototype.copy=function(){
return this;
};
CFDictionary.prototype.mutableCopy=function(){
var _13a=new CFMutableDictionary(),keys=this._keys,_13b=this._count;
_13a._keys=keys.slice();
_13a._count=_13b;
var _13c=0,_13d=this._buckets,_13e=_13a._buckets;
for(;_13c<_13b;++_13c){
var key=keys[_13c];
_13e[key]=_13d[key];
}
return _13a;
};
CFDictionary.prototype.containsKey=function(aKey){
return _82.apply(this._buckets,[aKey]);
};
CFDictionary.prototype.containsValue=function(_13f){
var keys=this._keys,_140=this._buckets,_9d=0,_141=keys.length;
for(;_9d<_141;++_9d){
if(_140[keys[_9d]]===_13f){
return YES;
}
}
return NO;
};
CFDictionary.prototype.count=function(){
return this._count;
};
CFDictionary.prototype.countOfKey=function(aKey){
return this.containsKey(aKey)?1:0;
};
CFDictionary.prototype.countOfValue=function(_142){
var keys=this._keys,_143=this._buckets,_9d=0,_144=keys.length,_145=0;
for(;_9d<_144;++_9d){
if(_143[keys[_9d]]===_142){
++_145;
}
}
return _145;
};
CFDictionary.prototype.keys=function(){
return this._keys.slice();
};
CFDictionary.prototype.valueForKey=function(aKey){
var _146=this._buckets;
if(!_82.apply(_146,[aKey])){
return nil;
}
return _146[aKey];
};
CFDictionary.prototype.toString=function(){
var _147="{\n",keys=this._keys,_9d=0,_148=this._count;
for(;_9d<_148;++_9d){
var key=keys[_9d];
_147+="\t"+key+" = \""+String(this.valueForKey(key)).split("\n").join("\n\t")+"\"\n";
}
return _147+"}";
};
CFMutableDictionary=function(_149){
CFDictionary.apply(this,[]);
};
CFMutableDictionary.prototype=new CFDictionary();
CFMutableDictionary.prototype.copy=function(){
return this.mutableCopy();
};
CFMutableDictionary.prototype.addValueForKey=function(aKey,_14a){
if(this.containsKey(aKey)){
return;
}
++this._count;
this._keys.push(aKey);
this._buckets[aKey]=_14a;
};
CFMutableDictionary.prototype.removeValueForKey=function(aKey){
var _14b=-1;
if(_139){
_14b=_139.call(this._keys,aKey);
}else{
var keys=this._keys,_9d=0,_14c=keys.length;
for(;_9d<_14c;++_9d){
if(keys[_9d]===aKey){
_14b=_9d;
break;
}
}
}
if(_14b===-1){
return;
}
--this._count;
this._keys.splice(_14b,1);
delete this._buckets[aKey];
};
CFMutableDictionary.prototype.removeAllValues=function(){
this._count=0;
this._keys=[];
this._buckets={};
};
CFMutableDictionary.prototype.replaceValueForKey=function(aKey,_14d){
if(!this.containsKey(aKey)){
return;
}
this._buckets[aKey]=_14d;
};
CFMutableDictionary.prototype.setValueForKey=function(aKey,_14e){
if(_14e===nil||_14e===_2f){
this.removeValueForKey(aKey);
}else{
if(this.containsKey(aKey)){
this.replaceValueForKey(aKey,_14e);
}else{
this.addValueForKey(aKey,_14e);
}
}
};
kCFErrorLocalizedDescriptionKey="CPLocalizedDescription";
kCFErrorLocalizedFailureReasonKey="CPLocalizedFailureReason";
kCFErrorLocalizedRecoverySuggestionKey="CPLocalizedRecoverySuggestion";
kCFErrorDescriptionKey="CPDescription";
kCFErrorUnderlyingErrorKey="CPUnderlyingError";
kCFErrorURLKey="CPURL";
kCFErrorFilePathKey="CPFilePath";
kCFErrorDomainCappuccino="CPCappuccinoErrorDomain";
kCFErrorDomainCocoa=kCFErrorDomainCappuccino;
CFError=function(_14f,code,_150){
this._domain=_14f||NULL;
this._code=code||0;
this._userInfo=_150||new CFDictionary();
this._UID=objj_generateObjectUID();
};
CFError.prototype.domain=function(){
return this._domain;
};
CFError.prototype.code=function(){
return this._code;
};
CFError.prototype.description=function(){
var _151=this._userInfo.valueForKey(kCFErrorLocalizedDescriptionKey);
if(_151){
return _151;
}
var _152=this._userInfo.valueForKey(kCFErrorLocalizedFailureReasonKey);
if(_152){
var _153="The operation couldn’t be completed. "+_152;
return _153;
}
var _154="",desc=this._userInfo.valueForKey(kCFErrorDescriptionKey);
if(desc){
var _154="The operation couldn’t be completed. (error "+this._code+" - "+desc+")";
}else{
var _154="The operation couldn’t be completed. (error "+this._code+")";
}
return _154;
};
CFError.prototype.failureReason=function(){
return this._userInfo.valueForKey(kCFErrorLocalizedFailureReasonKey);
};
CFError.prototype.recoverySuggestion=function(){
return this._userInfo.valueForKey(kCFErrorLocalizedRecoverySuggestionKey);
};
CFError.prototype.userInfo=function(){
return this._userInfo;
};
CFErrorCreate=function(_155,code,_156){
return new CFError(_155,code,_156);
};
CFErrorCreateWithUserInfoKeysAndValues=function(_157,code,_158,_159,_15a){
var _15b=new CFMutableDictionary();
while(_15a--){
_15b.setValueForKey(_158[_15a],_159[_15a]);
}
return new CFError(_157,code,_15b);
};
CFErrorGetCode=function(err){
return err.code();
};
CFErrorGetDomain=function(err){
return err.domain();
};
CFErrorCopyDescription=function(err){
return err.description();
};
CFErrorCopyUserInfo=function(err){
return err.userInfo();
};
CFErrorCopyFailureReason=function(err){
return err.failureReason();
};
CFErrorCopyRecoverySuggestion=function(err){
return err.recoverySuggestion();
};
kCFURLErrorUnknown=-998;
kCFURLErrorCancelled=-999;
kCFURLErrorBadURL=-1000;
kCFURLErrorTimedOut=-1001;
kCFURLErrorUnsupportedURL=-1002;
kCFURLErrorCannotFindHost=-1003;
kCFURLErrorCannotConnectToHost=-1004;
kCFURLErrorNetworkConnectionLost=-1005;
kCFURLErrorDNSLookupFailed=-1006;
kCFURLErrorHTTPTooManyRedirects=-1007;
kCFURLErrorResourceUnavailable=-1008;
kCFURLErrorNotConnectedToInternet=-1009;
kCFURLErrorRedirectToNonExistentLocation=-1010;
kCFURLErrorBadServerResponse=-1011;
kCFURLErrorUserCancelledAuthentication=-1012;
kCFURLErrorUserAuthenticationRequired=-1013;
kCFURLErrorZeroByteResource=-1014;
kCFURLErrorCannotDecodeRawData=-1015;
kCFURLErrorCannotDecodeContentData=-1016;
kCFURLErrorCannotParseResponse=-1017;
kCFURLErrorRequestBodyStreamExhausted=-1021;
kCFURLErrorFileDoesNotExist=-1100;
kCFURLErrorFileIsDirectory=-1101;
kCFURLErrorNoPermissionsToReadFile=-1102;
kCFURLErrorDataLengthExceedsMaximum=-1103;
CFData=function(){
this._rawString=NULL;
this._propertyList=NULL;
this._propertyListFormat=NULL;
this._JSONObject=NULL;
this._bytes=NULL;
this._base64=NULL;
};
CFData.prototype.propertyList=function(){
if(!this._propertyList){
this._propertyList=CFPropertyList.propertyListFromString(this.rawString());
}
return this._propertyList;
};
CFData.prototype.JSONObject=function(){
if(!this._JSONObject){
try{
this._JSONObject=JSON.parse(this.rawString());
}
catch(anException){
}
}
return this._JSONObject;
};
CFData.prototype.rawString=function(){
if(this._rawString===NULL){
if(this._propertyList){
this._rawString=CFPropertyList.stringFromPropertyList(this._propertyList,this._propertyListFormat);
}else{
if(this._JSONObject){
this._rawString=JSON.stringify(this._JSONObject);
}else{
if(this._bytes){
this._rawString=CFData.bytesToString(this._bytes);
}else{
if(this._base64){
this._rawString=CFData.decodeBase64ToString(this._base64,true);
}else{
throw new Error("Can't convert data to string.");
}
}
}
}
}
return this._rawString;
};
CFData.prototype.bytes=function(){
if(this._bytes===NULL){
var _15c=CFData.stringToBytes(this.rawString());
this.setBytes(_15c);
}
return this._bytes;
};
CFData.prototype.base64=function(){
if(this._base64===NULL){
var _15d;
if(this._bytes){
_15d=CFData.encodeBase64Array(this._bytes);
}else{
_15d=CFData.encodeBase64String(this.rawString());
}
this.setBase64String(_15d);
}
return this._base64;
};
CFMutableData=function(){
CFData.call(this);
};
CFMutableData.prototype=new CFData();
function _15e(_15f){
this._rawString=NULL;
this._propertyList=NULL;
this._propertyListFormat=NULL;
this._JSONObject=NULL;
this._bytes=NULL;
this._base64=NULL;
};
CFMutableData.prototype.setPropertyList=function(_160,_161){
_15e(this);
this._propertyList=_160;
this._propertyListFormat=_161;
};
CFMutableData.prototype.setJSONObject=function(_162){
_15e(this);
this._JSONObject=_162;
};
CFMutableData.prototype.setRawString=function(_163){
_15e(this);
this._rawString=_163;
};
CFMutableData.prototype.setBytes=function(_164){
_15e(this);
this._bytes=_164;
};
CFMutableData.prototype.setBase64String=function(_165){
_15e(this);
this._base64=_165;
};
var _166=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9","+","/","="],_167=[];
for(var i=0;i<_166.length;i++){
_167[_166[i].charCodeAt(0)]=i;
}
CFData.decodeBase64ToArray=function(_168,_169){
if(_169){
_168=_168.replace(/[^A-Za-z0-9\+\/\=]/g,"");
}
var pad=(_168[_168.length-1]=="="?1:0)+(_168[_168.length-2]=="="?1:0),_16a=_168.length,_16b=[];
var i=0;
while(i<_16a){
var bits=(_167[_168.charCodeAt(i++)]<<18)|(_167[_168.charCodeAt(i++)]<<12)|(_167[_168.charCodeAt(i++)]<<6)|(_167[_168.charCodeAt(i++)]);
_16b.push((bits&16711680)>>16);
_16b.push((bits&65280)>>8);
_16b.push(bits&255);
}
if(pad>0){
return _16b.slice(0,-1*pad);
}
return _16b;
};
CFData.encodeBase64Array=function(_16c){
var pad=(3-(_16c.length%3))%3,_16d=_16c.length+pad,_16e=[];
if(pad>0){
_16c.push(0);
}
if(pad>1){
_16c.push(0);
}
var i=0;
while(i<_16d){
var bits=(_16c[i++]<<16)|(_16c[i++]<<8)|(_16c[i++]);
_16e.push(_166[(bits&16515072)>>18]);
_16e.push(_166[(bits&258048)>>12]);
_16e.push(_166[(bits&4032)>>6]);
_16e.push(_166[bits&63]);
}
if(pad>0){
_16e[_16e.length-1]="=";
_16c.pop();
}
if(pad>1){
_16e[_16e.length-2]="=";
_16c.pop();
}
return _16e.join("");
};
CFData.decodeBase64ToString=function(_16f,_170){
return CFData.bytesToString(CFData.decodeBase64ToArray(_16f,_170));
};
CFData.decodeBase64ToUtf16String=function(_171,_172){
return CFData.bytesToUtf16String(CFData.decodeBase64ToArray(_171,_172));
};
CFData.bytesToString=function(_173){
return String.fromCharCode.apply(NULL,_173);
};
CFData.stringToBytes=function(_174){
var temp=[];
for(var i=0;i<_174.length;i++){
temp.push(_174.charCodeAt(i));
}
return temp;
};
CFData.encodeBase64String=function(_175){
var temp=[];
for(var i=0;i<_175.length;i++){
temp.push(_175.charCodeAt(i));
}
return CFData.encodeBase64Array(temp);
};
CFData.bytesToUtf16String=function(_176){
var temp=[];
for(var i=0;i<_176.length;i+=2){
temp.push(_176[i+1]<<8|_176[i]);
}
return String.fromCharCode.apply(NULL,temp);
};
CFData.encodeBase64Utf16String=function(_177){
var temp=[];
for(var i=0;i<_177.length;i++){
var c=_177.charCodeAt(i);
temp.push(c&255);
temp.push((c&65280)>>8);
}
return CFData.encodeBase64Array(temp);
};
var _178,_179,_17a=0;
function _17b(){
if(++_17a!==1){
return;
}
_178={};
_179={};
};
function _17c(){
_17a=MAX(_17a-1,0);
if(_17a!==0){
return;
}
delete _178;
delete _179;
};
var _17d=new RegExp("^"+"(?:"+"([^:/?#]+):"+")?"+"(?:"+"(//)"+"("+"(?:"+"("+"([^:@]*)"+":?"+"([^:@]*)"+")?"+"@"+")?"+"([^:/?#]*)"+"(?::(\\d*))?"+")"+")?"+"([^?#]*)"+"(?:\\?([^#]*))?"+"(?:#(.*))?");
var _17e=["url","scheme","authorityRoot","authority","userInfo","user","password","domain","portNumber","path","queryString","fragment"];
function _17f(aURL){
if(aURL._parts){
return aURL._parts;
}
var _180=aURL.string(),_181=_180.match(/^mhtml:/);
if(_181){
_180=_180.substr("mhtml:".length);
}
if(_17a>0&&_82.call(_179,_180)){
aURL._parts=_179[_180];
return aURL._parts;
}
aURL._parts={};
var _182=aURL._parts,_183=_17d.exec(_180),_9d=_183.length;
while(_9d--){
_182[_17e[_9d]]=_183[_9d]||NULL;
}
_182.portNumber=parseInt(_182.portNumber,10);
if(isNaN(_182.portNumber)){
_182.portNumber=-1;
}
_182.pathComponents=[];
if(_182.path){
var _184=_182.path.split("/"),_185=_182.pathComponents,_186=_184.length;
for(_9d=0;_9d<_186;++_9d){
var _187=_184[_9d];
if(_187){
_185.push(_187);
}else{
if(_9d===0){
_185.push("/");
}
}
}
_182.pathComponents=_185;
}
if(_181){
_182.url="mhtml:"+_182.url;
_182.scheme="mhtml:"+_182.scheme;
}
if(_17a>0){
_179[_180]=_182;
}
return _182;
};
CFURL=function(aURL,_188){
aURL=aURL||"";
if(aURL instanceof CFURL){
if(!_188){
return new CFURL(aURL.absoluteString());
}
var _189=aURL.baseURL();
if(_189){
_188=new CFURL(_189.absoluteURL(),_188);
}
aURL=aURL.string();
}
if(_17a>0){
var _18a=aURL+" "+(_188&&_188.UID()||"");
if(_82.call(_178,_18a)){
return _178[_18a];
}
_178[_18a]=this;
}
if(aURL.match(/^data:/)){
var _18b={},_9d=_17e.length;
while(_9d--){
_18b[_17e[_9d]]="";
}
_18b.url=aURL;
_18b.scheme="data";
_18b.pathComponents=[];
this._parts=_18b;
this._standardizedURL=this;
this._absoluteURL=this;
}
this._UID=objj_generateObjectUID();
this._string=aURL;
this._baseURL=_188;
};
CFURL.prototype.UID=function(){
return this._UID;
};
var _18c={};
CFURL.prototype.mappedURL=function(){
return _18c[this.absoluteString()]||this;
};
CFURL.setMappedURLForURL=function(_18d,_18e){
_18c[_18d.absoluteString()]=_18e;
};
CFURL.prototype.schemeAndAuthority=function(){
var _18f="",_190=this.scheme();
if(_190){
_18f+=_190+":";
}
var _191=this.authority();
if(_191){
_18f+="//"+_191;
}
return _18f;
};
CFURL.prototype.absoluteString=function(){
if(this._absoluteString===_2f){
this._absoluteString=this.absoluteURL().string();
}
return this._absoluteString;
};
CFURL.prototype.toString=function(){
return this.absoluteString();
};
function _192(aURL){
aURL=aURL.standardizedURL();
var _193=aURL.baseURL();
if(!_193){
return aURL;
}
var _194=((aURL)._parts||_17f(aURL)),_195,_196=_193.absoluteURL(),_197=((_196)._parts||_17f(_196));
if(!_194.scheme&&_194.authorityRoot){
_195=_198(_194);
_195.scheme=_193.scheme();
}else{
if(_194.scheme||_194.authority){
_195=_194;
}else{
_195={};
_195.scheme=_197.scheme;
_195.authority=_197.authority;
_195.userInfo=_197.userInfo;
_195.user=_197.user;
_195.password=_197.password;
_195.domain=_197.domain;
_195.portNumber=_197.portNumber;
_195.queryString=_194.queryString;
_195.fragment=_194.fragment;
var _199=_194.pathComponents;
if(_199.length&&_199[0]==="/"){
_195.path=_194.path;
_195.pathComponents=_199;
}else{
var _19a=_197.pathComponents,_19b=_19a.concat(_199);
if(!_193.hasDirectoryPath()&&_19a.length){
_19b.splice(_19a.length-1,1);
}
if(_199.length&&(_199[0]===".."||_199[0]===".")){
_19c(_19b,YES);
}
_195.pathComponents=_19b;
_195.path=_19d(_19b,_199.length<=0||aURL.hasDirectoryPath());
}
}
}
var _19e=_19f(_195),_1a0=new CFURL(_19e);
_1a0._parts=_195;
_1a0._standardizedURL=_1a0;
_1a0._standardizedString=_19e;
_1a0._absoluteURL=_1a0;
_1a0._absoluteString=_19e;
return _1a0;
};
function _19d(_1a1,_1a2){
var path=_1a1.join("/");
if(path.length&&path.charAt(0)==="/"){
path=path.substr(1);
}
if(_1a2){
path+="/";
}
return path;
};
function _19c(_1a3,_1a4){
var _1a5=0,_1a6=0,_1a7=_1a3.length,_1a8=_1a4?_1a3:[],_1a9=NO;
for(;_1a5<_1a7;++_1a5){
var _1aa=_1a3[_1a5];
if(_1aa===""){
continue;
}
if(_1aa==="."){
_1a9=_1a6===0;
continue;
}
if(_1aa!==".."||_1a6===0||_1a8[_1a6-1]===".."){
_1a8[_1a6]=_1aa;
_1a6++;
continue;
}
if(_1a6>0&&_1a8[_1a6-1]!=="/"){
--_1a6;
}
}
if(_1a9&&_1a6===0){
_1a8[_1a6++]=".";
}
_1a8.length=_1a6;
return _1a8;
};
function _19f(_1ab){
var _1ac="",_1ad=_1ab.scheme;
if(_1ad){
_1ac+=_1ad+":";
}
var _1ae=_1ab.authority;
if(_1ae){
_1ac+="//"+_1ae;
}
_1ac+=_1ab.path;
var _1af=_1ab.queryString;
if(_1af){
_1ac+="?"+_1af;
}
var _1b0=_1ab.fragment;
if(_1b0){
_1ac+="#"+_1b0;
}
return _1ac;
};
CFURL.prototype.absoluteURL=function(){
if(this._absoluteURL===_2f){
this._absoluteURL=_192(this);
}
return this._absoluteURL;
};
CFURL.prototype.standardizedURL=function(){
if(this._standardizedURL===_2f){
var _1b1=((this)._parts||_17f(this)),_1b2=_1b1.pathComponents,_1b3=_19c(_1b2,NO);
var _1b4=_19d(_1b3,this.hasDirectoryPath());
if(_1b1.path===_1b4){
this._standardizedURL=this;
}else{
var _1b5=_198(_1b1);
_1b5.pathComponents=_1b3;
_1b5.path=_1b4;
var _1b6=new CFURL(_19f(_1b5),this.baseURL());
_1b6._parts=_1b5;
_1b6._standardizedURL=_1b6;
this._standardizedURL=_1b6;
}
}
return this._standardizedURL;
};
function _198(_1b7){
var _1b8={},_1b9=_17e.length;
while(_1b9--){
var _1ba=_17e[_1b9];
_1b8[_1ba]=_1b7[_1ba];
}
return _1b8;
};
CFURL.prototype.string=function(){
return this._string;
};
CFURL.prototype.authority=function(){
var _1bb=((this)._parts||_17f(this)).authority;
if(_1bb){
return _1bb;
}
var _1bc=this.baseURL();
return _1bc&&_1bc.authority()||"";
};
CFURL.prototype.hasDirectoryPath=function(){
var _1bd=this._hasDirectoryPath;
if(_1bd===_2f){
var path=this.path();
if(!path){
return NO;
}
if(path.charAt(path.length-1)==="/"){
return YES;
}
var _1be=this.lastPathComponent();
_1bd=_1be==="."||_1be==="..";
this._hasDirectoryPath=_1bd;
}
return _1bd;
};
CFURL.prototype.hostName=function(){
return this.authority();
};
CFURL.prototype.fragment=function(){
return ((this)._parts||_17f(this)).fragment;
};
CFURL.prototype.lastPathComponent=function(){
if(this._lastPathComponent===_2f){
var _1bf=this.pathComponents(),_1c0=_1bf.length;
if(!_1c0){
this._lastPathComponent="";
}else{
this._lastPathComponent=_1bf[_1c0-1];
}
}
return this._lastPathComponent;
};
CFURL.prototype.path=function(){
return ((this)._parts||_17f(this)).path;
};
CFURL.prototype.createCopyDeletingLastPathComponent=function(){
var _1c1=((this)._parts||_17f(this)),_1c2=_19c(_1c1.pathComponents,NO);
if(_1c2.length>0){
if(_1c2.length>1||_1c2[0]!=="/"){
_1c2.pop();
}
}
var _1c3=_1c2.length===1&&_1c2[0]==="/";
_1c1.pathComponents=_1c2;
_1c1.path=_1c3?"/":_19d(_1c2,NO);
return new CFURL(_19f(_1c1));
};
CFURL.prototype.pathComponents=function(){
return ((this)._parts||_17f(this)).pathComponents;
};
CFURL.prototype.pathExtension=function(){
var _1c4=this.lastPathComponent();
if(!_1c4){
return NULL;
}
_1c4=_1c4.replace(/^\.*/,"");
var _1c5=_1c4.lastIndexOf(".");
return _1c5<=0?"":_1c4.substring(_1c5+1);
};
CFURL.prototype.queryString=function(){
return ((this)._parts||_17f(this)).queryString;
};
CFURL.prototype.scheme=function(){
var _1c6=this._scheme;
if(_1c6===_2f){
_1c6=((this)._parts||_17f(this)).scheme;
if(!_1c6){
var _1c7=this.baseURL();
_1c6=_1c7&&_1c7.scheme();
}
this._scheme=_1c6;
}
return _1c6;
};
CFURL.prototype.user=function(){
return ((this)._parts||_17f(this)).user;
};
CFURL.prototype.password=function(){
return ((this)._parts||_17f(this)).password;
};
CFURL.prototype.portNumber=function(){
return ((this)._parts||_17f(this)).portNumber;
};
CFURL.prototype.domain=function(){
return ((this)._parts||_17f(this)).domain;
};
CFURL.prototype.baseURL=function(){
return this._baseURL;
};
CFURL.prototype.asDirectoryPathURL=function(){
if(this.hasDirectoryPath()){
return this;
}
var _1c8=this.lastPathComponent();
if(_1c8!=="/"){
_1c8="./"+_1c8;
}
return new CFURL(_1c8+"/",this);
};
function _1c9(aURL){
if(!aURL._resourcePropertiesForKeys){
aURL._resourcePropertiesForKeys=new CFMutableDictionary();
}
return aURL._resourcePropertiesForKeys;
};
CFURL.prototype.resourcePropertyForKey=function(aKey){
return _1c9(this).valueForKey(aKey);
};
CFURL.prototype.setResourcePropertyForKey=function(aKey,_1ca){
_1c9(this).setValueForKey(aKey,_1ca);
};
CFURL.prototype.staticResourceData=function(){
var data=new CFMutableData();
data.setRawString(_1cb.resourceAtURL(this).contents());
return data;
};
function _11d(_1cc){
this._string=_1cc;
var _1cd=_1cc.indexOf(";");
this._magicNumber=_1cc.substr(0,_1cd);
this._location=_1cc.indexOf(";",++_1cd);
this._version=_1cc.substring(_1cd,this._location++);
};
_11d.prototype.magicNumber=function(){
return this._magicNumber;
};
_11d.prototype.version=function(){
return this._version;
};
_11d.prototype.getMarker=function(){
var _1ce=this._string,_1cf=this._location;
if(_1cf>=_1ce.length){
return null;
}
var next=_1ce.indexOf(";",_1cf);
if(next<0){
return null;
}
var _1d0=_1ce.substring(_1cf,next);
if(_1d0==="e"){
return null;
}
this._location=next+1;
return _1d0;
};
_11d.prototype.getString=function(){
var _1d1=this._string,_1d2=this._location;
if(_1d2>=_1d1.length){
return null;
}
var next=_1d1.indexOf(";",_1d2);
if(next<0){
return null;
}
var size=parseInt(_1d1.substring(_1d2,next),10),text=_1d1.substr(next+1,size);
this._location=next+1+size;
return text;
};
var _1d3=0,_1d4=1<<0,_1d5=1<<1,_1d6=1<<2,_1d7=1<<3,_1d8=1<<4,_1d9=1<<5;
var _1da={},_1db={},_1dc={},_1dd=new Date().getTime(),_1de=0,_1df=0;
var _1e0="CPBundleDefaultBrowserLanguage",_1e1="CPBundleDefaultLanguage";
CFBundle=function(aURL){
aURL=_1e2(aURL).asDirectoryPathURL();
var _1e3=aURL.absoluteString(),_1e4=_1da[_1e3];
if(_1e4){
return _1e4;
}
_1da[_1e3]=this;
this._bundleURL=aURL;
this._resourcesDirectoryURL=new CFURL("Resources/",aURL);
this._staticResource=NULL;
this._isValid=NO;
this._loadStatus=_1d3;
this._loadRequests=[];
this._infoDictionary=new CFDictionary();
this._eventDispatcher=new _7d(this);
this._localizableStrings=[];
this._loadedLanguage=NULL;
};
CFBundle.environments=function(){
return ["Browser","ObjJ"];
};
CFBundle.bundleContainingURL=function(aURL){
aURL=new CFURL(".",_1e2(aURL));
var _1e5,_1e6=aURL.absoluteString();
while(!_1e5||_1e5!==_1e6){
var _1e7=_1da[_1e6];
if(_1e7&&_1e7._isValid){
return _1e7;
}
aURL=new CFURL("..",aURL);
_1e5=_1e6;
_1e6=aURL.absoluteString();
}
return NULL;
};
CFBundle.mainBundle=function(){
return new CFBundle(_1e8);
};
function _1e9(_1ea,_1eb){
if(_1eb){
_1db[_1ea.name]=_1eb;
}
};
function _1ec(){
_1da={};
_1db={};
_1dc={};
_1de=0;
_1df=0;
};
CFBundle.bundleForClass=function(_1ed){
return _1db[_1ed.name]||CFBundle.mainBundle();
};
CFBundle.bundleWithIdentifier=function(_1ee){
return _1dc[_1ee]||NULL;
};
CFBundle.prototype.bundleURL=function(){
return this._bundleURL.absoluteURL();
};
CFBundle.prototype.resourcesDirectoryURL=function(){
return this._resourcesDirectoryURL;
};
CFBundle.prototype.resourceURL=function(_1ef,_1f0,_1f1,_1f2){
if(_1f0){
_1ef=_1ef+"."+_1f0;
}
if(_1f2){
_1ef=_1f2+_1ef;
}
if(_1f1){
_1ef=_1f1+"/"+_1ef;
}
var _1f3=(new CFURL(_1ef,this.resourcesDirectoryURL())).mappedURL();
return _1f3.absoluteURL();
};
CFBundle.prototype.mostEligibleEnvironmentURL=function(){
if(this._mostEligibleEnvironmentURL===_2f){
this._mostEligibleEnvironmentURL=new CFURL(this.mostEligibleEnvironment()+".environment/",this.bundleURL());
}
return this._mostEligibleEnvironmentURL;
};
CFBundle.prototype.executableURL=function(){
if(this._executableURL===_2f){
var _1f4=this.valueForInfoDictionaryKey("CPBundleExecutable");
if(!_1f4){
this._executableURL=NULL;
}else{
this._executableURL=new CFURL(_1f4,this.mostEligibleEnvironmentURL());
}
}
return this._executableURL;
};
CFBundle.prototype.infoDictionary=function(){
return this._infoDictionary;
};
CFBundle.prototype.loadedLanguage=function(){
return this._loadedLanguage;
};
CFBundle.prototype.valueForInfoDictionaryKey=function(aKey){
return this._infoDictionary.valueForKey(aKey);
};
CFBundle.prototype.identifier=function(){
return this._infoDictionary.valueForKey("CPBundleIdentifier");
};
CFBundle.prototype.hasSpritedImages=function(){
var _1f5=this._infoDictionary.valueForKey("CPBundleEnvironmentsWithImageSprites")||[],_9d=_1f5.length,_1f6=this.mostEligibleEnvironment();
while(_9d--){
if(_1f5[_9d]===_1f6){
return YES;
}
}
return NO;
};
CFBundle.prototype.environments=function(){
return this._infoDictionary.valueForKey("CPBundleEnvironments")||["ObjJ"];
};
CFBundle.prototype.mostEligibleEnvironment=function(_1f7){
_1f7=_1f7||this.environments();
var _1f8=CFBundle.environments(),_9d=0,_1f9=_1f8.length,_1fa=_1f7.length;
for(;_9d<_1f9;++_9d){
var _1fb=0,_1fc=_1f8[_9d];
for(;_1fb<_1fa;++_1fb){
if(_1fc===_1f7[_1fb]){
return _1fc;
}
}
}
return NULL;
};
CFBundle.prototype.isLoading=function(){
return this._loadStatus&_1d4;
};
CFBundle.prototype.isLoaded=function(){
return !!(this._loadStatus&_1d9);
};
CFBundle.prototype.load=function(_1fd){
if(this._loadStatus!==_1d3){
return;
}
this._loadStatus=_1d4|_1d5;
var self=this,_1fe=this.bundleURL(),_1ff=new CFURL("..",_1fe);
if(_1ff.absoluteString()===_1fe.absoluteString()){
_1ff=_1ff.schemeAndAuthority();
}
_1cb.resolveResourceAtURL(_1ff,YES,function(_200){
var _201=_1fe.lastPathComponent();
self._staticResource=_200._children[_201]||new _1cb(_1fe,_200,YES,NO);
function _202(_203){
self._loadStatus&=~_1d5;
var _204=_203.request.responsePropertyList();
self._isValid=!!_204||CFBundle.mainBundle()===self;
if(_204){
self._infoDictionary=_204;
var _205=self._infoDictionary.valueForKey("CPBundleIdentifier");
if(_205){
_1dc[_205]=self;
}
}
if(!self._infoDictionary){
_207(self,new Error("Could not load bundle at \""+path+"\""));
return;
}
if(self===CFBundle.mainBundle()&&self.valueForInfoDictionaryKey("CPApplicationSize")){
_1df=self.valueForInfoDictionaryKey("CPApplicationSize").valueForKey("executable")||0;
}
_248(self);
_20b(self,_1fd);
};
function _206(){
self._isValid=CFBundle.mainBundle()===self;
self._loadStatus=_1d3;
_207(self,new Error("Could not load bundle at \""+self.bundleURL()+"\""));
};
new _be(new CFURL("Info.plist",self.bundleURL()),_202,_206);
});
};
function _207(_208,_209){
_20a(_208._staticResource);
_208._eventDispatcher.dispatchEvent({type:"error",error:_209,bundle:_208});
};
function _20b(_20c,_20d){
if(!_20c.mostEligibleEnvironment()){
return _20e();
}
_20f(_20c,_210,_20e,_211);
_212(_20c,_210,_20e,_211);
_213(_20c,_210,_20e,_211);
if(_20c._loadStatus===_1d4){
return _210();
}
function _20e(_214){
var _215=_20c._loadRequests,_216=_215.length;
while(_216--){
_215[_216].abort();
}
this._loadRequests=[];
_20c._loadStatus=_1d3;
_207(_20c,_214||new Error("Could not recognize executable code format in Bundle "+_20c));
};
function _211(_217){
if((typeof CPApp==="undefined"||!CPApp||!CPApp._finishedLaunching)&&typeof OBJJ_PROGRESS_CALLBACK==="function"){
_1de+=_217;
var _218=_1df?MAX(MIN(1,_1de/_1df),0):0;
OBJJ_PROGRESS_CALLBACK(_218,_1df,_20c.bundlePath());
}
};
function _210(){
if(_20c._loadStatus===_1d4){
_20c._loadStatus=_1d9;
}else{
return;
}
_20a(_20c._staticResource);
function _219(){
_20c._eventDispatcher.dispatchEvent({type:"load",bundle:_20c});
};
if(_20d){
_21a(_20c,_219);
}else{
_219();
}
};
};
function _20f(_21b,_21c,_21d,_21e){
var _21f=_21b.executableURL();
if(!_21f){
return;
}
_21b._loadStatus|=_1d6;
new _be(_21f,function(_220){
try{
_221(_21b,_220.request.responseText(),_21f);
_21b._loadStatus&=~_1d6;
_21c();
}
catch(anException){
_21d(anException);
}
},_21d,_21e);
};
function _222(_223){
return "mhtml:"+new CFURL("MHTMLTest.txt",_223.mostEligibleEnvironmentURL());
};
function _224(_225){
if(_226===_227){
return new CFURL("dataURLs.txt",_225.mostEligibleEnvironmentURL());
}
if(_226===_228||_226===_229){
return new CFURL("MHTMLPaths.txt",_225.mostEligibleEnvironmentURL());
}
return NULL;
};
function _212(_22a,_22b,_22c,_22d){
if(!_22a.hasSpritedImages()){
return;
}
_22a._loadStatus|=_1d7;
if(!_22e()){
return _22f(_222(_22a),function(){
_212(_22a,_22b,_22c,_22d);
});
}
var _230=_224(_22a);
if(!_230){
_22a._loadStatus&=~_1d7;
return _22b();
}
new _be(_230,function(_231){
try{
_221(_22a,_231.request.responseText(),_230);
_22a._loadStatus&=~_1d7;
_22b();
}
catch(anException){
_22c(anException);
}
},_22c,_22d);
};
function _213(_232,_233,_234,_235){
var _236=_232._loadedLanguage;
if(!_236){
return;
}
var _237=_232.valueForInfoDictionaryKey("CPBundleLocalizableStrings");
if(!_237){
return;
}
var self=_232,_238=_237.length,_239=new CFURL(_236+".lproj/",self.resourcesDirectoryURL()),_23a=0;
for(var i=0;i<_238;i++){
var _23b=_237[i];
function _23c(_23d){
var _23e=_23d.request.responseText(),_23f=new CFURL(_23d.request._URL).lastPathComponent();
try{
_240(self,_23e,_23f);
if(++_23a==_238){
_232._loadStatus&=~_1d8;
_233();
}
}
catch(e){
_234(new Error("Error when parsing the localizable file "+_23f));
}
};
_232._loadStatus|=_1d8;
new _be(new CFURL(_23b,_239),_23c,_234,_235);
}
};
function _240(_241,_242,_243){
var _244={},_245=_242.split("\n"),_246;
_241._localizableStrings[_243]=_244;
for(var i=0;i<_245.length;i++){
var line=_245[i];
if(line[0]=="/"){
_246=line.substring(2,line.length-2).trim();
continue;
}
if(line[0]=="\""){
var _247=line.split("\"");
var key=_247[1];
if(!(key in _244)){
_244[key]=_247[3];
}
key+=_246;
if(!(key in _244)){
_244[key]=_247[3];
}
continue;
}
}
};
function _248(_249){
if(_249._loadedLanguage){
return;
}
var _24a=_249.valueForInfoDictionaryKey(_1e1);
if(_24a!=_1e0&&_24a){
_249._loadedLanguage=_24a;
return;
}
if(typeof navigator=="undefined"){
return;
}
var _24b=(typeof navigator.language!=="undefined")?navigator.language:navigator.userLanguage;
if(!_24b){
return;
}
_249._loadedLanguage=_24b.substring(0,2);
};
var _24c=[],_226=-1,_24d=0,_227=1,_228=2,_229=3;
function _22e(){
return _226!==-1;
};
function _22f(_24e,_24f){
if(_22e()){
return;
}
_24c.push(_24f);
if(_24c.length>1){
return;
}
_24c.push(function(){
var size=0,_250=CFBundle.mainBundle().valueForInfoDictionaryKey("CPApplicationSize");
if(!_250){
return;
}
switch(_226){
case _227:
size=_250.valueForKey("data");
break;
case _228:
case _229:
size=_250.valueForKey("mhtml");
break;
}
_1df+=size;
});
_251([_227,"data:image/gif;base64,R0lGODlhAQABAIAAAMc9BQAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==",_228,_24e+"!test",_229,_24e+"?"+_1dd+"!test"]);
};
function _252(){
var _253=_24c.length;
while(_253--){
_24c[_253]();
}
};
function _251(_254){
if(!("Image" in _1)||_254.length<2){
_226=_24d;
_252();
return;
}
var _255=new Image();
_255.onload=function(){
if(_255.width===1&&_255.height===1){
_226=_254[0];
_252();
}else{
_255.onerror();
}
};
_255.onerror=function(){
_251(_254.slice(2));
};
_255.src=_254[1];
};
function _21a(_256,_257){
var _258=[_256._staticResource];
function _259(_25a){
for(;_25a<_258.length;++_25a){
var _25b=_258[_25a];
if(_25b.isNotFound()){
continue;
}
if(_25b.isFile()){
var _25c=new _7c5(_25b.URL());
if(_25c.hasLoadedFileDependencies()){
_25c.execute();
}else{
_25c.loadFileDependencies(function(){
_259(_25a);
});
return;
}
}else{
if(_25b.URL().absoluteString()===_256.resourcesDirectoryURL().absoluteString()){
continue;
}
var _25d=_25b.children();
for(var name in _25d){
if(_82.call(_25d,name)){
_258.push(_25d[name]);
}
}
}
}
_257();
};
_259(0);
};
var _25e="@STATIC",_25f="p",_260="u",_261="c",_262="t",_263="I",_264="i";
function _221(_265,_266,_267){
var _268=new _11d(_266);
if(_268.magicNumber()!==_25e){
throw new Error("Could not read static file: "+_267);
}
if(_268.version()!=="1.0"){
throw new Error("Could not read static file: "+_267);
}
var _269,_26a=_265.bundleURL(),file=NULL;
while(_269=_268.getMarker()){
var text=_268.getString();
if(_269===_25f){
var _26b=new CFURL(text,_26a),_26c=_1cb.resourceAtURL(new CFURL(".",_26b),YES);
file=new _1cb(_26b,_26c,NO,YES);
}else{
if(_269===_260){
var URL=new CFURL(text,_26a),_26d=_268.getString();
if(_26d.indexOf("mhtml:")===0){
_26d="mhtml:"+new CFURL(_26d.substr("mhtml:".length),_26a);
if(_226===_229){
var _26e=_26d.indexOf("!"),_26f=_26d.substring(0,_26e),_270=_26d.substring(_26e);
_26d=_26f+"?"+_1dd+_270;
}
}
CFURL.setMappedURLForURL(URL,new CFURL(_26d));
var _26c=_1cb.resourceAtURL(new CFURL(".",URL),YES);
new _1cb(URL,_26c,NO,YES);
}else{
if(_269===_262){
file.write(text);
}
}
}
}
};
CFBundle.prototype.addEventListener=function(_271,_272){
this._eventDispatcher.addEventListener(_271,_272);
};
CFBundle.prototype.removeEventListener=function(_273,_274){
this._eventDispatcher.removeEventListener(_273,_274);
};
CFBundle.prototype.onerror=function(_275){
throw _275.error;
};
CFBundle.prototype.bundlePath=function(){
return this.bundleURL().path();
};
CFBundle.prototype.path=function(){
CPLog.warn("CFBundle.prototype.path is deprecated, use CFBundle.prototype.bundlePath instead.");
return this.bundlePath.apply(this,arguments);
};
CFBundle.prototype.pathForResource=function(_276,_277,_278,_279){
return this.resourceURL(_276,_277,_278,_279).absoluteString();
};
CFBundleCopyLocalizedString=function(_27a,key,_27b,_27c){
return CFCopyLocalizedStringWithDefaultValue(key,_27c,_27a,_27b,"");
};
CFBundleCopyBundleLocalizations=function(_27d){
return [this._loadedLanguage];
};
CFCopyLocalizedString=function(key,_27e){
return CFCopyLocalizedStringFromTable(key,"Localizable",_27e);
};
CFCopyLocalizedStringFromTable=function(key,_27f,_280){
return CFCopyLocalizedStringFromTableInBundle(key,_27f,CFBundleGetMainBundle(),_280);
};
CFCopyLocalizedStringFromTableInBundle=function(key,_281,_282,_283){
return CFCopyLocalizedStringWithDefaultValue(key,_281,_282,null,_283);
};
CFCopyLocalizedStringWithDefaultValue=function(key,_284,_285,_286,_287){
var _288;
if(!_284){
_284="Localizable";
}
_284+=".strings";
var _289=_285._localizableStrings[_284];
_288=_289?_289[key+_287]:null;
return _288||(_286||key);
};
CFBundleGetMainBundle=function(){
return CFBundle.mainBundle();
};
var _28a={};
function _1cb(aURL,_28b,_28c,_28d,_28e){
this._parent=_28b;
this._eventDispatcher=new _7d(this);
var name=aURL.absoluteURL().lastPathComponent()||aURL.schemeAndAuthority();
this._name=name;
this._URL=aURL;
this._isResolved=!!_28d;
this._filenameTranslateDictionary=_28e;
if(_28c){
this._URL=this._URL.asDirectoryPathURL();
}
if(!_28b){
_28a[name]=this;
}
this._isDirectory=!!_28c;
this._isNotFound=NO;
if(_28b){
_28b._children[name]=this;
}
if(_28c){
this._children={};
}else{
this._contents="";
}
};
_1cb.rootResources=function(){
return _28a;
};
function _28f(x){
var _290=0;
for(var k in x){
if(x.hasOwnProperty(k)){
++_290;
}
}
return _290;
};
_1cb.resetRootResources=function(){
_28a={};
};
_1cb.prototype.filenameTranslateDictionary=function(){
return this._filenameTranslateDictionary||{};
};
_2.StaticResource=_1cb;
function _20a(_291){
_291._isResolved=YES;
_291._eventDispatcher.dispatchEvent({type:"resolve",staticResource:_291});
};
_1cb.prototype.resolve=function(){
if(this.isDirectory()){
var _292=new CFBundle(this.URL());
_292.onerror=function(){
};
_292.load(NO);
}else{
var self=this;
function _293(_294){
self._contents=_294.request.responseText();
_20a(self);
};
function _295(){
self._isNotFound=YES;
_20a(self);
};
var url=this.URL(),_296=this.filenameTranslateDictionary();
if(_296){
var _297=url.toString(),_298=url.lastPathComponent(),_299=_297.substring(0,_297.length-_298.length),_29a=_296[_298];
if(_29a&&_297.slice(-_29a.length)!==_29a){
url=new CFURL(_299+_29a);
}
}
new _be(url,_293,_295);
}
};
_1cb.prototype.name=function(){
return this._name;
};
_1cb.prototype.URL=function(){
return this._URL;
};
_1cb.prototype.contents=function(){
return this._contents;
};
_1cb.prototype.children=function(){
return this._children;
};
_1cb.prototype.parent=function(){
return this._parent;
};
_1cb.prototype.isResolved=function(){
return this._isResolved;
};
_1cb.prototype.write=function(_29b){
this._contents+=_29b;
};
function _29c(_29d){
var _29e=_29d.schemeAndAuthority(),_29f=_28a[_29e];
if(!_29f){
_29f=new _1cb(new CFURL(_29e),NULL,YES,YES);
}
return _29f;
};
_1cb.resourceAtURL=function(aURL,_2a0){
aURL=_1e2(aURL).absoluteURL();
var _2a1=_29c(aURL),_2a2=aURL.pathComponents(),_9d=0,_2a3=_2a2.length;
for(;_9d<_2a3;++_9d){
var name=_2a2[_9d];
if(_82.call(_2a1._children,name)){
_2a1=_2a1._children[name];
}else{
if(_2a0){
if(name!=="/"){
name="./"+name;
}
_2a1=new _1cb(new CFURL(name,_2a1.URL()),_2a1,YES,YES);
}else{
throw new Error("Static Resource at "+aURL+" is not resolved (\""+name+"\")");
}
}
}
return _2a1;
};
_1cb.prototype.resourceAtURL=function(aURL,_2a4){
return _1cb.resourceAtURL(new CFURL(aURL,this.URL()),_2a4);
};
_1cb.resolveResourceAtURL=function(aURL,_2a5,_2a6,_2a7){
aURL=_1e2(aURL).absoluteURL();
_2a8(_29c(aURL),_2a5,aURL.pathComponents(),0,_2a6,_2a7);
};
_1cb.prototype.resolveResourceAtURL=function(aURL,_2a9,_2aa){
_1cb.resolveResourceAtURL(new CFURL(aURL,this.URL()).absoluteURL(),_2a9,_2aa);
};
function _2a8(_2ab,_2ac,_2ad,_2ae,_2af,_2b0){
var _2b1=_2ad.length;
for(;_2ae<_2b1;++_2ae){
var name=_2ad[_2ae],_2b2=_82.call(_2ab._children,name)&&_2ab._children[name];
if(!_2b2){
_2b2=new _1cb(new CFURL(name,_2ab.URL()),_2ab,_2ae+1<_2b1||_2ac,NO,_2b0);
_2b2.resolve();
}
if(!_2b2.isResolved()){
return _2b2.addEventListener("resolve",function(){
_2a8(_2ab,_2ac,_2ad,_2ae,_2af,_2b0);
});
}
if(_2b2.isNotFound()){
return _2af(null,new Error("File not found: "+_2ad.join("/")));
}
if((_2ae+1<_2b1)&&_2b2.isFile()){
return _2af(null,new Error("File is not a directory: "+_2ad.join("/")));
}
_2ab=_2b2;
}
_2af(_2ab);
};
function _2b3(aURL,_2b4,_2b5){
var _2b6=_1cb.includeURLs(),_2b7=new CFURL(aURL,_2b6[_2b4]).absoluteURL();
_1cb.resolveResourceAtURL(_2b7,NO,function(_2b8){
if(!_2b8){
if(_2b4+1<_2b6.length){
_2b3(aURL,_2b4+1,_2b5);
}else{
_2b5(NULL);
}
return;
}
_2b5(_2b8);
});
};
_1cb.resolveResourceAtURLSearchingIncludeURLs=function(aURL,_2b9){
_2b3(aURL,0,_2b9);
};
_1cb.prototype.addEventListener=function(_2ba,_2bb){
this._eventDispatcher.addEventListener(_2ba,_2bb);
};
_1cb.prototype.removeEventListener=function(_2bc,_2bd){
this._eventDispatcher.removeEventListener(_2bc,_2bd);
};
_1cb.prototype.isNotFound=function(){
return this._isNotFound;
};
_1cb.prototype.isFile=function(){
return !this._isDirectory;
};
_1cb.prototype.isDirectory=function(){
return this._isDirectory;
};
_1cb.prototype.toString=function(_2be){
if(this.isNotFound()){
return "<file not found: "+this.name()+">";
}
var _2bf=this.name();
if(this.isDirectory()){
var _2c0=this._children;
for(var name in _2c0){
if(_2c0.hasOwnProperty(name)){
var _2c1=_2c0[name];
if(_2be||!_2c1.isNotFound()){
_2bf+="\n\t"+_2c0[name].toString(_2be).split("\n").join("\n\t");
}
}
}
}
return _2bf;
};
var _2c2=NULL;
_1cb.includeURLs=function(){
if(_2c2!==NULL){
return _2c2;
}
_2c2=[];
if(!_1.OBJJ_INCLUDE_PATHS&&!_1.OBJJ_INCLUDE_URLS){
_2c2=["Frameworks","Frameworks/Debug"];
}else{
_2c2=(_1.OBJJ_INCLUDE_PATHS||[]).concat(_1.OBJJ_INCLUDE_URLS||[]);
}
var _2c3=_2c2.length;
while(_2c3--){
_2c2[_2c3]=new CFURL(_2c2[_2c3]).asDirectoryPathURL();
}
return _2c2;
};
var _2c4="accessors",_2c5="class",_2c6="end",_2c7="function",_2c8="implementation",_2c9="import",_2ca="each",_2cb="outlet",_2cc="action",_2cd="new",_2ce="selector",_2cf="super",_2d0="var",_2d1="in",_2d2="pragma",_2d3="mark",_2d4="=",_2d5="+",_2d6="-",_2d7=":",_2d8=",",_2d9=".",_2da="*",_2db=";",_2dc="<",_2dd="{",_2de="}",_2df=">",_2e0="[",_2e1="\"",_2e2="@",_2e3="#",_2e4="]",_2e5="?",_2e6="(",_2e7=")",_2e8=/^(?:(?:\s+$)|(?:\/(?:\/|\*)))/,_2e9=/^[+-]?\d+(([.]\d+)*([eE][+-]?\d+))?$/,_2ea=/^[a-zA-Z_$](\w|$)*$/;
function _2eb(_2ec){
this._index=-1;
this._tokens=(_2ec+"\n").match(/\/\/.*(\r|\n)?|\/\*(?:.|\n|\r)*?\*\/|\w+\b|[+-]?\d+(([.]\d+)*([eE][+-]?\d+))?|"[^"\\]*(\\[\s\S][^"\\]*)*"|'[^'\\]*(\\[\s\S][^'\\]*)*'|\s+|./g);
this._context=[];
return this;
};
_2eb.prototype.push=function(){
this._context.push(this._index);
};
_2eb.prototype.pop=function(){
this._index=this._context.pop();
};
_2eb.prototype.peek=function(_2ed){
if(_2ed){
this.push();
var _2ee=this.skip_whitespace();
this.pop();
return _2ee;
}
return this._tokens[this._index+1];
};
_2eb.prototype.next=function(){
return this._tokens[++this._index];
};
_2eb.prototype.previous=function(){
return this._tokens[--this._index];
};
_2eb.prototype.last=function(){
if(this._index<0){
return NULL;
}
return this._tokens[this._index-1];
};
_2eb.prototype.skip_whitespace=function(_2ef){
var _2f0;
if(_2ef){
while((_2f0=this.previous())&&_2e8.test(_2f0)){
}
}else{
while((_2f0=this.next())&&_2e8.test(_2f0)){
}
}
return _2f0;
};
_2.Lexer=_2eb;
function _2f1(){
this.atoms=[];
};
_2f1.prototype.toString=function(){
return this.atoms.join("");
};
_2.preprocess=function(_2f2,aURL,_2f3){
return new _2f4(_2f2,aURL,_2f3).executable();
};
_2.eval=function(_2f5){
return eval(_2.preprocess(_2f5).code());
};
var _2f4=function(_2f6,aURL,_2f7){
this._URL=new CFURL(aURL);
_2f6=_2f6.replace(/^#[^\n]+\n/,"\n");
this._currentSelector="";
this._currentClass="";
this._currentSuperClass="";
this._currentSuperMetaClass="";
this._buffer=new _2f1();
this._preprocessed=NULL;
this._dependencies=[];
this._tokens=new _2eb(_2f6);
this._flags=_2f7;
this._classMethod=false;
this._executable=NULL;
this._classLookupTable={};
this._classVars={};
var _2f8=new objj_class();
for(var i in _2f8){
this._classVars[i]=1;
}
this.preprocess(this._tokens,this._buffer);
};
_2f4.prototype.setClassInfo=function(_2f9,_2fa,_2fb){
this._classLookupTable[_2f9]={superClassName:_2fa,ivars:_2fb};
};
_2f4.prototype.getClassInfo=function(_2fc){
return this._classLookupTable[_2fc];
};
_2f4.prototype.allIvarNamesForClassName=function(_2fd){
var _2fe={},_2ff=this.getClassInfo(_2fd);
while(_2ff){
for(var i in _2ff.ivars){
_2fe[i]=1;
}
_2ff=this.getClassInfo(_2ff.superClassName);
}
return _2fe;
};
_2.Preprocessor=_2f4;
_2f4.Flags={};
_2f4.Flags.IncludeDebugSymbols=1<<0;
_2f4.Flags.IncludeTypeSignatures=1<<1;
_2f4.prototype.executable=function(){
if(!this._executable){
this._executable=new _300(this._buffer.toString(),this._dependencies,this._URL);
}
return this._executable;
};
_2f4.prototype.accessors=function(_301){
var _302=_301.skip_whitespace(),_303={};
if(_302!=_2e6){
_301.previous();
return _303;
}
while((_302=_301.skip_whitespace())!=_2e7){
var name=_302,_304=true;
if(!/^\w+$/.test(name)){
throw new SyntaxError(this.error_message("*** @accessors attribute name not valid."));
}
if((_302=_301.skip_whitespace())==_2d4){
_304=_301.skip_whitespace();
if(!/^\w+$/.test(_304)){
throw new SyntaxError(this.error_message("*** @accessors attribute value not valid."));
}
if(name=="setter"){
if((_302=_301.next())!=_2d7){
throw new SyntaxError(this.error_message("*** @accessors setter attribute requires argument with \":\" at end of selector name."));
}
_304+=":";
}
_302=_301.skip_whitespace();
}
_303[name]=_304;
if(_302==_2e7){
break;
}
if(_302!=_2d8){
throw new SyntaxError(this.error_message("*** Expected ',' or ')' in @accessors attribute list."));
}
}
return _303;
};
_2f4.prototype.brackets=function(_305,_306){
var _307=[];
while(this.preprocess(_305,NULL,NULL,NULL,_307[_307.length]=[])){
}
if(_307[0].length===1){
_306.atoms[_306.atoms.length]="[";
_306.atoms[_306.atoms.length]=_307[0][0];
_306.atoms[_306.atoms.length]="]";
}else{
var _308=new _2f1();
if(_307[0][0].atoms[0]==_2cf){
_306.atoms[_306.atoms.length]="objj_msgSendSuper(";
_306.atoms[_306.atoms.length]="{ receiver:self, super_class:"+(this._classMethod?this._currentSuperMetaClass:this._currentSuperClass)+" }";
}else{
_306.atoms[_306.atoms.length]="objj_msgSend(";
_306.atoms[_306.atoms.length]=_307[0][0];
}
_308.atoms[_308.atoms.length]=_307[0][1];
var _309=1,_30a=_307.length,_30b=new _2f1();
for(;_309<_30a;++_309){
var pair=_307[_309];
_308.atoms[_308.atoms.length]=pair[1];
_30b.atoms[_30b.atoms.length]=", "+pair[0];
}
_306.atoms[_306.atoms.length]=", \"";
_306.atoms[_306.atoms.length]=_308;
_306.atoms[_306.atoms.length]="\"";
_306.atoms[_306.atoms.length]=_30b;
_306.atoms[_306.atoms.length]=")";
}
};
_2f4.prototype.directive=function(_30c,_30d,_30e){
var _30f=_30d?_30d:new _2f1(),_310=_30c.next();
if(_310.charAt(0)==_2e1){
_30f.atoms[_30f.atoms.length]=_310;
}else{
if(_310===_2c5){
_30c.skip_whitespace();
return;
}else{
if(_310===_2c8){
this.implementation(_30c,_30f);
}else{
if(_310===_2c9){
this._import(_30c);
}else{
if(_310===_2ce){
this.selector(_30c,_30f);
}
}
}
}
}
if(!_30d){
return _30f;
}
};
_2f4.prototype.hash=function(_311,_312){
var _313=_312?_312:new _2f1(),_314=_311.next();
if(_314===_2d2){
_314=_311.skip_whitespace();
if(_314===_2d3){
while((_314=_311.next()).indexOf("\n")<0){
}
}
}else{
throw new SyntaxError(this.error_message("*** Expected \"pragma\" to follow # but instead saw \""+_314+"\"."));
}
};
_2f4.prototype.implementation=function(_315,_316){
var _317=_316,_318="",_319=NO,_31a=_315.skip_whitespace(),_31b="Nil",_31c=new _2f1(),_31d=new _2f1();
if(!(/^\w/).test(_31a)){
throw new Error(this.error_message("*** Expected class name, found \""+_31a+"\"."));
}
this._currentSuperClass="objj_getClass(\""+_31a+"\").super_class";
this._currentSuperMetaClass="objj_getMetaClass(\""+_31a+"\").super_class";
this._currentClass=_31a;
this._currentSelector="";
if((_318=_315.skip_whitespace())==_2e6){
_318=_315.skip_whitespace();
if(_318==_2e7){
throw new SyntaxError(this.error_message("*** Can't Have Empty Category Name for class \""+_31a+"\"."));
}
if(_315.skip_whitespace()!=_2e7){
throw new SyntaxError(this.error_message("*** Improper Category Definition for class \""+_31a+"\"."));
}
_317.atoms[_317.atoms.length]="{\nvar the_class = objj_getClass(\""+_31a+"\")\n";
_317.atoms[_317.atoms.length]="if(!the_class) throw new SyntaxError(\"*** Could not find definition for class \\\""+_31a+"\\\"\");\n";
_317.atoms[_317.atoms.length]="var meta_class = the_class.isa;";
}else{
if(_318==_2d7){
_318=_315.skip_whitespace();
if(!_2ea.test(_318)){
throw new SyntaxError(this.error_message("*** Expected class name, found \""+_318+"\"."));
}
_31b=_318;
_318=_315.skip_whitespace();
}
_317.atoms[_317.atoms.length]="{var the_class = objj_allocateClassPair("+_31b+", \""+_31a+"\"),\nmeta_class = the_class.isa;";
if(_318==_2dd){
var _31e={},_31f=0,_320=[],_321,_322={},_323=[];
while((_318=_315.skip_whitespace())&&_318!=_2de){
if(_318===_2e2){
_318=_315.next();
if(_318===_2c4){
_321=this.accessors(_315);
}else{
if(_318!==_2cb){
throw new SyntaxError(this.error_message("*** Unexpected '@' token in ivar declaration ('@"+_318+"')."));
}else{
_323.push("@"+_318);
}
}
}else{
if(_318==_2db){
if(_31f++===0){
_317.atoms[_317.atoms.length]="class_addIvars(the_class, [";
}else{
_317.atoms[_317.atoms.length]=", ";
}
var name=_320[_320.length-1];
if(this._flags&_2f4.Flags.IncludeTypeSignatures){
_317.atoms[_317.atoms.length]="new objj_ivar(\""+name+"\", \""+_323.slice(0,_323.length-1).join(" ")+"\")";
}else{
_317.atoms[_317.atoms.length]="new objj_ivar(\""+name+"\")";
}
_31e[name]=1;
_320=[];
_323=[];
if(_321){
_322[name]=_321;
_321=NULL;
}
}else{
_320.push(_318);
_323.push(_318);
}
}
}
if(_320.length){
throw new SyntaxError(this.error_message("*** Expected ';' in ivar declaration, found '}'."));
}
if(_31f){
_317.atoms[_317.atoms.length]="]);\n";
}
if(!_318){
throw new SyntaxError(this.error_message("*** Expected '}'"));
}
this.setClassInfo(_31a,_31b==="Nil"?null:_31b,_31e);
var _31e=this.allIvarNamesForClassName(_31a);
for(ivar_name in _322){
var _324=_322[ivar_name],_325=_324["property"]||ivar_name;
var _326=_324["getter"]||_325,_327="(id)"+_326+"\n{\nreturn "+ivar_name+";\n}";
if(_31c.atoms.length!==0){
_31c.atoms[_31c.atoms.length]=",\n";
}
_31c.atoms[_31c.atoms.length]=this.method(new _2eb(_327),_31e);
if(_324["readonly"]){
continue;
}
var _328=_324["setter"];
if(!_328){
var _329=_325.charAt(0)=="_"?1:0;
_328=(_329?"_":"")+"set"+_325.substr(_329,1).toUpperCase()+_325.substring(_329+1)+":";
}
var _32a="(void)"+_328+"(id)newValue\n{\n";
if(_324["copy"]){
_32a+="if ("+ivar_name+" !== newValue)\n"+ivar_name+" = [newValue copy];\n}";
}else{
_32a+=ivar_name+" = newValue;\n}";
}
if(_31c.atoms.length!==0){
_31c.atoms[_31c.atoms.length]=",\n";
}
_31c.atoms[_31c.atoms.length]=this.method(new _2eb(_32a),_31e);
}
}else{
_315.previous();
}
_317.atoms[_317.atoms.length]="objj_registerClassPair(the_class);\n";
}
if(!_31e){
var _31e=this.allIvarNamesForClassName(_31a);
}
while((_318=_315.skip_whitespace())){
if(_318==_2d5){
this._classMethod=true;
if(_31d.atoms.length!==0){
_31d.atoms[_31d.atoms.length]=", ";
}
_31d.atoms[_31d.atoms.length]=this.method(_315,this._classVars);
}else{
if(_318==_2d6){
this._classMethod=false;
if(_31c.atoms.length!==0){
_31c.atoms[_31c.atoms.length]=", ";
}
_31c.atoms[_31c.atoms.length]=this.method(_315,_31e);
}else{
if(_318==_2e3){
this.hash(_315,_317);
}else{
if(_318==_2e2){
if((_318=_315.next())==_2c6){
break;
}else{
throw new SyntaxError(this.error_message("*** Expected \"@end\", found \"@"+_318+"\"."));
}
}
}
}
}
}
if(_31c.atoms.length!==0){
_317.atoms[_317.atoms.length]="class_addMethods(the_class, [";
_317.atoms[_317.atoms.length]=_31c;
_317.atoms[_317.atoms.length]="]);\n";
}
if(_31d.atoms.length!==0){
_317.atoms[_317.atoms.length]="class_addMethods(meta_class, [";
_317.atoms[_317.atoms.length]=_31d;
_317.atoms[_317.atoms.length]="]);\n";
}
_317.atoms[_317.atoms.length]="}";
this._currentClass="";
};
_2f4.prototype._import=function(_32b){
var _32c="",_32d=_32b.skip_whitespace(),_32e=(_32d!==_2dc);
if(_32d===_2dc){
while((_32d=_32b.next())&&_32d!==_2df){
_32c+=_32d;
}
if(!_32d){
throw new SyntaxError(this.error_message("*** Unterminated import statement."));
}
}else{
if(_32d.charAt(0)===_2e1){
_32c=_32d.substr(1,_32d.length-2);
}else{
throw new SyntaxError(this.error_message("*** Expecting '<' or '\"', found \""+_32d+"\"."));
}
}
this._buffer.atoms[this._buffer.atoms.length]="objj_executeFile(\"";
this._buffer.atoms[this._buffer.atoms.length]=_32c;
this._buffer.atoms[this._buffer.atoms.length]=_32e?"\", YES);":"\", NO);";
this._dependencies.push(new _32f(new CFURL(_32c),_32e));
};
_2f4.prototype.method=function(_330,_331){
var _332=new _2f1(),_333,_334="",_335=[],_336=[null];
_331=_331||{};
while((_333=_330.skip_whitespace())&&_333!==_2dd&&_333!==_2db){
if(_333==_2d7){
var type="";
_334+=_333;
_333=_330.skip_whitespace();
if(_333==_2e6){
while((_333=_330.skip_whitespace())&&_333!=_2e7){
type+=_333;
}
_333=_330.skip_whitespace();
}
_336[_335.length+1]=type||null;
_335[_335.length]=_333;
if(_333 in _331){
CPLog.warn(this.error_message("*** Warning: Method ( "+_334+" ) uses a parameter name that is already in use ( "+_333+" )"));
}
}else{
if(_333==_2e6){
var type="";
while((_333=_330.skip_whitespace())&&_333!=_2e7){
type+=_333;
}
_336[0]=type||null;
}else{
if(_333==_2d8){
if((_333=_330.skip_whitespace())!=_2d9||_330.next()!=_2d9||_330.next()!=_2d9){
throw new SyntaxError(this.error_message("*** Argument list expected after ','."));
}
}else{
_334+=_333;
}
}
}
}
if(_333===_2db){
_333=_330.skip_whitespace();
if(_333!==_2dd){
throw new SyntaxError(this.error_message("Invalid semi-colon in method declaration. "+"Semi-colons are allowed only to terminate the method signature, before the open brace."));
}
}
var _337=0,_338=_335.length;
_332.atoms[_332.atoms.length]="new objj_method(sel_getUid(\"";
_332.atoms[_332.atoms.length]=_334;
_332.atoms[_332.atoms.length]="\"), function";
this._currentSelector=_334;
if(this._flags&_2f4.Flags.IncludeDebugSymbols){
_332.atoms[_332.atoms.length]=" $"+this._currentClass+"__"+_334.replace(/:/g,"_");
}
_332.atoms[_332.atoms.length]="(self, _cmd";
for(;_337<_338;++_337){
_332.atoms[_332.atoms.length]=", ";
_332.atoms[_332.atoms.length]=_335[_337];
}
_332.atoms[_332.atoms.length]=")\n{ with(self)\n{";
_332.atoms[_332.atoms.length]=this.preprocess(_330,NULL,_2de,_2dd);
_332.atoms[_332.atoms.length]="}\n}";
if(this._flags&_2f4.Flags.IncludeDebugSymbols){
_332.atoms[_332.atoms.length]=","+JSON.stringify(_336);
}
_332.atoms[_332.atoms.length]=")";
this._currentSelector="";
return _332;
};
_2f4.prototype.preprocess=function(_339,_33a,_33b,_33c,_33d){
var _33e=_33a?_33a:new _2f1(),_33f=0,_340="";
if(_33d){
_33d[0]=_33e;
var _341=false,_342=[0,0,0];
}
while((_340=_339.next())&&((_340!==_33b)||_33f)){
if(_33d){
if(_340===_2e5){
++_342[2];
}else{
if(_340===_2dd){
++_342[0];
}else{
if(_340===_2de){
--_342[0];
}else{
if(_340===_2e6){
++_342[1];
}else{
if(_340===_2e7){
--_342[1];
}else{
if((_340===_2d7&&_342[2]--===0||(_341=(_340===_2e4)))&&_342[0]===0&&_342[1]===0){
_339.push();
var _343=_341?_339.skip_whitespace(true):_339.previous(),_344=_2e8.test(_343);
if(_344||_2ea.test(_343)&&_2e8.test(_339.previous())){
_339.push();
var last=_339.skip_whitespace(true),_345=true,_346=false;
if(last==="+"||last==="-"){
if(_339.previous()!==last){
_345=false;
}else{
last=_339.skip_whitespace(true);
_346=true;
}
}
_339.pop();
_339.pop();
if(_345&&((!_346&&(last===_2de))||last===_2e7||last===_2e4||last===_2d9||_2e9.test(last)||last.charAt(last.length-1)==="\""||last.charAt(last.length-1)==="'"||_2ea.test(last)&&!/^(new|return|case|var)$/.test(last))){
if(_344){
_33d[1]=":";
}else{
_33d[1]=_343;
if(!_341){
_33d[1]+=":";
}
var _33f=_33e.atoms.length;
while(_33e.atoms[_33f--]!==_343){
}
_33e.atoms.length=_33f;
}
return !_341;
}
if(_341){
return NO;
}
}
_339.pop();
if(_341){
return NO;
}
}
}
}
}
}
}
_342[2]=MAX(_342[2],0);
}
if(_33c){
if(_340===_33c){
++_33f;
}else{
if(_340===_33b){
--_33f;
}
}
}
if(_340===_2c7){
var _347="";
while((_340=_339.next())&&_340!==_2e6&&!(/^\w/).test(_340)){
_347+=_340;
}
if(_340===_2e6){
if(_33c===_2e6){
++_33f;
}
_33e.atoms[_33e.atoms.length]="function"+_347+"(";
if(_33d){
++_342[1];
}
}else{
_33e.atoms[_33e.atoms.length]=_340+" = function";
}
}else{
if(_340==_2e2){
this.directive(_339,_33e);
}else{
if(_340==_2e3){
this.hash(_339,_33e);
}else{
if(_340==_2e0){
this.brackets(_339,_33e);
}else{
_33e.atoms[_33e.atoms.length]=_340;
}
}
}
}
}
if(_33d){
throw new SyntaxError(this.error_message("*** Expected ']' - Unterminated message send or array."));
}
if(!_33a){
return _33e;
}
};
_2f4.prototype.selector=function(_348,_349){
var _34a=_349?_349:new _2f1();
_34a.atoms[_34a.atoms.length]="sel_getUid(\"";
if(_348.skip_whitespace()!=_2e6){
throw new SyntaxError(this.error_message("*** Expected '('"));
}
var _34b=_348.skip_whitespace();
if(_34b==_2e7){
throw new SyntaxError(this.error_message("*** Unexpected ')', can't have empty @selector()"));
}
_349.atoms[_349.atoms.length]=_34b;
var _34c,_34d=true;
while((_34c=_348.next())&&_34c!=_2e7){
if(_34d&&/^\d+$/.test(_34c)||!(/^(\w|$|\:)/.test(_34c))){
if(!(/\S/).test(_34c)){
if(_348.skip_whitespace()==_2e7){
break;
}else{
throw new SyntaxError(this.error_message("*** Unexpected whitespace in @selector()."));
}
}else{
throw new SyntaxError(this.error_message("*** Illegal character '"+_34c+"' in @selector()."));
}
}
_34a.atoms[_34a.atoms.length]=_34c;
_34d=(_34c==_2d7);
}
_34a.atoms[_34a.atoms.length]="\")";
if(!_349){
return _34a;
}
};
_2f4.prototype.error_message=function(_34e){
return _34e+" <Context File: "+this._URL+(this._currentClass?" Class: "+this._currentClass:"")+(this._currentSelector?" Method: "+this._currentSelector:"")+">";
};
if(typeof _2!="undefined"&&!_2.acorn){
_2.acorn={};
_2.acorn.walk={};
}
(function(_34f,walk){
"use strict";
_34f.version="0.3.3-objj-3";
var _350,_351,_352,_353;
_34f.parse=function(inpt,opts){
_351=String(inpt);
_352=_351.length;
_354(opts);
_355();
if(_350.macros){
_356(_350.macros);
}
_357();
return _358(_350.program);
};
var _359=_34f.defaultOptions={ecmaVersion:5,strictSemicolons:false,allowTrailingCommas:true,forbidReserved:false,trackComments:false,trackCommentsIncludeLineBreak:false,trackSpaces:false,locations:false,onComment:null,ranges:false,program:null,sourceFile:null,objj:true,preprocess:true,preprocessAddMacro:_35a,preprocessGetMacro:_35b,preprocessUndefineMacro:_35c,preprocessIsMacro:_35d,macros:null,lineNoInErrorMessage:true};
function _354(opts){
_350=opts||{};
for(var opt in _359){
if(!Object.prototype.hasOwnProperty.call(_350,opt)){
_350[opt]=_359[opt];
}
}
_353=_350.sourceFile||null;
};
var _35e;
var _35f;
var _360=function(name,_361,_362){
return new _363(name,_361,null,_362-name.length);
};
var _364={__OBJJ__:function(){
return _360("__OBJJ__",_350.objj?"1":null,_365);
},__BROWSER__:function(){
return _360("__BROWSER__",typeof (window)!=="undefined"?"1":null,_365);
},171:function(){
return _360("__LINE__",String(_350.locations?_366:_367(_351,_365).line),_365);
},};
function _35a(_368){
_35e[_368.identifier]=_368;
_35f=null;
};
function _35b(_369){
return _35e[_369];
};
function _35c(_36a){
delete _35e[_36a];
_35f=null;
};
function _35d(_36b){
return (_35f||(_35f=_36c(Object.keys(_35e).concat(Object.keys(_364).filter(function(key){
return this[key]().macro!=null;
},_364)).join(" "))))(_36b);
};
function _36d(_36e){
var _36f=_364[_36e];
return _36f?_36f():null;
};
function _356(_370){
for(var i=0,size=_370.length;i<size;i++){
var _371=_351;
var _372=_370[i].trim();
var pos=_372.indexOf("=");
if(pos===0){
_373(0,"Invalid macro definition: '"+_372+"'");
}
var name,body;
if(pos>0){
name=_372.slice(0,pos);
body=_372.slice(pos+1);
}else{
name=_372;
}
if(_364.hasOwnProperty(name)){
_373(0,"'"+name+"' is a predefined macro name");
}
_351=name+(body!=null?" "+body:"");
_352=_351.length;
_357();
_374();
_351=_371;
_352=_351.length;
}
};
var _367=_34f.getLineInfo=function(_375,_376){
for(var line=1,cur=0;;){
_377.lastIndex=cur;
var _378=_377.exec(_375);
if(_378&&_378.index<_376){
++line;
cur=_378.index+_378[0].length;
}else{
break;
}
}
return {line:line,column:_376-cur,lineStart:cur,lineEnd:(_378?_378.index+_378[0].length:_375.length)};
};
_34f.tokenize=function(inpt,opts){
_351=String(inpt);
_352=_351.length;
_354(opts);
_357();
_355();
var t={};
function _379(_37a){
_449(_37a);
t.start=_381;
t.end=_382;
t.startLoc=_386;
t.endLoc=_387;
t.type=_388;
t.value=_389;
return t;
};
_379.jumpTo=function(pos,_37b){
_365=pos;
if(_350.locations){
_366=1;
_37c=_377.lastIndex=0;
var _37d;
while((_37d=_377.exec(_351))&&_37d.index<pos){
++_366;
_37c=_37d.index+_37d[0].length;
}
}
_37e=_37b;
_37f();
};
return _379;
};
var _365;
var _380,_381,_382,_383,_384,_385;
var _386,_387;
var _388,_389;
var _38a,_38b,_38c;
var _38d,_38e,_38f;
var _37e,_390,_391;
var _366,_37c;
var _392,_393,_394;
var _395,_396,_397;
var _398;
var _399,_39a,_39b;
var _39c,_39d,_39e,_39f,_3a0;
var _3a1,_3a2;
var _3a3;
var _3a4;
var _3a5;
var _3a6;
var _3a7;
var _3a8;
var _3a9;
var _3aa;
var _3ab;
var _3ac;
var _3ad;
function _373(pos,_3ae){
if(typeof pos=="number"){
pos=_367(_351,pos);
}
if(_350.lineNoInErrorMessage){
_3ae+=" ("+pos.line+":"+pos.column+")";
}
var _3af=new SyntaxError(_3ae);
_3af.messageOnLine=pos.line;
_3af.messageOnColumn=pos.column;
_3af.lineStart=pos.lineStart;
_3af.lineEnd=pos.lineEnd;
_3af.fileName=_353;
throw _3af;
};
var _3b0=[];
var _3b1={type:"num"},_3b2={type:"regexp"},_3b3={type:"string"};
var _3b4={type:"name"},_3b5={type:"eof"},_3b6={type:"eol"};
var _3b7={keyword:"break"},_3b8={keyword:"case",beforeExpr:true},_3b9={keyword:"catch"};
var _3ba={keyword:"continue"},_3bb={keyword:"debugger"},_3bc={keyword:"default"};
var _3bd={keyword:"do",isLoop:true},_3be={keyword:"else",beforeExpr:true};
var _3bf={keyword:"finally"},_3c0={keyword:"for",isLoop:true},_3c1={keyword:"function"};
var _3c2={keyword:"if"},_3c3={keyword:"return",beforeExpr:true},_3c4={keyword:"switch"};
var _3c5={keyword:"throw",beforeExpr:true},_3c6={keyword:"try"},_3c7={keyword:"var"};
var _3c8={keyword:"while",isLoop:true},_3c9={keyword:"with"},_3ca={keyword:"new",beforeExpr:true};
var _3cb={keyword:"this"};
var _3cc={keyword:"void",prefix:true,beforeExpr:true};
var _3cd={keyword:"null",atomValue:null},_3ce={keyword:"true",atomValue:true};
var _3cf={keyword:"false",atomValue:false};
var _3d0={keyword:"in",binop:7,beforeExpr:true};
var _3d1={keyword:"implementation"},_3d2={keyword:"outlet"},_3d3={keyword:"accessors"};
var _3d4={keyword:"end"},_3d5={keyword:"import"};
var _3d6={keyword:"action"},_3d7={keyword:"selector"},_3d8={keyword:"class"},_3d9={keyword:"global"};
var _3da={keyword:"{"},_3db={keyword:"["};
var _3dc={keyword:"ref"},_3dd={keyword:"deref"};
var _3de={keyword:"protocol"},_3df={keyword:"optional"},_3e0={keyword:"required"};
var _3e1={keyword:"interface"};
var _3e2={keyword:"typedef"};
var _3e3={keyword:"filename"},_3e4={keyword:"unsigned",okAsIdent:true},_3e5={keyword:"signed",okAsIdent:true};
var _3e6={keyword:"byte",okAsIdent:true},_3e7={keyword:"char",okAsIdent:true},_3e8={keyword:"short",okAsIdent:true};
var _3e9={keyword:"int",okAsIdent:true},_3ea={keyword:"long",okAsIdent:true},_3eb={keyword:"id",okAsIdent:true};
var _3ec={keyword:"BOOL",okAsIdent:true},_3ed={keyword:"SEL",okAsIdent:true},_3ee={keyword:"float",okAsIdent:true};
var _3ef={keyword:"double",okAsIdent:true};
var _3f0={keyword:"#"};
var _3f1={keyword:"define"};
var _3f2={keyword:"undef"};
var _3f3={keyword:"ifdef"};
var _3f4={keyword:"ifndef"};
var _3f5={keyword:"if"};
var _3f6={keyword:"else"};
var _3f7={keyword:"endif"};
var _3f8={keyword:"elif"};
var _3f9={keyword:"elif (True)"};
var _3fa={keyword:"elif (false)"};
var _3fb={keyword:"pragma"};
var _3fc={keyword:"defined"};
var _3fd={keyword:"\\"};
var _3fe={keyword:"error"};
var _3ff={keyword:"warning"};
var _400={type:"preprocessParamItem"};
var _401={type:"skipLine"};
var _402={"break":_3b7,"case":_3b8,"catch":_3b9,"continue":_3ba,"debugger":_3bb,"default":_3bc,"do":_3bd,"else":_3be,"finally":_3bf,"for":_3c0,"function":_3c1,"if":_3c2,"return":_3c3,"switch":_3c4,"throw":_3c5,"try":_3c6,"var":_3c7,"while":_3c8,"with":_3c9,"null":_3cd,"true":_3ce,"false":_3cf,"new":_3ca,"in":_3d0,"instanceof":{keyword:"instanceof",binop:7,beforeExpr:true},"this":_3cb,"typeof":{keyword:"typeof",prefix:true,beforeExpr:true},"void":_3cc,"delete":{keyword:"delete",prefix:true,beforeExpr:true}};
var _403={"IBAction":_3d6,"IBOutlet":_3d2,"unsigned":_3e4,"signed":_3e5,"byte":_3e6,"char":_3e7,"short":_3e8,"int":_3e9,"long":_3ea,"id":_3eb,"float":_3ee,"BOOL":_3ec,"SEL":_3ed,"double":_3ef};
var _404={"implementation":_3d1,"outlet":_3d2,"accessors":_3d3,"end":_3d4,"import":_3d5,"action":_3d6,"selector":_3d7,"class":_3d8,"global":_3d9,"ref":_3dc,"deref":_3dd,"protocol":_3de,"optional":_3df,"required":_3e0,"interface":_3e1,"typedef":_3e2};
var _405={"define":_3f1,"pragma":_3fb,"ifdef":_3f3,"ifndef":_3f4,"undef":_3f2,"if":_3f5,"endif":_3f7,"else":_3f6,"elif":_3f8,"defined":_3fc,"warning":_3ff,"error":_3fe};
var _406={type:"[",beforeExpr:true},_407={type:"]"},_408={type:"{",beforeExpr:true};
var _409={type:"}"},_40a={type:"(",beforeExpr:true},_40b={type:")"};
var _40c={type:",",beforeExpr:true},_40d={type:";",beforeExpr:true};
var _40e={type:":",beforeExpr:true},_40f={type:"."},_410={type:"?",beforeExpr:true};
var _411={type:"@"},_412={type:"..."},_413={type:"#"};
var _414={binop:10,beforeExpr:true,preprocess:true},_415={isAssign:true,beforeExpr:true,preprocess:true};
var _416={isAssign:true,beforeExpr:true},_417={binop:9,prefix:true,beforeExpr:true,preprocess:true};
var _418={postfix:true,prefix:true,isUpdate:true},_419={prefix:true,beforeExpr:true,preprocess:true};
var _41a={binop:1,beforeExpr:true,preprocess:true},_41b={binop:2,beforeExpr:true,preprocess:true};
var _41c={binop:3,beforeExpr:true,preprocess:true},_41d={binop:4,beforeExpr:true,preprocess:true};
var _41e={binop:5,beforeExpr:true,preprocess:true},_41f={binop:6,beforeExpr:true,preprocess:true};
var _420={binop:7,beforeExpr:true,preprocess:true},_421={binop:8,beforeExpr:true,preprocess:true};
var _422={binop:10,beforeExpr:true,preprocess:true};
_34f.tokTypes={bracketL:_406,bracketR:_407,braceL:_408,braceR:_409,parenL:_40a,parenR:_40b,comma:_40c,semi:_40d,colon:_40e,dot:_40f,question:_410,slash:_414,eq:_415,name:_3b4,eof:_3b5,num:_3b1,regexp:_3b2,string:_3b3};
for(var kw in _402){
_34f.tokTypes["_"+kw]=_402[kw];
}
function _36c(_423){
_423=_423.split(" ");
var f="",cats=[];
out:
for(var i=0;i<_423.length;++i){
for(var j=0;j<cats.length;++j){
if(cats[j][0].length==_423[i].length){
cats[j].push(_423[i]);
continue out;
}
}
cats.push([_423[i]]);
}
function _424(arr){
if(arr.length==1){
return f+="return str === "+JSON.stringify(arr[0])+";";
}
f+="switch(str){";
for(var i=0;i<arr.length;++i){
f+="case "+JSON.stringify(arr[i])+":";
}
f+="return true}return false;";
};
if(cats.length>3){
cats.sort(function(a,b){
return b.length-a.length;
});
f+="switch(str.length){";
for(var i=0;i<cats.length;++i){
var cat=cats[i];
f+="case "+cat[0].length+":";
_424(cat);
}
f+="}";
}else{
_424(_423);
}
return new Function("str",f);
};
_34f.makePredicate=_36c;
var _425=_36c("abstract boolean byte char class double enum export extends final float goto implements import int interface long native package private protected public short static super synchronized throws transient volatile");
var _426=_36c("class enum extends super const export import");
var _427=_36c("implements interface let package private protected public static yield");
var _428=_36c("eval arguments");
var _429=_36c("break case catch continue debugger default do else finally for function if return switch throw try var while with null true false instanceof typeof void delete new in this");
var _42a=_36c("IBAction IBOutlet byte char short int long float unsigned signed id BOOL SEL double");
var _42b=_36c("define undef pragma if ifdef ifndef else elif endif defined error warning");
var _42c=/[\u1680\u180e\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]/;
var _42d=/[\u1680\u180e\u2000-\u200a\u202f\u205f\u3000]/;
var _42e="ªµºÀ-ÖØ-öø-ˁˆ-ˑˠ-ˤˬˮͰ-ʹͶͷͺ-ͽΆΈ-ΊΌΎ-ΡΣ-ϵϷ-ҁҊ-ԧԱ-Ֆՙա-ևא-תװ-ײؠ-يٮٯٱ-ۓەۥۦۮۯۺ-ۼۿܐܒ-ܯݍ-ޥޱߊ-ߪߴߵߺࠀ-ࠕࠚࠤࠨࡀ-ࡘࢠࢢ-ࢬऄ-हऽॐक़-ॡॱ-ॷॹ-ॿঅ-ঌএঐও-নপ-রলশ-হঽৎড়ঢ়য়-ৡৰৱਅ-ਊਏਐਓ-ਨਪ-ਰਲਲ਼ਵਸ਼ਸਹਖ਼-ੜਫ਼ੲ-ੴઅ-ઍએ-ઑઓ-નપ-રલળવ-હઽૐૠૡଅ-ଌଏଐଓ-ନପ-ରଲଳଵ-ହଽଡ଼ଢ଼ୟ-ୡୱஃஅ-ஊஎ-ஐஒ-கஙசஜஞடணதந-பம-ஹௐఅ-ఌఎ-ఐఒ-నప-ళవ-హఽౘౙౠౡಅ-ಌಎ-ಐಒ-ನಪ-ಳವ-ಹಽೞೠೡೱೲഅ-ഌഎ-ഐഒ-ഺഽൎൠൡൺ-ൿඅ-ඖක-නඳ-රලව-ෆก-ะาำเ-ๆກຂຄງຈຊຍດ-ທນ-ຟມ-ຣລວສຫອ-ະາຳຽເ-ໄໆໜ-ໟༀཀ-ཇཉ-ཬྈ-ྌက-ဪဿၐ-ၕၚ-ၝၡၥၦၮ-ၰၵ-ႁႎႠ-ჅჇჍა-ჺჼ-ቈቊ-ቍቐ-ቖቘቚ-ቝበ-ኈኊ-ኍነ-ኰኲ-ኵኸ-ኾዀዂ-ዅወ-ዖዘ-ጐጒ-ጕጘ-ፚᎀ-ᎏᎠ-Ᏼᐁ-ᙬᙯ-ᙿᚁ-ᚚᚠ-ᛪᛮ-ᛰᜀ-ᜌᜎ-ᜑᜠ-ᜱᝀ-ᝑᝠ-ᝬᝮ-ᝰក-ឳៗៜᠠ-ᡷᢀ-ᢨᢪᢰ-ᣵᤀ-ᤜᥐ-ᥭᥰ-ᥴᦀ-ᦫᧁ-ᧇᨀ-ᨖᨠ-ᩔᪧᬅ-ᬳᭅ-ᭋᮃ-ᮠᮮᮯᮺ-ᯥᰀ-ᰣᱍ-ᱏᱚ-ᱽᳩ-ᳬᳮ-ᳱᳵᳶᴀ-ᶿḀ-ἕἘ-Ἕἠ-ὅὈ-Ὅὐ-ὗὙὛὝὟ-ώᾀ-ᾴᾶ-ᾼιῂ-ῄῆ-ῌῐ-ΐῖ-Ίῠ-Ῥῲ-ῴῶ-ῼⁱⁿₐ-ₜℂℇℊ-ℓℕℙ-ℝℤΩℨK-ℭℯ-ℹℼ-ℿⅅ-ⅉⅎⅠ-ↈⰀ-Ⱞⰰ-ⱞⱠ-ⳤⳫ-ⳮⳲⳳⴀ-ⴥⴧⴭⴰ-ⵧⵯⶀ-ⶖⶠ-ⶦⶨ-ⶮⶰ-ⶶⶸ-ⶾⷀ-ⷆⷈ-ⷎⷐ-ⷖⷘ-ⷞⸯ々-〇〡-〩〱-〵〸-〼ぁ-ゖゝ-ゟァ-ヺー-ヿㄅ-ㄭㄱ-ㆎㆠ-ㆺㇰ-ㇿ㐀-䶵一-鿌ꀀ-ꒌꓐ-ꓽꔀ-ꘌꘐ-ꘟꘪꘫꙀ-ꙮꙿ-ꚗꚠ-ꛯꜗ-ꜟꜢ-ꞈꞋ-ꞎꞐ-ꞓꞠ-Ɦꟸ-ꠁꠃ-ꠅꠇ-ꠊꠌ-ꠢꡀ-ꡳꢂ-ꢳꣲ-ꣷꣻꤊ-ꤥꤰ-ꥆꥠ-ꥼꦄ-ꦲꧏꨀ-ꨨꩀ-ꩂꩄ-ꩋꩠ-ꩶꩺꪀ-ꪯꪱꪵꪶꪹ-ꪽꫀꫂꫛ-ꫝꫠ-ꫪꫲ-ꫴꬁ-ꬆꬉ-ꬎꬑ-ꬖꬠ-ꬦꬨ-ꬮꯀ-ꯢ가-힣ힰ-ퟆퟋ-ퟻ豈-舘並-龎ﬀ-ﬆﬓ-ﬗיִײַ-ﬨשׁ-זּטּ-לּמּנּסּףּפּצּ-ﮱﯓ-ﴽﵐ-ﶏﶒ-ﷇﷰ-ﷻﹰ-ﹴﹶ-ﻼＡ-Ｚａ-ｚｦ-ﾾￂ-ￇￊ-ￏￒ-ￗￚ-ￜ";
var _42f="̀-ͯ҃-֑҇-ׇֽֿׁׂׅׄؐ-ؚؠ-ىٲ-ۓۧ-ۨۻ-ۼܰ-݊ࠀ-ࠔࠛ-ࠣࠥ-ࠧࠩ-࠭ࡀ-ࡗࣤ-ࣾऀ-ःऺ-़ा-ॏ॑-ॗॢ-ॣ०-९ঁ-ঃ়া-ৄেৈৗয়-ৠਁ-ਃ਼ਾ-ੂੇੈੋ-੍ੑ੦-ੱੵઁ-ઃ઼ા-ૅે-ૉો-્ૢ-ૣ૦-૯ଁ-ଃ଼ା-ୄେୈୋ-୍ୖୗୟ-ୠ୦-୯ஂா-ூெ-ைொ-்ௗ௦-௯ఁ-ఃె-ైొ-్ౕౖౢ-ౣ౦-౯ಂಃ಼ಾ-ೄೆ-ೈೊ-್ೕೖೢ-ೣ೦-೯ംഃെ-ൈൗൢ-ൣ൦-൯ංඃ්ා-ුූෘ-ෟෲෳิ-ฺเ-ๅ๐-๙ິ-ູ່-ໍ໐-໙༘༙༠-༩༹༵༷ཁ-ཇཱ-྄྆-྇ྍ-ྗྙ-ྼ࿆က-ဩ၀-၉ၧ-ၭၱ-ၴႂ-ႍႏ-ႝ፝-፟ᜎ-ᜐᜠ-ᜰᝀ-ᝐᝲᝳក-ឲ៝០-៩᠋-᠍᠐-᠙ᤠ-ᤫᤰ-᤻ᥑ-ᥭᦰ-ᧀᧈ-ᧉ᧐-᧙ᨀ-ᨕᨠ-ᩓ᩠-᩿᩼-᪉᪐-᪙ᭆ-ᭋ᭐-᭙᭫-᭳᮰-᮹᯦-᯳ᰀ-ᰢ᱀-᱉ᱛ-ᱽ᳐-᳒ᴀ-ᶾḁ-ἕ‌‍‿⁀⁔⃐-⃥⃜⃡-⃰ⶁ-ⶖⷠ-ⷿ〡-〨゙゚Ꙁ-ꙭꙴ-꙽ꚟ꛰-꛱ꟸ-ꠀ꠆ꠋꠣ-ꠧꢀ-ꢁꢴ-꣄꣐-꣙ꣳ-ꣷ꤀-꤉ꤦ-꤭ꤰ-ꥅꦀ-ꦃ꦳-꧀ꨀ-ꨧꩀ-ꩁꩌ-ꩍ꩐-꩙ꩻꫠ-ꫩꫲ-ꫳꯀ-ꯡ꯬꯭꯰-꯹ﬠ-ﬨ︀-️︠-︦︳︴﹍-﹏０-９＿";
var _430=new RegExp("["+_42e+"]");
var _431=new RegExp("["+_42e+_42f+"]");
var _432=/[\n\r\u2028\u2029]/;
var _377=/\r\n|[\n\r\u2028\u2029]/g;
var _433=_34f.isIdentifierStart=function(code){
if(code<65){
return code===36;
}
if(code<91){
return true;
}
if(code<97){
return code===95;
}
if(code<123){
return true;
}
return code>=170&&_430.test(String.fromCharCode(code));
};
var _434=_34f.isIdentifierChar=function(code){
if(code<48){
return code===36;
}
if(code<58){
return true;
}
if(code<65){
return false;
}
if(code<91){
return true;
}
if(code<97){
return code===95;
}
if(code<123){
return true;
}
return code>=170&&_431.test(String.fromCharCode(code));
};
function _435(){
this.line=_366;
this.column=_365-_37c;
if(_3a4){
var _436=_3a4.macro;
var _437=_436.locationOffset;
if(_437){
var _438=_437.line;
if(_438){
this.line+=_438;
}
var _439=_437.column;
if(_439){
this.column+=_384-(_366===0?_439:0);
}
}
}
};
function _43a(line,_43b){
this.line=line;
this.column=_43b;
if(_3a4){
var _43c=_3a4.macro;
var _43d=_43c.locationOffset;
if(_43d){
var _43e=_43d.line;
if(_43e){
this.line+=_43e;
}
var _43f=_43d.column;
if(_43f){
this.column+=_43f;
}
}
}
};
function _357(){
_366=1;
_365=_37c=_385=_383=_384=0;
_37e=true;
_390=null;
_391=null;
_37f();
};
function _355(){
_35e=Object.create(null);
_35f=null;
_3a8=null;
_3a9=null;
_3a6=false;
_3a7=false;
_3a3=[];
_3a4=null;
_3a5=null;
_3ac=true;
_3ab=false;
_3ad=[];
};
function _440(type,val,_441){
if(_441){
_382=_441;
if(_350.locations){
_387=preprocessOverrideTokLoc;
}
}else{
_382=_365;
if(_350.locations){
_387=new _435;
}
}
_388=type;
_37f();
if(_350.preprocess&&_351.charCodeAt(_365)===35&&_351.charCodeAt(_365+1)===35){
var val1=val!=null?val:type.keyword||type.type;
_365+=2;
if(val1!=null){
var _442=_350.locations&&new _43a(_366,_37c);
var _443=_392,_444=_382,_445=_381,_446=_381+_383,_447=_3a4&&_3a4.macro&&_3a4.macro.variadicName;
_37f();
if(_447&&_447===_351.slice(_365,_365+_447.length)){
var _448=true;
}
_3ab=true;
_449(null,2);
_3ab=false;
var val2=_389!=null?_389:_388.keyword||_388.type;
if(val2!=null){
if(_448&&val1===","&&val2===""){
return _449();
}
var _44a=""+val1+val2,_44b=_381+_384;
var _44c=new _363(null,_44a,null,_446,false,null,false,_442);
var r=_44d(_44c,_384,_3a4?_3a4.parameterDict:null,null,_365,next,null);
if(_3a4&&_3a4.macro===_44c){
_388=type;
_381=_445;
_382=_444;
_392=_443;
_384=_44b-val1.length;
if(!_448){
console.log("Warning: pasting formed '"+_44a+"', an invalid preprocessing token");
}
}else{
return r;
}
}
}
}
_389=val;
_38c=_38b;
_38f=_38e;
_38b=_390;
_38e=_391;
_37e=type.beforeExpr;
};
function _44e(_44f,_450){
var _451=_350.onComment&&_350.locations&&new _435;
var _452=_365,end=_351.indexOf("*/",_365+=2);
if(end===-1){
_373(_365-2,"Unterminated comment");
}
_365=end+2;
if(_350.locations){
_377.lastIndex=_452;
var _453;
while((_453=_377.exec(_351))&&_453.index<_365){
++_366;
_37c=_453.index+_453[0].length;
}
}
if(!_450){
if(_350.onComment){
_350.onComment(true,_351.slice(_452+2,end),_452,_365,_451,_350.locations&&new _435);
}
if(_350.trackComments){
(_390||(_390=[])).push(_351.slice(_44f!=null&&_350.trackCommentsIncludeLineBreak?_44f:_452,_365));
}
}
};
function _454(_455,_456){
var _457=_365;
var _458=_350.onComment&&_350.locations&&new _435;
var ch=_351.charCodeAt(_365+=2);
while(_365<_352&&ch!==10&&ch!==13&&ch!==8232&&ch!==8233){
++_365;
ch=_351.charCodeAt(_365);
}
if(!_456){
if(_350.onComment){
_350.onComment(false,_351.slice(_457+2,_365),_457,_365,_458,_350.locations&&new _435);
}
if(_350.trackComments){
(_390||(_390=[])).push(_351.slice(_455!=null&&_350.trackCommentsIncludeLineBreak?_455:_457,_365));
}
}
};
function _459(){
var ch=_351.charCodeAt(_365);
var last;
while(_365<_352&&((ch!==10&&ch!==13&&ch!==8232&&ch!==8233)||last===92)){
if(ch!=32&&ch!=9&&ch!=160&&(ch<5760||!_42d.test(String.fromCharCode(ch)))){
last=ch;
}
ch=_351.charCodeAt(++_365);
}
if(_350.locations){
++_366;
_37c=_365;
}
};
function _37f(){
_390=null;
_391=null;
_45a();
};
function _45a(_45b,_45c,_45d){
var _45e=_365,_45f;
for(;;){
var ch=_351.charCodeAt(_365);
if(ch===32){
++_365;
}else{
if(ch===13&&!_45b){
_45f=_365;
++_365;
var next=_351.charCodeAt(_365);
if(next===10){
++_365;
}
if(_350.locations){
++_366;
_37c=_365;
}
}else{
if(ch===10&&!_45b){
_45f=_365;
++_365;
if(_350.locations){
++_366;
_37c=_365;
}
}else{
if(ch===9){
++_365;
}else{
if(ch===47&&!_45d){
var next=_351.charCodeAt(_365+1);
if(next===42){
if(_350.trackSpaces){
(_391||(_391=[])).push(_351.slice(_45e,_365));
}
_44e(_45f);
_45e=_365;
}else{
if(next===47){
if(_350.trackSpaces){
(_391||(_391=[])).push(_351.slice(_45e,_365));
}
_454(_45f);
_45e=_365;
}else{
break;
}
}
}else{
if(ch===160||ch===11||ch===12||(ch>=5760&&_42c.test(String.fromCharCode(ch)))){
++_365;
}else{
if(_365>=_352){
if(_350.preprocess){
if(_45c){
return true;
}
if(!_3a3.length){
break;
}
var _460=_3a3.pop();
_365=_460.end;
_351=_460.input;
_352=_460.inputLen;
_366=_460.currentLine;
_37c=_460.currentLineStart;
_3a5=_460.onlyTransformArgumentsForLastToken;
_3a8=_460.parameterScope;
_384=_460.macroOffset;
var _461=_3a3.length;
_3a4=_461?_3a3[_461-1]:null;
_45a(_45b);
}else{
break;
}
}else{
if(ch===92&&_350.preprocess){
var pos=_365+1;
ch=_351.charCodeAt(pos);
while(pos<_352&&(ch===32||ch===9||ch===11||ch===12||(ch>=5760&&_42d.test(String.fromCharCode(ch))))){
ch=_351.charCodeAt(++pos);
}
_377.lastIndex=0;
var _462=_377.exec(_351.slice(pos,pos+2));
if(_462&&_462.index===0){
_365=pos+_462[0].length;
if(_350.locations){
++_366;
_37c=_365;
}
}else{
break;
}
}else{
break;
}
}
}
}
}
}
}
}
}
};
function _463(code,_464){
var next=_351.charCodeAt(_365+1);
if(next>=48&&next<=57){
return _465(String.fromCharCode(code),_464);
}
if(next===46&&_350.objj&&_351.charCodeAt(_365+2)===46){
_365+=3;
return _464(_412);
}
++_365;
return _464(_40f);
};
function _466(_467){
var next=_351.charCodeAt(_365+1);
if(_37e){
++_365;
return _468();
}
if(next===61){
return _469(_416,2,_467);
}
return _469(_414,1,_467);
};
function _46a(_46b){
var next=_351.charCodeAt(_365+1);
if(next===61){
return _469(_416,2,_46b);
}
return _469(_422,1,_46b);
};
function _46c(code,_46d){
var next=_351.charCodeAt(_365+1);
if(next===code){
return _469(code===124?_41a:_41b,2,_46d);
}
if(next===61){
return _469(_416,2,_46d);
}
return _469(code===124?_41c:_41e,1,_46d);
};
function _46e(_46f){
var next=_351.charCodeAt(_365+1);
if(next===61){
return _469(_416,2,_46f);
}
return _469(_41d,1,_46f);
};
function _470(code,_471){
var next=_351.charCodeAt(_365+1);
if(next===code){
return _469(_418,2,_471);
}
if(next===61){
return _469(_416,2,_471);
}
return _469(_417,1,_471);
};
function _472(code,_473){
if(_388===_3d5&&_350.objj&&code===60){
for(var _474=_365+1;;){
var ch=_351.charCodeAt(++_365);
if(ch===62){
return _473(_3e3,_351.slice(_474,_365++));
}
if(_365>=_352||ch===13||ch===10||ch===8232||ch===8233){
_373(_381,"Unterminated import statement");
}
}
}
var next=_351.charCodeAt(_365+1);
var size=1;
if(next===code){
size=code===62&&_351.charCodeAt(_365+2)===62?3:2;
if(_351.charCodeAt(_365+size)===61){
return _469(_416,size+1,_473);
}
return _469(_421,size,_473);
}
if(next===61){
size=_351.charCodeAt(_365+2)===61?3:2;
}
return _469(_420,size,_473);
};
function _475(code,_476){
var next=_351.charCodeAt(_365+1);
if(next===61){
return _469(_41f,_351.charCodeAt(_365+2)===61?3:2,_476);
}
return _469(code===61?_415:_419,1,_476);
};
function _477(code,_478){
var next=_351.charCodeAt(++_365);
if(next===34||next===39){
return _479(next,_478);
}
if(next===123){
return _478(_3da);
}
if(next===91){
return _478(_3db);
}
var word=_47a(),_47b=_404[word];
if(!_47b){
_373(_381,"Unrecognized Objective-J keyword '@"+word+"'");
}
return _478(_47b);
};
function _47c(_47d){
++_365;
_47e();
_47f(false,true);
switch(_39d){
case _3f1:
if(_3ac){
_374();
}else{
return _47d(_3f1);
}
break;
case _3f2:
_47f();
_350.preprocessUndefineMacro(_480());
break;
case _3f5:
if(_3ac){
var _481=_37e;
_37e=false;
_3ad.push(_3f5);
_47f(false,false,true);
var expr=_482(true);
var test=_483(expr);
if(!test){
_3ac=false;
_484();
}
_37e=_481;
}else{
return _47d(_3f5);
}
break;
case _3f3:
if(_3ac){
_3ad.push(_3f5);
_47f();
var _485=_480();
var test=_350.preprocessIsMacro(_485);
if(!test){
_3ac=false;
_484();
}
}else{
return _47d(_3f3);
}
break;
case _3f4:
if(_3ac){
_3ad.push(_3f5);
_47f();
var _485=_480();
var test=_350.preprocessIsMacro(_485);
if(test){
_3ac=false;
_484();
}
}else{
return _47d(_3f4);
}
break;
case _3f6:
if(_3ad.length){
if(_3ac){
if(_3ad[_3ad.length-1]===_3f5){
_3ad[_3ad.length-1]=_3f6;
_3ac=false;
_47d(_3f6);
_47f();
_484(true);
}else{
_373(_39f,"#else after #else");
}
}else{
_3ad[_3ad.length-1]=_3f6;
return _47d(_3f6);
}
}else{
_373(_39f,"#else without #if");
}
break;
case _3f8:
if(_3ad.length){
if(_3ac){
if(_3ad[_3ad.length-1]===_3f5){
_3ac=false;
_47d(_3f8);
_47f();
_484(true);
}else{
_373(_39f,"#elsif after #else");
}
}else{
var _481=_37e;
_37e=false;
_3ac=true;
_47f(false,false,true);
var expr=_482(true);
_3ac=false;
_37e=_481;
var test=_483(expr);
return _47d(test?_3f9:_3fa);
}
}else{
_373(_39f,"#elif without #if");
}
break;
case _3f7:
if(_3ad.length){
if(_3ac){
_3ad.pop();
break;
}
}else{
_373(_39f,"#endif without #if");
}
return _47d(_3f7);
break;
case _3fb:
_459();
break;
case _419:
_459();
break;
case _3ff:
_47f(false,false,true);
var expr=_482();
console.log("Warning: "+String(_483(expr)));
break;
case _3fe:
var _486=_39f;
_47f(false,false,true);
var expr=_482();
_373(_486,"Error: "+String(_483(expr)));
break;
default:
if(_3a4){
if(_3a4.parameterDict&&_3a4.macro.isParameterFunction()(_39e)){
var _487=_3a4.parameterDict[_39e];
if(_487){
return _440(_3b3,_487.macro);
}
}
}
_373(_39f,"Invalid preprocessing directive");
_459();
return _47d(_3f0);
}
if(_39d===_3b6&&_350.trackSpaces){
if(_391&&_391.length){
_391.push("\n"+_391.pop());
}else{
_391=["\n"];
}
}
_488(_3f0,null,null,true);
return _449();
};
function _374(){
_3a7=true;
_47f();
var _489=_3a0;
var _48a=_480();
if(_351.charCodeAt(_489)===40){
_48b(_40a);
var _48c=[];
var _48d=false;
var _48e=true;
while(!_48f(_40b)){
if(_48d){
_373(_39f,"Variadic parameter must be last");
}
if(!_48e){
_48b(_40c,"Expected ',' between macro parameters");
}else{
_48e=false;
}
_48c.push(_48f(_412)?_48d=true&&"__VA_ARGS__":_480());
if(_48f(_412)){
_48d=true;
}
}
}
var _490=_39f;
var _491=_350.locations&&new _43a(_366,_37c);
while(_39d!==_3b6&&_39d!==_3b5){
_47f();
}
var _492=_351.slice(_490,_39f);
_492=_492.replace(/\\/g," ");
_350.preprocessAddMacro(new _363(_48a,_492,_48c,_490,false,null,_48d&&_48c[_48c.length-1],_491));
_3a7=false;
};
function _483(expr){
return walk.recursive(expr,{},{LogicalExpression:function(node,st,c){
var left=node.left,_493=node.right;
switch(node.operator){
case "||":
return c(left,st)||c(_493,st);
case "&&":
return c(left,st)&&c(_493,st);
}
},BinaryExpression:function(node,st,c){
var left=node.left,_494=node.right;
switch(node.operator){
case "+":
return c(left,st)+c(_494,st);
case "-":
return c(left,st)-c(_494,st);
case "*":
return c(left,st)*c(_494,st);
case "/":
return c(left,st)/c(_494,st);
case "%":
return c(left,st)%c(_494,st);
case "<":
return c(left,st)<c(_494,st);
case ">":
return c(left,st)>c(_494,st);
case "^":
return c(left,st)^c(_494,st);
case "&":
return c(left,st)&c(_494,st);
case "|":
return c(left,st)|c(_494,st);
case "==":
return c(left,st)==c(_494,st);
case "===":
return c(left,st)===c(_494,st);
case "!=":
return c(left,st)!=c(_494,st);
case "!==":
return c(left,st)!==c(_494,st);
case "<=":
return c(left,st)<=c(_494,st);
case ">=":
return c(left,st)>=c(_494,st);
case ">>":
return c(left,st)>>c(_494,st);
case ">>>":
return c(left,st)>>>c(_494,st);
case "<<":
return c(left,st)<<c(_494,st);
}
},UnaryExpression:function(node,st,c){
var arg=node.argument;
switch(node.operator){
case "-":
return -c(arg,st);
case "+":
return +c(arg,st);
case "!":
return !c(arg,st);
case "~":
return ~c(arg,st);
}
},Literal:function(node,st,c){
return node.value;
},Identifier:function(node,st,c){
return 0;
},DefinedExpression:function(node,st,c){
var _495=node.object;
if(_495.type==="Identifier"){
var name=_495.name,_496=_350.preprocessGetMacro(name)||_36d(name);
return _496||0;
}else{
return c(_495,st);
}
}},{});
};
function _497(code,_498,_499){
switch(code){
case 46:
return _463(code,_498);
case 40:
++_365;
return _498(_40a);
case 41:
++_365;
return _498(_40b);
case 59:
++_365;
return _498(_40d);
case 44:
++_365;
return _498(_40c);
case 91:
++_365;
return _498(_406);
case 93:
++_365;
return _498(_407);
case 123:
++_365;
return _498(_408);
case 125:
++_365;
return _498(_409);
case 58:
++_365;
return _498(_40e);
case 63:
++_365;
return _498(_410);
case 48:
var next=_351.charCodeAt(_365+1);
if(next===120||next===88){
return _49a(_498);
}
case 49:
case 50:
case 51:
case 52:
case 53:
case 54:
case 55:
case 56:
case 57:
return _465(false,_498);
case 34:
case 39:
return _479(code,_498);
case 47:
return _466(_498);
case 37:
case 42:
return _46a(_498);
case 124:
case 38:
return _46c(code,_498);
case 94:
return _46e(_498);
case 43:
case 45:
return _470(code,_498);
case 60:
case 62:
return _472(code,_498);
case 61:
case 33:
return _475(code,_498);
case 126:
return _469(_419,1,_498);
case 64:
if(_350.objj){
return _477(code,_498);
}
return false;
case 35:
if(_350.preprocess){
if(_3a7){
++_365;
return _498(_3f0);
}
_377.lastIndex=0;
var _49b=_377.exec(_351.slice(_396,_365));
if(_396!==0&&_396!==_365&&!_49b){
if(_3a4){
return _49c();
}else{
_373(_365,"Preprocessor directives may only be used at the beginning of a line");
}
}
return _47c(_498);
}
return false;
case 92:
if(_350.preprocess){
return _469(_3fd,1,_498);
}
return false;
}
if(_499){
var r;
if(code===13){
r=_469(_3b6,_351.charCodeAt(_365+1)===10?2:1,_498);
}else{
if(code===10||code===8232||code===8233){
r=_469(_3b6,1,_498);
}else{
return false;
}
}
if(_350.locations){
++_366;
_37c=_365;
}
return r;
}
return false;
};
function _49c(){
var _49d=_3a3.length,_49e=_3a4;
_365++;
_3ab=true;
next(false,2);
_3ab=false;
var _49f=_381+_383;
var _4a0=_350.locations&&new _43a(_366,_37c);
var _4a1;
if(_388===_3b3){
var _4a2=_392.slice(_381,_381+1);
var _4a3=_4a2==="\""?"\\\"":"'";
_4a1=_4a3;
_4a1+=_4a4(_389);
_4a1+=_4a3;
}else{
_4a1=_389!=null?_389:_388.keyword||_388.type;
}
while(_3a3.length>_49d&&_49e===_3a3[_49d-1]){
_3ab=true;
next(false,2);
_3ab=false;
if(_396!==_381){
_4a1+=" ";
}
if(_388===_3b3){
var _4a2=_392.slice(_381,_381+1);
var _4a3=_4a2==="\""?"\\\"":"'";
_4a1+=_4a3;
_4a1+=_4a4(_389);
_4a1+=_4a3;
}else{
_4a1+=_389!=null?_389:_388.keyword||_388.type;
}
}
var _4a5=new _363(null,"\""+_4a1+"\"",null,_49f,false,null,false,_4a0);
return _44d(_4a5,_384,null,null,_365,next);
};
function _4a4(_4a6){
for(var _4a7="",pos=0,size=_4a6.length,ch=_4a6.charCodeAt(pos);pos<size;ch=_4a6.charCodeAt(++pos)){
switch(ch){
case 34:
_4a7+="\\\\\\\"";
break;
case 10:
_4a7+="\\\\n";
break;
case 13:
_4a7+="\\\\r";
break;
case 9:
_4a7+="\\\\t";
break;
case 8:
_4a7+="\\\\b";
break;
case 11:
_4a7+="\\\\v";
break;
case 160:
_4a7+="\\\\u00A0";
break;
case 8232:
_4a7+="\\\\u2028";
break;
case 8233:
_4a7+="\\\\u2029";
break;
case 92:
_4a7+="\\\\";
break;
default:
_4a7+=_4a6.charAt(pos);
break;
}
}
return _4a7;
};
function _47e(_4a8,_4a9){
_45a(!_4a9);
_377.lastIndex=0;
var _4aa=_377.exec(_351.slice(_365,_365+2));
return _4aa&&_4aa.index===0;
};
function _484(_4ab){
var _4ac=[];
while(_4ac.length>0||(_39d!==_3f7&&((_39d!==_3f6&&_39d!==_3f9)||_4ab))){
switch(_39d){
case _3f5:
case _3f3:
case _3f4:
_4ac.push(_3f5);
break;
case _3f6:
if(_4ac[_4ac.length-1]!==_3f5){
_373(_39f,"#else after #else");
}else{
_4ac[_4ac.length-1]=_3f6;
}
break;
case _3f8:
if(_4ac[_4ac.length-1]!==_3f5){
_373(_39f,"#elif after #else");
}
break;
case _3f7:
_4ac.pop();
break;
case _3b5:
_3ac=true;
_373(_39f,"Missing #endif");
}
_47f(true);
}
_3ac=true;
if(_39d===_3f7){
_3ad.pop();
}
};
function _47f(_4ad,_4ae,_4af){
_39f=_365;
_393=_351;
_3a9=_3a8;
if(_365>=_352){
return _488(_3b5);
}
var code=_351.charCodeAt(_365);
if(!_4ae&&!_3ac&&code!==35){
_459();
return _488(_401,_351.slice(_39f,_365++));
}else{
if(_3a6&&code!==41&&code!==44){
var _4b0=0;
while(_365<_352&&(_4b0||(code!==41&&code!==44))){
if(code===40){
_4b0++;
}
if(code===41){
_4b0--;
}
if(code===34||code===39){
var _4b1=code;
code=_351.charCodeAt(++_365);
while(_365<_352&&code!==_4b1){
if(code===92){
code=_351.charCodeAt(++_365);
if(code!==_4b1){
continue;
}
}
code=_351.charCodeAt(++_365);
}
}
code=_351.charCodeAt(++_365);
}
return _488(_400,_351.slice(_39f,_365));
}
}
if(_433(code)||(code===92&&_351.charCodeAt(_365+1)===117)){
return _4b2(_4af);
}
if(_497(code,_4ad?_4b3:_488,true)===false){
var ch=String.fromCharCode(code);
if(ch==="\\"||_430.test(ch)){
return _4b2(_4af);
}
_373(_365,"Unexpected character '"+ch+"'");
}
};
function _4b2(_4b4){
var word=_47a();
var type=_3b4;
if(_4b4&&_350.preprocess){
var _4b5=_4b6(word,_4b7);
if(_4b5===true){
return true;
}
}
if(!_4b8&&_42b(word)){
type=_405[word];
}
_488(type,word,_4b5);
};
function _488(type,val,_4b9,_4ba){
_39d=type;
_39e=val;
_3a0=_4b9||_365;
_47e(false,_4ba);
};
function _4b3(type,val){
_39d=type;
_39e=val;
_3a0=_365;
_47e(true);
};
function _4b7(_4bb,_4bc,_4bd,_4be){
if(!_4bb){
_3a1=_381;
_3a2=_382;
}
return _47f(false,false,_4be);
};
function _48f(type,_4bf){
if(_39d===type){
_4b7(false,false,null,_4bf);
return true;
}
};
function _48b(type,_4c0,_4c1){
if(_39d===type){
_47f(_4c1);
}else{
_373(_39f,_4c0||"Unexpected token");
}
};
function _4c2(){
};
function _480(_4c3){
var _4c4=_39d===_3b4?_39e:((!_350.forbidReserved||_39d.okAsIdent)&&_39d.keyword)||_4c2();
_4b7(false,false,null,_4c3);
return _4c4;
};
function _4c5(_4c6){
var node=_4c7();
node.name=_480(_4c6);
return _4c8(node,"Identifier");
};
function _482(_4c9){
return _4ca(_4c9);
};
function _4ca(_4cb){
return _4cc(_4cd(_4cb),-1,_4cb);
};
function _4cc(left,_4ce,_4cf){
var prec=_39d.binop;
if(prec){
if(!_39d.preprocess){
_373(_39f,"Unsupported macro operator");
}
if(prec>_4ce){
var node=_4d0(left);
node.left=left;
node.operator=_39e;
_4b7(false,false,null,_4cf);
node.right=_4cc(_4cd(_4cf),prec,_4cf);
var node=_4c8(node,/&&|\|\|/.test(node.operator)?"LogicalExpression":"BinaryExpression");
return _4cc(node,_4ce,_4cf);
}
}
return left;
};
function _4cd(_4d1){
if(_39d.preprocess&&_39d.prefix){
var node=_4c7();
node.operator=_39e;
node.prefix=true;
_4b7(false,false,null,_4d1);
node.argument=_4cd(_4d1);
return _4c8(node,"UnaryExpression");
}
return _4d2(_4d1);
};
function _4d2(_4d3){
switch(_39d){
case _3b4:
return _4c5(_4d3);
case _3b1:
case _3b3:
return _4d4(_4d3);
case _40a:
var _4d5=_39f;
_4b7(false,false,null,_4d3);
var val=_482(_4d3);
val.start=_4d5;
val.end=_3a0;
_48b(_40b,"Expected closing ')' in macro expression",_4d3);
return val;
case _3fc:
var node=_4c7();
_4b7(false,false,null,_4d3);
node.object=_4d6(_4d3);
return _4c8(node,"DefinedExpression");
default:
_4d7();
}
};
function _4d6(_4d8){
switch(_39d){
case _3b4:
return _4c5(_4d8);
case _3b1:
case _3b3:
return _4d4(_4d8);
case _40a:
var _4d9=_39f;
_4b7(false,false,null,_4d8);
var val=_4d6(_4d8);
val.start=_4d9;
val.end=_3a0;
_48b(_40b,"Expected closing ')' in macro expression",_4d8);
return val;
default:
_4d7();
}
};
function _4d4(_4da){
var node=_4c7();
node.value=_39e;
node.raw=_393.slice(_39f,_3a0);
_4b7(false,false,null,_4da);
return _4c8(node,"Literal");
};
function _4c8(node,type){
node.type=type;
node.end=_3a2;
return node;
};
function _449(_4db,_4dc,_4dd){
_38a=_390;
_38d=_391;
if(!_4db){
_381=_365;
}else{
_365=_381+1;
}
if(!_4dd){
_380=_381;
_394=_351;
}
_392=_351;
_383=_384;
_3a9=_3a8;
if(_350.locations){
_386=new _435;
}
if(_4db){
return _468();
}
if(_365>=_352){
return _440(_3b5);
}
var code=_351.charCodeAt(_365);
if(_433(code)||code===92){
return _4de(null,_4dc,_4db);
}
var tok=_497(code,_440);
if(tok===false){
var ch=String.fromCharCode(code);
if(ch==="\\"||_430.test(ch)){
return _4de(null,_4dc,_4db);
}
_373(_365,"Unexpected character '"+ch+"'");
}
return tok;
};
function _469(type,size,_4df){
var str=_351.slice(_365,_365+size);
_365+=size;
_4df(type,str);
};
function _468(){
var _4e0="",_4e1,_4e2,_4e3=_365;
for(;;){
if(_365>=_352){
_373(_4e3,"Unterminated regular expression");
}
var ch=_351.charAt(_365);
if(_432.test(ch)){
_373(_4e3,"Unterminated regular expression");
}
if(!_4e1){
if(ch==="["){
_4e2=true;
}else{
if(ch==="]"&&_4e2){
_4e2=false;
}else{
if(ch==="/"&&!_4e2){
break;
}
}
}
_4e1=ch==="\\";
}else{
_4e1=false;
}
++_365;
}
var _4e0=_351.slice(_4e3,_365);
++_365;
var mods=_47a();
if(mods&&!/^[gmsiy]*$/.test(mods)){
_373(_4e3,"Invalid regexp flag");
}
return _440(_3b2,new RegExp(_4e0,mods));
};
function _4e4(_4e5,len){
var _4e6=_365,_4e7=0;
for(var i=0,e=len==null?Infinity:len;i<e;++i){
var code=_351.charCodeAt(_365),val;
if(code>=97){
val=code-97+10;
}else{
if(code>=65){
val=code-65+10;
}else{
if(code>=48&&code<=57){
val=code-48;
}else{
val=Infinity;
}
}
}
if(val>=_4e5){
break;
}
++_365;
_4e7=_4e7*_4e5+val;
}
if(_365===_4e6||len!=null&&_365-_4e6!==len){
return null;
}
return _4e7;
};
function _49a(_4e8){
_365+=2;
var val=_4e4(16);
if(val==null){
_373(_381+2,"Expected hexadecimal number");
}
if(_433(_351.charCodeAt(_365))){
_373(_365,"Identifier directly after number");
}
return _4e8(_3b1,val);
};
function _465(_4e9,_4ea){
var _4eb=_365,_4ec=false,_4ed=_351.charCodeAt(_365)===48;
if(!_4e9&&_4e4(10)===null){
_373(_4eb,"Invalid number");
}
if(_351.charCodeAt(_365)===46){
++_365;
_4e4(10);
_4ec=true;
}
var next=_351.charCodeAt(_365);
if(next===69||next===101){
next=_351.charCodeAt(++_365);
if(next===43||next===45){
++_365;
}
if(_4e4(10)===null){
_373(_4eb,"Invalid number");
}
_4ec=true;
}
if(_433(_351.charCodeAt(_365))){
_373(_365,"Identifier directly after number");
}
var str=_351.slice(_4eb,_365),val;
if(_4ec){
val=parseFloat(str);
}else{
if(!_4ed||str.length===1){
val=parseInt(str,10);
}else{
if(/[89]/.test(str)||_39b){
_373(_4eb,"Invalid number");
}else{
val=parseInt(str,8);
}
}
}
return _4ea(_3b1,val);
};
function _479(_4ee,_4ef){
_365++;
var out="";
for(;;){
if(_365>=_352){
_373(_381,"Unterminated string constant");
}
var ch=_351.charCodeAt(_365);
if(ch===_4ee){
++_365;
return _4ef(_3b3,out);
}
if(ch===92){
ch=_351.charCodeAt(++_365);
var _4f0=/^[0-7]+/.exec(_351.slice(_365,_365+3));
if(_4f0){
_4f0=_4f0[0];
}
while(_4f0&&parseInt(_4f0,8)>255){
_4f0=_4f0.slice(0,_4f0.length-1);
}
if(_4f0==="0"){
_4f0=null;
}
++_365;
if(_4f0){
if(_39b){
_373(_365-2,"Octal literal in strict mode");
}
out+=String.fromCharCode(parseInt(_4f0,8));
_365+=_4f0.length-1;
}else{
switch(ch){
case 110:
out+="\n";
break;
case 114:
out+="\r";
break;
case 120:
out+=String.fromCharCode(_4f1(2));
break;
case 117:
out+=String.fromCharCode(_4f1(4));
break;
case 85:
out+=String.fromCharCode(_4f1(8));
break;
case 116:
out+="\t";
break;
case 98:
out+="\b";
break;
case 118:
out+="\v";
break;
case 102:
out+="\f";
break;
case 48:
out+="\x00";
break;
case 13:
if(_351.charCodeAt(_365)===10){
++_365;
}
case 10:
if(_350.locations){
_37c=_365;
++_366;
}
break;
default:
out+=String.fromCharCode(ch);
break;
}
}
}else{
if(ch===13||ch===10||ch===8232||ch===8233){
_373(_381,"Unterminated string constant");
}
out+=String.fromCharCode(ch);
++_365;
}
}
};
function _4f1(len){
var n=_4e4(16,len);
if(n===null){
_373(_381,"Bad character escape sequence");
}
return n;
};
var _4b8;
function _47a(){
_4b8=false;
var word,_4f2=true,_4f3=_365;
for(;;){
var ch=_351.charCodeAt(_365);
if(_434(ch)){
if(_4b8){
word+=_351.charAt(_365);
}
++_365;
}else{
if(ch===92){
if(!_4b8){
word=_351.slice(_4f3,_365);
}
_4b8=true;
if(_351.charCodeAt(++_365)!=117){
_373(_365,"Expecting Unicode escape sequence \\uXXXX");
}
++_365;
var esc=_4f1(4);
var _4f4=String.fromCharCode(esc);
if(!_4f4){
_373(_365-1,"Invalid Unicode escape");
}
if(!(_4f2?_433(esc):_434(esc))){
_373(_365-4,"Invalid Unicode escape");
}
word+=_4f4;
}else{
break;
}
}
_4f2=false;
}
return _4b8?word:_351.slice(_4f3,_365);
};
function _4de(_4f5,_4f6,_4f7){
var word=_4f5||_47a();
var type=_3b4;
if(_350.preprocess){
var _4f8=_4b6(word,next,_4f6,_4f7);
if(_4f8===true){
return true;
}
}
if(!_4b8){
if(_429(word)){
type=_402[word];
}else{
if(_350.objj&&_42a(word)){
type=_403[word];
}else{
if(_350.forbidReserved&&(_350.ecmaVersion===3?_425:_426)(word)||_39b&&_427(word)){
_373(_381,"The keyword '"+word+"' is reserved");
}
}
}
}
return _440(type,word,_4f8);
};
function _4b6(word,_4f9,_4fa,_4fb){
var _4fc,_4fd=_3a4,_4fe=_3a8;
if(_4fd){
var _4ff=_3a9||_3a4;
if(_4ff.parameterDict&&_4ff.macro.isParameterFunction()(word)){
_4fc=_4ff.parameterDict[word];
if(!_4fc&&_4ff.macro.variadicName===word){
if(_3ab){
_440(_3b4,"");
return true;
}else{
_45a();
_4f9(true,_4fa,_4fb,true);
}
return true;
}
if(_45a(true,true)){
if(_500(35,35)){
_4fa=2;
}
}else{
if(_351.charCodeAt(_365)===35&&_351.charCodeAt(_365+1)===35){
_4fa=2;
}
}
_3a8=_4fc&&_4fc.parameterScope;
_4fa--;
}
}
if(!_4fc&&(!_4fa&&!_3a5||_365<_352)&&_350.preprocessIsMacro(word)){
_3a8=null;
_4fc=_350.preprocessGetMacro(word);
if(_4fc){
if(!_3a4||!_3a4.macro.isArgument){
var i=_3a3.length,_501;
while(i>0){
var item=_3a3[--i],_502=item.macro;
if(_502.identifier===word&&!(_501&&_501.isArgument)){
_4fc=null;
}
_501=_502;
}
}
}else{
_4fc=_36d(word);
}
}
if(_4fc){
var _503=_381;
var _504;
var _505=_4fc.parameters;
var _506;
if(_505){
var pos=_365;
var loc;
if(_350.locations){
loc=new _435;
}
if((_45a(true,true)&&_500(40))||_351.charCodeAt(_365)===40){
_506=true;
}else{
_3aa=loc;
return pos;
}
}
if(!_505||_506){
var _507=_4fc.macro;
if(_506){
var _508=_4fc.variadicName;
var _509=true;
var _50a=0;
_504=Object.create(null);
_45a(true);
if(_351.charCodeAt(_365++)!==40){
_373(_365-1,"Expected '(' before macro prarameters");
}
_45a(true,true,true);
var code=_351.charCodeAt(_365++);
while(_365<_352&&code!==41){
if(_509){
_509=false;
}else{
if(code===44){
_45a(true,true,true);
code=_351.charCodeAt(_365++);
}else{
_373(_365-1,"Expected ',' between macro parameters");
}
}
var _50b=_505[_50a++];
var _50c=_508&&_505.length===_50a;
var _50d=_365-1,_50e=0;
var _50f=_350.locations&&new _43a(_366,_37c);
while(_365<_352&&(_50e||(code!==41&&(code!==44||_50c)))){
if(code===40){
_50e++;
}
if(code===41){
_50e--;
}
if(code===34||code===39){
var _510=code;
code=_351.charCodeAt(_365++);
while(_365<_352&&code!==_510){
if(code===92){
code=_351.charCodeAt(_365++);
if(code!==_510){
continue;
}
}
code=_351.charCodeAt(_365++);
}
}
code=_351.charCodeAt(_365++);
}
var val=_351.slice(_50d,_365-1);
_504[_50b]=new _363(_50b,val,null,_50d+_383,true,_3a9||_3a4,false,_50f);
}
if(code!==41){
_373(_365,"Expected ')' after macro prarameters");
}
_45a(true,true);
}
return _44d(_4fc,_384,_504,_4fe,_365,_4f9,_4fa,_4fb);
}
}
};
function _500(_511,_512){
var i=_3a3.length;
stackloop:
while(i-->0){
var _513=_3a3[i],_514=_513.end,_515=_513.input,_516=_513.inputLen;
for(;;){
var ch=_515.charCodeAt(_514);
if(ch===32){
++_514;
}else{
if(ch===13){
++_514;
var next=_515.charCodeAt(_514);
if(next===10){
++_514;
}
}else{
if(ch===10){
++_514;
}else{
if(ch===9){
++_514;
}else{
if(ch===47){
var next=_515.charCodeAt(_514+1);
if(next===42){
var end=_515.indexOf("*/",_514+=2);
if(end===-1){
_373(_514-2,"Unterminated comment");
}
_514=end+2;
}else{
if(next===47){
ch=_515.charCodeAt(_514+=2);
while(_514<_352&&ch!==10&&ch!==13&&ch!==8232&&ch!==8233){
++_514;
ch=_515.charCodeAt(_514);
}
}else{
break stackloop;
}
}
}else{
if(ch===160||ch===11||ch===12||(ch>=5760&&_42c.test(String.fromCharCode(ch)))){
++_514;
}else{
if(_514>=_516){
continue stackloop;
}else{
if(ch===92){
var pos=_514+1;
ch=_515.charCodeAt(pos);
while(pos<_516&&(ch===32||ch===9||ch===11||ch===12||(ch>=5760&&_42d.test(String.fromCharCode(ch))))){
ch=_515.charCodeAt(++pos);
}
_377.lastIndex=0;
var _517=_377.exec(_515.slice(pos,pos+2));
if(_517&&_517.index===0){
_514=pos+_517[0].length;
}else{
break stackloop;
}
}else{
break stackloop;
}
}
}
}
}
}
}
}
}
}
return _515.charCodeAt(_514)===_511&&(_512==null||_515.charCodeAt(_514+1)===_512);
};
function _44d(_518,_519,_51a,_51b,end,_51c,_51d,_51e){
var _51f=_518.macro;
if(!_51f&&_51c===_4b7){
_51f="1";
}
if(_51f){
_3a4={macro:_518,macroOffset:_519,parameterDict:_51a,end:end,inputLen:_352,tokStart:_381,onlyTransformArgumentsForLastToken:_3a5,currentLine:_366,currentLineStart:_37c};
if(_51b){
_3a4.parameterScope=_51b;
}
_3a4.input=_351;
_3a3.push(_3a4);
_3a5=_51d;
_351=_51f;
_352=_51f.length;
_384=_518.start;
_365=0;
_366=0;
_37c=0;
}else{
if(_3ab){
_440(_3b4,"");
return true;
}
}
_45a();
_51c(true,_51d,_51e,true);
return true;
};
var _363=_34f.Macro=function _363(_520,_521,_522,_523,_524,_525,_526,_527){
this.identifier=_520;
if(_521!=null){
this.macro=_521;
}
if(_522){
this.parameters=_522;
}
if(_523!=null){
this.start=_523;
}
if(_524){
this.isArgument=true;
}
if(_525){
this.parameterScope=_525;
}
if(_526){
this.variadicName=_526;
}
if(_527){
this.locationOffset=_527;
}
};
_363.prototype.isParameterFunction=function(){
return this.isParameterFunctionVar||(this.isParameterFunctionVar=_36c((this.parameters||[]).join(" ")));
};
function next(_528,_529,_52a){
if(!_528){
_395=_381;
_396=_382;
_397=_387;
_385=_383;
}
_398=null;
_449(_52a,_529,_528);
};
function _52b(_52c){
_39b=_52c;
_365=_396;
while(_365<_37c){
_37c=_351.lastIndexOf("\n",_37c-2)+1;
--_366;
}
_37f();
_449();
};
function _52d(){
this.type=null;
this.start=_381+_383;
this.end=null;
};
function _52e(){
this.start=_386;
this.end=null;
if(_353!==null){
this.source=_353;
}
};
function _4c7(){
var node=new _52d();
if(_350.trackComments&&_38a){
node.commentsBefore=_38a;
_38a=null;
}
if(_350.trackSpaces&&_38d){
node.spacesBefore=_38d;
_38d=null;
}
if(_350.locations){
node.loc=new _52e();
}
if(_350.ranges){
node.range=[_381,0];
}
return node;
};
function _4d0(_52f){
var node=new _52d();
node.start=_52f.start;
if(_52f.commentsBefore){
node.commentsBefore=_52f.commentsBefore;
delete _52f.commentsBefore;
}
if(_52f.spacesBefore){
node.spacesBefore=_52f.spacesBefore;
delete _52f.spacesBefore;
}
if(_350.locations){
node.loc=new _52e();
node.loc.start=_52f.loc.start;
}
if(_350.ranges){
node.range=[_52f.range[0],0];
}
return node;
};
var _530;
function _531(node,type){
var _532=_396+_385;
node.type=type;
node.end=_532;
if(_350.trackComments){
if(_38c){
node.commentsAfter=_38c;
_38c=null;
}else{
if(_530&&_530.end===_396&&_530.commentsAfter){
node.commentsAfter=_530.commentsAfter;
delete _530.commentsAfter;
}
}
if(!_350.trackSpaces){
_530=node;
}
}
if(_350.trackSpaces){
if(_38f){
node.spacesAfter=_38f;
_38f=null;
}else{
if(_530&&_530.end===_396&&_530.spacesAfter){
node.spacesAfter=_530.spacesAfter;
delete _530.spacesAfter;
}
}
_530=node;
}
if(_350.locations){
node.loc.end=_397;
}
if(_350.ranges){
node.range[1]=_532;
}
return node;
};
function _533(stmt){
return _350.ecmaVersion>=5&&stmt.type==="ExpressionStatement"&&stmt.expression.type==="Literal"&&stmt.expression.value==="use strict";
};
function eat(type){
if(_388===type){
next();
return true;
}
};
function _534(){
return !_350.strictSemicolons&&(_388===_3b5||_388===_409||_432.test(_394.slice(_396,_380))||(_398&&_350.objj));
};
function _535(){
if(!eat(_40d)&&!_534()){
_373(_381,"Expected a semicolon");
}
};
function _536(type,_537){
if(_388===type){
next();
}else{
_537?_373(_381,_537):_4d7();
}
};
function _4d7(){
_373(_381,"Unexpected token");
};
function _538(expr){
if(expr.type!=="Identifier"&&expr.type!=="MemberExpression"&&expr.type!=="Dereference"){
_373(expr.start,"Assigning to rvalue");
}
if(_39b&&expr.type==="Identifier"&&_428(expr.name)){
_373(expr.start,"Assigning to "+expr.name+" in strict mode");
}
};
function _358(_539){
_395=_396=_365;
if(_350.locations){
_397=new _435;
}
_399=_39b=null;
_39a=[];
_449();
var node=_539||_4c7(),_53a=true;
if(!_539){
node.body=[];
}
while(_388!==_3b5){
var stmt=_53b();
node.body.push(stmt);
if(_53a&&_533(stmt)){
_52b(true);
}
_53a=false;
}
return _531(node,"Program");
};
var _53c={kind:"loop"},_53d={kind:"switch"};
function _53b(){
if(_388===_414||_388===_416&&_389=="/="){
_449(true);
}
var _53e=_388,node=_4c7();
if(_398){
node.expression=_53f(_398,_398.object);
_535();
return _531(node,"ExpressionStatement");
}
switch(_53e){
case _3b7:
case _3ba:
next();
var _540=_53e===_3b7;
if(eat(_40d)||_534()){
node.label=null;
}else{
if(_388!==_3b4){
_4d7();
}else{
node.label=_541();
_535();
}
}
for(var i=0;i<_39a.length;++i){
var lab=_39a[i];
if(node.label==null||lab.name===node.label.name){
if(lab.kind!=null&&(_540||lab.kind==="loop")){
break;
}
if(node.label&&_540){
break;
}
}
}
if(i===_39a.length){
_373(node.start,"Unsyntactic "+_53e.keyword);
}
return _531(node,_540?"BreakStatement":"ContinueStatement");
case _3bb:
next();
_535();
return _531(node,"DebuggerStatement");
case _3bd:
next();
_39a.push(_53c);
node.body=_53b();
_39a.pop();
_536(_3c8,"Expected 'while' at end of do statement");
node.test=_542();
_535();
return _531(node,"DoWhileStatement");
case _3c0:
next();
_39a.push(_53c);
_536(_40a,"Expected '(' after 'for'");
if(_388===_40d){
return _543(node,null);
}
if(_388===_3c7){
var init=_4c7();
next();
_544(init,true);
if(init.declarations.length===1&&eat(_3d0)){
return _545(node,init);
}
return _543(node,init);
}
var init=_546(false,true);
if(eat(_3d0)){
_538(init);
return _545(node,init);
}
return _543(node,init);
case _3c1:
next();
return _547(node,true);
case _3c2:
next();
node.test=_542();
node.consequent=_53b();
node.alternate=eat(_3be)?_53b():null;
return _531(node,"IfStatement");
case _3c3:
if(!_399){
_373(_381,"'return' outside of function");
}
next();
if(eat(_40d)||_534()){
node.argument=null;
}else{
node.argument=_546();
_535();
}
return _531(node,"ReturnStatement");
case _3c4:
next();
node.discriminant=_542();
node.cases=[];
_536(_408,"Expected '{' in switch statement");
_39a.push(_53d);
for(var cur,_548;_388!=_409;){
if(_388===_3b8||_388===_3bc){
var _549=_388===_3b8;
if(cur){
_531(cur,"SwitchCase");
}
node.cases.push(cur=_4c7());
cur.consequent=[];
next();
if(_549){
cur.test=_546();
}else{
if(_548){
_373(_395,"Multiple default clauses");
}
_548=true;
cur.test=null;
}
_536(_40e,"Expected ':' after case clause");
}else{
if(!cur){
_4d7();
}
cur.consequent.push(_53b());
}
}
if(cur){
_531(cur,"SwitchCase");
}
next();
_39a.pop();
return _531(node,"SwitchStatement");
case _3c5:
next();
if(_432.test(_392.slice(_396,_381))){
_373(_396,"Illegal newline after throw");
}
node.argument=_546();
_535();
return _531(node,"ThrowStatement");
case _3c6:
next();
node.block=_54a();
node.handler=null;
if(_388===_3b9){
var _54b=_4c7();
next();
_536(_40a,"Expected '(' after 'catch'");
_54b.param=_541();
if(_39b&&_428(_54b.param.name)){
_373(_54b.param.start,"Binding "+_54b.param.name+" in strict mode");
}
_536(_40b,"Expected closing ')' after catch");
_54b.guard=null;
_54b.body=_54a();
node.handler=_531(_54b,"CatchClause");
}
node.guardedHandlers=_3b0;
node.finalizer=eat(_3bf)?_54a():null;
if(!node.handler&&!node.finalizer){
_373(node.start,"Missing catch or finally clause");
}
return _531(node,"TryStatement");
case _3c7:
next();
node=_544(node);
_535();
return node;
case _3c8:
next();
node.test=_542();
_39a.push(_53c);
node.body=_53b();
_39a.pop();
return _531(node,"WhileStatement");
case _3c9:
if(_39b){
_373(_381,"'with' in strict mode");
}
next();
node.object=_542();
node.body=_53b();
return _531(node,"WithStatement");
case _408:
return _54a();
case _40d:
next();
return _531(node,"EmptyStatement");
case _3e1:
if(_350.objj){
next();
node.classname=_541(true);
if(eat(_40e)){
node.superclassname=_541(true);
}else{
if(eat(_40a)){
node.categoryname=_541(true);
_536(_40b,"Expected closing ')' after category name");
}
}
if(_389==="<"){
next();
var _54c=[],_54d=true;
node.protocols=_54c;
while(_389!==">"){
if(!_54d){
_536(_40c,"Expected ',' between protocol names");
}else{
_54d=false;
}
_54c.push(_541(true));
}
next();
}
if(eat(_408)){
node.ivardeclarations=[];
for(;;){
if(eat(_409)){
break;
}
_54e(node);
}
node.endOfIvars=_381;
}
node.body=[];
while(!eat(_3d4)){
if(_388===_3b5){
_373(_365,"Expected '@end' after '@interface'");
}
node.body.push(_54f());
}
return _531(node,"InterfaceDeclarationStatement");
}
break;
case _3d1:
if(_350.objj){
next();
node.classname=_541(true);
if(eat(_40e)){
node.superclassname=_541(true);
}else{
if(eat(_40a)){
node.categoryname=_541(true);
_536(_40b,"Expected closing ')' after category name");
}
}
if(_389==="<"){
next();
var _54c=[],_54d=true;
node.protocols=_54c;
while(_389!==">"){
if(!_54d){
_536(_40c,"Expected ',' between protocol names");
}else{
_54d=false;
}
_54c.push(_541(true));
}
next();
}
if(eat(_408)){
node.ivardeclarations=[];
for(;;){
if(eat(_409)){
break;
}
_54e(node);
}
node.endOfIvars=_381;
}
node.body=[];
while(!eat(_3d4)){
if(_388===_3b5){
_373(_365,"Expected '@end' after '@implementation'");
}
node.body.push(_54f());
}
return _531(node,"ClassDeclarationStatement");
}
break;
case _3de:
if(_350.objj&&_351.charCodeAt(_365)!==40){
next();
node.protocolname=_541(true);
if(_389==="<"){
next();
var _54c=[],_54d=true;
node.protocols=_54c;
while(_389!==">"){
if(!_54d){
_536(_40c,"Expected ',' between protocol names");
}else{
_54d=false;
}
_54c.push(_541(true));
}
next();
}
while(!eat(_3d4)){
if(_388===_3b5){
_373(_365,"Expected '@end' after '@protocol'");
}
if(eat(_3e0)){
continue;
}
if(eat(_3df)){
while(!eat(_3e0)&&_388!==_3d4){
(node.optional||(node.optional=[])).push(_550());
}
}else{
(node.required||(node.required=[])).push(_550());
}
}
return _531(node,"ProtocolDeclarationStatement");
}
break;
case _3d5:
if(_350.objj){
next();
if(_388===_3b3){
node.localfilepath=true;
}else{
if(_388===_3e3){
node.localfilepath=false;
}else{
_4d7();
}
}
node.filename=_551();
return _531(node,"ImportStatement");
}
break;
case _3f0:
if(_350.objj){
next();
return _531(node,"PreprocessStatement");
}
break;
case _3d8:
if(_350.objj){
next();
node.id=_541(false);
return _531(node,"ClassStatement");
}
break;
case _3d9:
if(_350.objj){
next();
node.id=_541(false);
return _531(node,"GlobalStatement");
}
break;
case _3e2:
if(_350.objj){
next();
node.typedefname=_541(true);
return _531(node,"TypeDefStatement");
}
break;
}
var _552=_389,expr=_546();
if(_53e===_3b4&&expr.type==="Identifier"&&eat(_40e)){
for(var i=0;i<_39a.length;++i){
if(_39a[i].name===_552){
_373(expr.start,"Label '"+_552+"' is already declared");
}
}
var kind=_388.isLoop?"loop":_388===_3c4?"switch":null;
_39a.push({name:_552,kind:kind});
node.body=_53b();
_39a.pop();
node.label=expr;
return _531(node,"LabeledStatement");
}else{
node.expression=expr;
_535();
return _531(node,"ExpressionStatement");
}
};
function _54e(node){
var _553;
if(eat(_3d2)){
_553=true;
}
var type=_554();
if(_39b&&_428(type.name)){
_373(type.start,"Binding "+type.name+" in strict mode");
}
for(;;){
var decl=_4c7();
if(_553){
decl.outlet=_553;
}
decl.ivartype=type;
decl.id=_541();
if(_39b&&_428(decl.id.name)){
_373(decl.id.start,"Binding "+decl.id.name+" in strict mode");
}
if(eat(_3d3)){
decl.accessors={};
if(eat(_40a)){
if(!eat(_40b)){
for(;;){
var _555=_541(true);
switch(_555.name){
case "property":
case "getter":
_536(_415,"Expected '=' after 'getter' accessor attribute");
decl.accessors[_555.name]=_541(true);
break;
case "setter":
_536(_415,"Expected '=' after 'setter' accessor attribute");
var _556=_541(true);
decl.accessors[_555.name]=_556;
if(eat(_40e)){
_556.end=_381;
}
_556.name+=":";
break;
case "readwrite":
case "readonly":
case "copy":
decl.accessors[_555.name]=true;
break;
default:
_373(_555.start,"Unknown accessors attribute '"+_555.name+"'");
}
if(!eat(_40c)){
break;
}
}
_536(_40b,"Expected closing ')' after accessor attributes");
}
}
}
_531(decl,"IvarDeclaration");
node.ivardeclarations.push(decl);
if(!eat(_40c)){
break;
}
}
_535();
};
function _557(node){
node.methodtype=_389;
_536(_417,"Method declaration must start with '+' or '-'");
if(eat(_40a)){
var _558=_4c7();
if(eat(_3d6)){
node.action=_531(_558,"ObjectiveJActionType");
_558=_4c7();
}
if(!eat(_40b)){
node.returntype=_554(_558);
_536(_40b,"Expected closing ')' after method return type");
}
}
var _559=true,_55a=[],args=[];
node.selectors=_55a;
node.arguments=args;
for(;;){
if(_388!==_40e){
_55a.push(_541(true));
if(_559&&_388!==_40e){
break;
}
}else{
_55a.push(null);
}
_536(_40e,"Expected ':' in selector");
var _55b={};
args.push(_55b);
if(eat(_40a)){
_55b.type=_554();
_536(_40b,"Expected closing ')' after method argument type");
}
_55b.identifier=_541(false);
if(_388===_408||_388===_40d){
break;
}
if(eat(_40c)){
_536(_412,"Expected '...' after ',' in method declaration");
node.parameters=true;
break;
}
_559=false;
}
};
function _54f(){
var _55c=_4c7();
if(_389==="+"||_389==="-"){
_557(_55c);
eat(_40d);
_55c.startOfBody=_396;
var _55d=_399,_55e=_39a;
_399=true;
_39a=[];
_55c.body=_54a(true);
_399=_55d;
_39a=_55e;
return _531(_55c,"MethodDeclarationStatement");
}else{
return _53b();
}
};
function _550(){
var _55f=_4c7();
_557(_55f);
_535();
return _531(_55f,"MethodDeclarationStatement");
};
function _542(){
_536(_40a,"Expected '(' before expression");
var val=_546();
_536(_40b,"Expected closing ')' after expression");
return val;
};
function _54a(_560){
var node=_4c7(),_561=true,_39b=false,_562;
node.body=[];
_536(_408,"Expected '{' before block");
while(!eat(_409)){
var stmt=_53b();
node.body.push(stmt);
if(_561&&_560&&_533(stmt)){
_562=_39b;
_52b(_39b=true);
}
_561=false;
}
if(_39b&&!_562){
_52b(false);
}
return _531(node,"BlockStatement");
};
function _543(node,init){
node.init=init;
_536(_40d,"Expected ';' in for statement");
node.test=_388===_40d?null:_546();
_536(_40d,"Expected ';' in for statement");
node.update=_388===_40b?null:_546();
_536(_40b,"Expected closing ')' in for statement");
node.body=_53b();
_39a.pop();
return _531(node,"ForStatement");
};
function _545(node,init){
node.left=init;
node.right=_546();
_536(_40b,"Expected closing ')' in for statement");
node.body=_53b();
_39a.pop();
return _531(node,"ForInStatement");
};
function _544(node,noIn){
node.declarations=[];
node.kind="var";
for(;;){
var decl=_4c7();
decl.id=_541();
if(_39b&&_428(decl.id.name)){
_373(decl.id.start,"Binding "+decl.id.name+" in strict mode");
}
decl.init=eat(_415)?_546(true,noIn):null;
node.declarations.push(_531(decl,"VariableDeclarator"));
if(!eat(_40c)){
break;
}
}
return _531(node,"VariableDeclaration");
};
function _546(_563,noIn){
var expr=_564(noIn);
if(!_563&&_388===_40c){
var node=_4d0(expr);
node.expressions=[expr];
while(eat(_40c)){
node.expressions.push(_564(noIn));
}
return _531(node,"SequenceExpression");
}
return expr;
};
function _564(noIn){
var left=_565(noIn);
if(_388.isAssign){
var node=_4d0(left);
node.operator=_389;
node.left=left;
next();
node.right=_564(noIn);
_538(left);
return _531(node,"AssignmentExpression");
}
return left;
};
function _565(noIn){
var expr=_566(noIn);
if(eat(_410)){
var node=_4d0(expr);
node.test=expr;
node.consequent=_546(true);
_536(_40e,"Expected ':' in conditional expression");
node.alternate=_546(true,noIn);
return _531(node,"ConditionalExpression");
}
return expr;
};
function _566(noIn){
return _567(_568(),-1,noIn);
};
function _567(left,_569,noIn){
var prec=_388.binop;
if(prec!=null&&(!noIn||_388!==_3d0)){
if(prec>_569){
var node=_4d0(left);
node.left=left;
node.operator=_389;
next();
node.right=_567(_568(),prec,noIn);
var node=_531(node,/&&|\|\|/.test(node.operator)?"LogicalExpression":"BinaryExpression");
return _567(node,_569,noIn);
}
}
return left;
};
function _568(){
if(_388.prefix){
var node=_4c7(),_56a=_388.isUpdate;
node.operator=_389;
node.prefix=true;
_37e=true;
next();
node.argument=_568();
if(_56a){
_538(node.argument);
}else{
if(_39b&&node.operator==="delete"&&node.argument.type==="Identifier"){
_373(node.start,"Deleting local variable in strict mode");
}
}
return _531(node,_56a?"UpdateExpression":"UnaryExpression");
}
var expr=_56b();
while(_388.postfix&&!_534()){
var node=_4d0(expr);
node.operator=_389;
node.prefix=false;
node.argument=expr;
_538(expr);
next();
expr=_531(node,"UpdateExpression");
}
return expr;
};
function _56b(){
return _56c(_56d());
};
function _56c(base,_56e){
if(eat(_40f)){
var node=_4d0(base);
node.object=base;
node.property=_541(true);
node.computed=false;
return _56c(_531(node,"MemberExpression"),_56e);
}else{
if(_350.objj){
var _56f=_4c7();
}
if(eat(_406)){
var expr=_546();
if(_350.objj&&_388!==_407){
_56f.object=expr;
_398=_56f;
return base;
}
var node=_4d0(base);
node.object=base;
node.property=expr;
node.computed=true;
_536(_407,"Expected closing ']' in subscript");
return _56c(_531(node,"MemberExpression"),_56e);
}else{
if(!_56e&&eat(_40a)){
var node=_4d0(base);
node.callee=base;
node.arguments=_570(_40b,_388===_40b?null:_546(true),false);
return _56c(_531(node,"CallExpression"),_56e);
}
}
}
return base;
};
function _56d(){
switch(_388){
case _3cb:
var node=_4c7();
next();
return _531(node,"ThisExpression");
case _3b4:
return _541();
case _3b1:
case _3b3:
case _3b2:
return _551();
case _3cd:
case _3ce:
case _3cf:
var node=_4c7();
node.value=_388.atomValue;
node.raw=_388.keyword;
next();
return _531(node,"Literal");
case _40a:
var _571=_386,_572=_383,_573=_381+_572;
next();
var val=_546();
val.start=_573;
val.end=_382+_572;
if(_350.locations){
val.loc.start=_571;
val.loc.end=_387;
}
if(_350.ranges){
val.range=[_573,_382+_385];
}
_536(_40b,"Expected closing ')' in expression");
return val;
case _3db:
var node=_4c7(),_574=null;
next();
_536(_406,"Expected '[' at beginning of array literal");
if(_388!==_407){
_574=_546(true,true);
}
node.elements=_570(_407,_574,true,true);
return _531(node,"ArrayLiteral");
case _406:
var node=_4c7(),_574=null;
next();
if(_388!==_40c&&_388!==_407){
_574=_546(true,true);
if(_388!==_40c&&_388!==_407){
return _53f(node,_574);
}
}
node.elements=_570(_407,_574,true,true);
return _531(node,"ArrayExpression");
case _3da:
var node=_4c7();
next();
var r=_575();
node.keys=r[0];
node.values=r[1];
return _531(node,"DictionaryLiteral");
case _408:
return _576();
case _3c1:
var node=_4c7();
next();
return _547(node,false);
case _3ca:
return _577();
case _3d7:
var node=_4c7();
next();
_536(_40a,"Expected '(' after '@selector'");
_578(node,_40b);
_536(_40b,"Expected closing ')' after selector");
return _531(node,"SelectorLiteralExpression");
case _3de:
var node=_4c7();
next();
_536(_40a,"Expected '(' after '@protocol'");
node.id=_541(true);
_536(_40b,"Expected closing ')' after protocol name");
return _531(node,"ProtocolLiteralExpression");
case _3dc:
var node=_4c7();
next();
_536(_40a,"Expected '(' after '@ref'");
node.element=_541(node,_40b);
_536(_40b,"Expected closing ')' after ref");
return _531(node,"Reference");
case _3dd:
var node=_4c7();
next();
_536(_40a,"Expected '(' after '@deref'");
node.expr=_546(true,true);
_536(_40b,"Expected closing ')' after deref");
return _531(node,"Dereference");
default:
if(_388.okAsIdent){
return _541();
}
_4d7();
}
};
function _53f(node,_579){
_57a(node,_407);
if(_579.type==="Identifier"&&_579.name==="super"){
node.superObject=true;
}else{
node.object=_579;
}
return _531(node,"MessageSendExpression");
};
function _578(node,_57b){
var _57c=true,_57d=[];
for(;;){
if(_388!==_40e){
_57d.push(_541(true).name);
if(_57c&&_388===_57b){
break;
}
}
_536(_40e,"Expected ':' in selector");
_57d.push(":");
if(_388===_57b){
break;
}
_57c=false;
}
node.selector=_57d.join("");
};
function _57a(node,_57e){
var _57f=true,_580=[],args=[],_581=[];
node.selectors=_580;
node.arguments=args;
for(;;){
if(_388!==_40e){
_580.push(_541(true));
if(_57f&&eat(_57e)){
break;
}
}else{
_580.push(null);
}
_536(_40e,"Expected ':' in selector");
args.push(_546(true,true));
if(eat(_57e)){
break;
}
if(_388===_40c){
node.parameters=[];
while(eat(_40c)){
node.parameters.push(_546(true,true));
}
eat(_57e);
break;
}
_57f=false;
}
};
function _577(){
var node=_4c7();
next();
node.callee=_56c(_56d(false),true);
if(eat(_40a)){
node.arguments=_570(_40b,_388===_40b?null:_546(true),false);
}else{
node.arguments=_3b0;
}
return _531(node,"NewExpression");
};
function _576(){
var node=_4c7(),_582=true,_583=false;
node.properties=[];
next();
while(!eat(_409)){
if(!_582){
_536(_40c,"Expected ',' in object literal");
if(_350.allowTrailingCommas&&eat(_409)){
break;
}
}else{
_582=false;
}
var prop={key:_584()},_585=false,kind;
if(eat(_40e)){
prop.value=_546(true);
kind=prop.kind="init";
}else{
if(_350.ecmaVersion>=5&&prop.key.type==="Identifier"&&(prop.key.name==="get"||prop.key.name==="set")){
_585=_583=true;
kind=prop.kind=prop.key.name;
prop.key=_584();
if(_388!==_40a){
_4d7();
}
prop.value=_547(_4c7(),false);
}else{
_4d7();
}
}
if(prop.key.type==="Identifier"&&(_39b||_583)){
for(var i=0;i<node.properties.length;++i){
var _586=node.properties[i];
if(_586.key.name===prop.key.name){
var _587=kind==_586.kind||_585&&_586.kind==="init"||kind==="init"&&(_586.kind==="get"||_586.kind==="set");
if(_587&&!_39b&&kind==="init"&&_586.kind==="init"){
_587=false;
}
if(_587){
_373(prop.key.start,"Redefinition of property");
}
}
}
}
node.properties.push(prop);
}
return _531(node,"ObjectExpression");
};
function _584(){
if(_388===_3b1||_388===_3b3){
return _56d();
}
return _541(true);
};
function _547(node,_588){
if(_388===_3b4){
node.id=_541();
}else{
if(_588){
_4d7();
}else{
node.id=null;
}
}
node.params=[];
var _589=true;
_536(_40a,"Expected '(' before function parameters");
while(!eat(_40b)){
if(!_589){
_536(_40c,"Expected ',' between function parameters");
}else{
_589=false;
}
node.params.push(_541());
}
var _58a=_399,_58b=_39a;
_399=true;
_39a=[];
node.body=_54a(true);
_399=_58a;
_39a=_58b;
if(_39b||node.body.body.length&&_533(node.body.body[0])){
for(var i=node.id?-1:0;i<node.params.length;++i){
var id=i<0?node.id:node.params[i];
if(_427(id.name)||_428(id.name)){
_373(id.start,"Defining '"+id.name+"' in strict mode");
}
if(i>=0){
for(var j=0;j<i;++j){
if(id.name===node.params[j].name){
_373(id.start,"Argument name clash in strict mode");
}
}
}
}
}
return _531(node,_588?"FunctionDeclaration":"FunctionExpression");
};
function _570(_58c,_58d,_58e,_58f){
if(_58d&&eat(_58c)){
return [_58d];
}
var elts=[],_590=true;
while(!eat(_58c)){
if(_590){
_590=false;
if(_58f&&_388===_40c&&!_58d){
elts.push(null);
}else{
elts.push(_58d);
}
}else{
_536(_40c,"Expected ',' between expressions");
if(_58e&&_350.allowTrailingCommas&&eat(_58c)){
break;
}
if(_58f&&_388===_40c){
elts.push(null);
}else{
elts.push(_546(true));
}
}
}
return elts;
};
function _575(){
_536(_408,"Expected '{' before dictionary");
var keys=[],_591=[],_592=true;
while(!eat(_409)){
if(!_592){
_536(_40c,"Expected ',' between expressions");
if(_350.allowTrailingCommas&&eat(_409)){
break;
}
}
keys.push(_546(true,true));
_536(_40e,"Expected ':' between dictionary key and value");
_591.push(_546(true,true));
_592=false;
}
return [keys,_591];
};
function _541(_593){
var node=_4c7();
node.name=_388===_3b4?_389:(((_593&&!_350.forbidReserved)||_388.okAsIdent)&&_388.keyword)||_4d7();
_37e=false;
next();
return _531(node,"Identifier");
};
function _551(){
var node=_4c7();
node.value=_389;
node.raw=_392.slice(_381,_382);
next();
return _531(node,"Literal");
};
function _554(_594){
var node=_594?_4d0(_594):_4c7(),_595=false;
if(_388===_3b4){
node.name=_389;
node.typeisclass=true;
_595=true;
next();
}else{
node.typeisclass=false;
node.name=_388.keyword;
if(!eat(_3cc)){
if(eat(_3eb)){
_595=true;
}else{
var _596;
if(eat(_3ee)||eat(_3ec)||eat(_3ed)||eat(_3ef)){
_596=_388.keyword;
}else{
if(eat(_3e5)||eat(_3e4)){
_596=_388.keyword||true;
}
if(eat(_3e7)||eat(_3e6)||eat(_3e8)){
if(_596){
node.name+=" "+_596;
}
_596=_388.keyword||true;
}else{
if(eat(_3e9)){
if(_596){
node.name+=" "+_596;
}
_596=_388.keyword||true;
}
if(eat(_3ea)){
if(_596){
node.name+=" "+_596;
}
_596=_388.keyword||true;
if(eat(_3ea)){
node.name+=" "+_596;
}
}
}
if(!_596){
node.name=(!_350.forbidReserved&&_388.keyword)||_4d7();
node.typeisclass=true;
_595=true;
next();
}
}
}
}
}
if(_595){
if(_389==="<"){
var _597=true,_598=[];
node.protocols=_598;
do{
next();
if(_597){
_597=false;
}else{
eat(_40c);
}
_598.push(_541(true));
}while(_389!==">");
next();
}
}
return _531(node,"ObjectiveJType");
};
})(_2.acorn,_2.acorn.walk);
if(!_2.acorn){
_2.acorn={};
_2.acorn.walk={};
}
(function(_599){
"use strict";
_599.simple=function(node,_59a,base,_59b){
if(!base){
base=_599;
}
function c(node,st,_59c){
var type=_59c||node.type,_59d=_59a[type];
if(_59d){
_59d(node,st);
}
base[type](node,st,c);
};
c(node,_59b);
};
_599.recursive=function(node,_59e,_59f,base){
var _5a0=_599.make(_59f,base);
function c(node,st,_5a1){
return _5a0[_5a1||node.type](node,st,c);
};
return c(node,_59e);
};
_599.make=function(_5a2,base){
if(!base){
base=_599;
}
var _5a3={};
for(var type in base){
_5a3[type]=base[type];
}
for(var type in _5a2){
_5a3[type]=_5a2[type];
}
return _5a3;
};
function _5a4(node,st,c){
c(node,st);
};
function _5a5(node,st,c){
};
_599.Program=_599.BlockStatement=function(node,st,c){
for(var i=0;i<node.body.length;++i){
c(node.body[i],st,"Statement");
}
};
_599.Statement=_5a4;
_599.EmptyStatement=_5a5;
_599.ExpressionStatement=function(node,st,c){
c(node.expression,st,"Expression");
};
_599.IfStatement=function(node,st,c){
c(node.test,st,"Expression");
c(node.consequent,st,"Statement");
if(node.alternate){
c(node.alternate,st,"Statement");
}
};
_599.LabeledStatement=function(node,st,c){
c(node.body,st,"Statement");
};
_599.BreakStatement=_599.ContinueStatement=_5a5;
_599.WithStatement=function(node,st,c){
c(node.object,st,"Expression");
c(node.body,st,"Statement");
};
_599.SwitchStatement=function(node,st,c){
c(node.discriminant,st,"Expression");
for(var i=0;i<node.cases.length;++i){
var cs=node.cases[i];
if(cs.test){
c(cs.test,st,"Expression");
}
for(var j=0;j<cs.consequent.length;++j){
c(cs.consequent[j],st,"Statement");
}
}
};
_599.ReturnStatement=function(node,st,c){
if(node.argument){
c(node.argument,st,"Expression");
}
};
_599.ThrowStatement=function(node,st,c){
c(node.argument,st,"Expression");
};
_599.TryStatement=function(node,st,c){
c(node.block,st,"Statement");
if(node.handler){
c(node.handler.body,st,"ScopeBody");
}
if(node.finalizer){
c(node.finalizer,st,"Statement");
}
};
_599.WhileStatement=function(node,st,c){
c(node.test,st,"Expression");
c(node.body,st,"Statement");
};
_599.DoWhileStatement=function(node,st,c){
c(node.body,st,"Statement");
c(node.test,st,"Expression");
};
_599.ForStatement=function(node,st,c){
if(node.init){
c(node.init,st,"ForInit");
}
if(node.test){
c(node.test,st,"Expression");
}
if(node.update){
c(node.update,st,"Expression");
}
c(node.body,st,"Statement");
};
_599.ForInStatement=function(node,st,c){
c(node.left,st,"ForInit");
c(node.right,st,"Expression");
c(node.body,st,"Statement");
};
_599.ForInit=function(node,st,c){
if(node.type=="VariableDeclaration"){
c(node,st);
}else{
c(node,st,"Expression");
}
};
_599.DebuggerStatement=_5a5;
_599.FunctionDeclaration=function(node,st,c){
c(node,st,"Function");
};
_599.VariableDeclaration=function(node,st,c){
for(var i=0;i<node.declarations.length;++i){
var decl=node.declarations[i];
if(decl.init){
c(decl.init,st,"Expression");
}
}
};
_599.Function=function(node,st,c){
c(node.body,st,"ScopeBody");
};
_599.ScopeBody=function(node,st,c){
c(node,st,"Statement");
};
_599.Expression=_5a4;
_599.ThisExpression=_5a5;
_599.ArrayExpression=_599.ArrayLiteral=function(node,st,c){
for(var i=0;i<node.elements.length;++i){
var elt=node.elements[i];
if(elt){
c(elt,st,"Expression");
}
}
};
_599.DictionaryLiteral=function(node,st,c){
for(var i=0;i<node.keys.length;i++){
var key=node.keys[i];
c(key,st,"Expression");
var _5a6=node.values[i];
c(_5a6,st,"Expression");
}
};
_599.ObjectExpression=function(node,st,c){
for(var i=0;i<node.properties.length;++i){
c(node.properties[i].value,st,"Expression");
}
};
_599.FunctionExpression=_599.FunctionDeclaration;
_599.SequenceExpression=function(node,st,c){
for(var i=0;i<node.expressions.length;++i){
c(node.expressions[i],st,"Expression");
}
};
_599.UnaryExpression=_599.UpdateExpression=function(node,st,c){
c(node.argument,st,"Expression");
};
_599.BinaryExpression=_599.AssignmentExpression=_599.LogicalExpression=function(node,st,c){
c(node.left,st,"Expression");
c(node.right,st,"Expression");
};
_599.ConditionalExpression=function(node,st,c){
c(node.test,st,"Expression");
c(node.consequent,st,"Expression");
c(node.alternate,st,"Expression");
};
_599.NewExpression=_599.CallExpression=function(node,st,c){
c(node.callee,st,"Expression");
if(node.arguments){
for(var i=0;i<node.arguments.length;++i){
c(node.arguments[i],st,"Expression");
}
}
};
_599.MemberExpression=function(node,st,c){
c(node.object,st,"Expression");
if(node.computed){
c(node.property,st,"Expression");
}
};
_599.Identifier=_599.Literal=_5a5;
_599.ClassDeclarationStatement=function(node,st,c){
if(node.ivardeclarations){
for(var i=0;i<node.ivardeclarations.length;++i){
c(node.ivardeclarations[i],st,"IvarDeclaration");
}
}
for(var i=0;i<node.body.length;++i){
c(node.body[i],st,"Statement");
}
};
_599.ImportStatement=_5a5;
_599.IvarDeclaration=_5a5;
_599.PreprocessStatement=_5a5;
_599.ClassStatement=_5a5;
_599.GlobalStatement=_5a5;
_599.ProtocolDeclarationStatement=function(node,st,c){
if(node.required){
for(var i=0;i<node.required.length;++i){
c(node.required[i],st,"Statement");
}
}
if(node.optional){
for(var i=0;i<node.optional.length;++i){
c(node.optional[i],st,"Statement");
}
}
};
_599.TypeDefStatement=_5a5;
_599.MethodDeclarationStatement=function(node,st,c){
var body=node.body;
if(body){
c(body,st,"Statement");
}
};
_599.MessageSendExpression=function(node,st,c){
if(!node.superObject){
c(node.object,st,"Expression");
}
if(node.arguments){
for(var i=0;i<node.arguments.length;++i){
c(node.arguments[i],st,"Expression");
}
}
if(node.parameters){
for(var i=0;i<node.parameters.length;++i){
c(node.parameters[i],st,"Expression");
}
}
};
_599.SelectorLiteralExpression=_5a5;
_599.ProtocolLiteralExpression=_5a5;
_599.Reference=function(node,st,c){
c(node.element,st,"Identifier");
};
_599.Dereference=function(node,st,c){
c(node.expr,st,"Expression");
};
function _5a7(prev){
return {vars:Object.create(null),prev:prev};
};
_599.scopeVisitor=_599.make({Function:function(node,_5a8,c){
var _5a9=_5a7(_5a8);
for(var i=0;i<node.params.length;++i){
_5a9.vars[node.params[i].name]={type:"argument",node:node.params[i]};
}
if(node.id){
var decl=node.type=="FunctionDeclaration";
(decl?_5a8:_5a9).vars[node.id.name]={type:decl?"function":"function name",node:node.id};
}
c(node.body,_5a9,"ScopeBody");
},TryStatement:function(node,_5aa,c){
c(node.block,_5aa,"Statement");
if(node.handler){
var _5ab=_5a7(_5aa);
_5ab.vars[node.handler.param.name]={type:"catch clause",node:node.handler.param};
c(node.handler.body,_5ab,"ScopeBody");
}
if(node.finalizer){
c(node.finalizer,_5aa,"Statement");
}
},VariableDeclaration:function(node,_5ac,c){
for(var i=0;i<node.declarations.length;++i){
var decl=node.declarations[i];
_5ac.vars[decl.id.name]={type:"var",node:decl.id};
if(decl.init){
c(decl.init,_5ac,"Expression");
}
}
}});
})(typeof _2=="undefined"?acorn.walk={}:_2.acorn.walk);
(function(mod){
mod(_2.ObjJCompiler||(_2.ObjJCompiler={}),_2.acorn,_2.acorn.walk);
})(function(_5ad,_5ae,walk,_5af){
"use strict";
_5ad.version="0.3.7";
var _5b0=function(prev,base){
this.vars=Object.create(null);
if(base){
for(var key in base){
this[key]=base[key];
}
}
this.prev=prev;
if(prev){
this.compiler=prev.compiler;
this.nodeStack=prev.nodeStack.slice(0);
this.nodePriorStack=prev.nodePriorStack.slice(0);
this.nodeStackOverrideType=prev.nodeStackOverrideType.slice(0);
}else{
this.nodeStack=[];
this.nodePriorStack=[];
this.nodeStackOverrideType=[];
}
};
_5b0.prototype.toString=function(){
return this.ivars?"ivars: "+JSON.stringify(this.ivars):"<No ivars>";
};
_5b0.prototype.compiler=function(){
return this.compiler;
};
_5b0.prototype.rootScope=function(){
return this.prev?this.prev.rootScope():this;
};
_5b0.prototype.isRootScope=function(){
return !this.prev;
};
_5b0.prototype.currentClassName=function(){
return this.classDef?this.classDef.name:this.prev?this.prev.currentClassName():null;
};
_5b0.prototype.currentProtocolName=function(){
return this.protocolDef?this.protocolDef.name:this.prev?this.prev.currentProtocolName():null;
};
_5b0.prototype.getIvarForCurrentClass=function(_5b1){
if(this.ivars){
var ivar=this.ivars[_5b1];
if(ivar){
return ivar;
}
}
var prev=this.prev;
if(prev&&!this.classDef){
return prev.getIvarForCurrentClass(_5b1);
}
return null;
};
_5b0.prototype.getLvar=function(_5b2,_5b3){
if(this.vars){
var lvar=this.vars[_5b2];
if(lvar){
return lvar;
}
}
var prev=this.prev;
if(prev&&(!_5b3||!this.methodType)){
return prev.getLvar(_5b2,_5b3);
}
return null;
};
_5b0.prototype.currentMethodType=function(){
return this.methodType?this.methodType:this.prev?this.prev.currentMethodType():null;
};
_5b0.prototype.copyAddedSelfToIvarsToParent=function(){
if(this.prev&&this.addedSelfToIvars){
for(var key in this.addedSelfToIvars){
var _5b4=this.addedSelfToIvars[key],_5b5=(this.prev.addedSelfToIvars||(this.prev.addedSelfToIvars=Object.create(null)))[key]||(this.prev.addedSelfToIvars[key]=[]);
_5b5.push.apply(_5b5,_5b4);
}
}
};
_5b0.prototype.addMaybeWarning=function(_5b6){
var _5b7=this.rootScope(),_5b8=_5b7._maybeWarnings;
if(!_5b8){
_5b7._maybeWarnings=_5b8=[_5b6];
}else{
var _5b9=_5b8[_5b8.length-1];
if(!_5b9.isEqualTo(_5b6)){
_5b8.push(_5b6);
}
}
};
_5b0.prototype.maybeWarnings=function(){
return this.rootScope()._maybeWarnings;
};
_5b0.prototype.pushNode=function(node,_5ba){
var _5bb=this.nodePriorStack,_5bc=_5bb.length,_5bd=_5bc?_5bb[_5bc-1]:null,_5be=_5bc?this.nodeStack[_5bc-1]:null;
if(_5bd){
if(_5be!==node){
_5bd.push(node);
}
}
_5bb.push(_5be===node?_5bd:[]);
this.nodeStack.push(node);
this.nodeStackOverrideType.push(_5ba);
};
_5b0.prototype.popNode=function(){
this.nodeStackOverrideType.pop();
this.nodePriorStack.pop();
return this.nodeStack.pop();
};
_5b0.prototype.currentNode=function(){
var _5bf=this.nodeStack;
return _5bf[_5bf.length-1];
};
_5b0.prototype.currentOverrideType=function(){
var _5c0=this.nodeStackOverrideType;
return _5c0[_5c0.length-1];
};
_5b0.prototype.priorNode=function(){
var _5c1=this.nodePriorStack,_5c2=_5c1.length;
if(_5c2>1){
var _5c3=_5c1[_5c2-2],l=_5c3.length;
return _5c3[l-2]||null;
}
return null;
};
_5b0.prototype.formatDescription=function(_5c4,_5c5,_5c6){
var _5c7=this.nodeStack,_5c8=_5c7.length;
_5c4=_5c4||0;
if(_5c4>=_5c8){
return null;
}
var i=_5c8-_5c4-1;
var _5c9=_5c7[i];
var _5ca=_5c5||this.compiler.formatDescription;
var _5cb=_5c5?_5c5.parent:_5ca;
var _5cc;
if(_5cb){
var _5cd=_5c6===_5c9?this.nodeStackOverrideType[i]:_5c9.type;
_5cc=_5cb[_5cd];
if(_5c6===_5c9&&!_5cc){
return null;
}
}
if(_5cc){
return this.formatDescription(_5c4+1,_5cc);
}else{
_5cc=this.formatDescription(_5c4+1,_5c5,_5c9);
if(_5cc){
return _5cc;
}else{
var _5ce=_5ca.prior;
if(_5ce){
var _5cf=this.priorNode(),_5d0=_5ce[_5cf?_5cf.type:"None"];
if(_5d0){
return _5d0;
}
}
return _5ca;
}
}
};
var _5d1=function(_5d2,node,code){
this.message=_5d3(_5d2,node,code);
this.node=node;
};
_5d1.prototype.checkIfWarning=function(st){
var _5d4=this.node.name;
return !st.getLvar(_5d4)&&typeof _1[_5d4]==="undefined"&&(typeof window==="undefined"||typeof window[_5d4]==="undefined")&&!st.compiler.getClassDef(_5d4);
};
_5d1.prototype.isEqualTo=function(_5d5){
if(this.message.message!==_5d5.message.message){
return false;
}
if(this.node.start!==_5d5.node.start){
return false;
}
if(this.node.end!==_5d5.node.end){
return false;
}
return true;
};
function _2f1(_5d6,file){
if(_5d6){
this.rootNode=new _5af.SourceNode();
this.concat=this.concatSourceNode;
this.toString=this.toStringSourceNode;
this.isEmpty=this.isEmptySourceNode;
this.appendStringBuffer=this.appendStringBufferSourceNode;
this.length=this.lengthSourceNode;
if(file){
this.file=file.toString();
}
}else{
this.atoms=[];
this.concat=this.concatString;
this.toString=this.toStringString;
this.isEmpty=this.isEmptyString;
this.appendStringBuffer=this.appendStringBufferString;
this.length=this.lengthString;
}
};
_2f1.prototype.toStringString=function(){
return this.atoms.join("");
};
_2f1.prototype.toStringSourceNode=function(){
return this.rootNode.toStringWithSourceMap({file:this.file});
};
_2f1.prototype.concatString=function(_5d7){
this.atoms.push(_5d7);
};
_2f1.prototype.concatSourceNode=function(_5d8,node){
if(node){
this.rootNode.add(new _5af.SourceNode(node.loc.start.line,node.loc.start.column,node.loc.source,_5d8));
}else{
this.rootNode.add(_5d8);
}
if(!this.notEmpty){
this.notEmpty=true;
}
};
_2f1.prototype.concatFormat=function(_5d9){
if(!_5d9){
return;
}
var _5da=_5d9.split("\n"),size=_5da.length;
if(size>1){
this.concat(_5da[0]);
for(var i=1;i<size;i++){
var line=_5da[i];
this.concat("\n");
if(line.slice(0,1)==="\\"){
var _5db=1;
var _5dc=line.slice(1,1+_5db);
if(_5dc==="-"){
_5db=2;
_5dc=line.slice(1,1+_5db);
}
var _5dd=parseInt(_5dc);
if(_5dd){
this.concat(_5dd>0?_5de+Array(_5dd*_5df+1).join(_5e0):_5de.substring(_5e1*-_5dd));
}
line=line.slice(1+_5db);
}else{
if(line||i===size-1){
this.concat(_5de);
}
}
if(line){
this.concat(line);
}
}
}else{
this.concat(_5d9);
}
};
_2f1.prototype.isEmptyString=function(){
return this.atoms.length!==0;
};
_2f1.prototype.isEmptySourceNode=function(){
return this.notEmpty;
};
_2f1.prototype.appendStringBufferString=function(_5e2){
this.atoms.push.apply(this.atoms,_5e2.atoms);
};
_2f1.prototype.appendStringBufferSourceNode=function(_5e3){
this.rootNode.add(_5e3.rootNode);
};
_2f1.prototype.lengthString=function(){
return this.atoms.length;
};
_2f1.prototype.lengthSourceNode=function(){
return this.rootNode.children.length;
};
var _5e4=function(_5e5,name,_5e6,_5e7,_5e8,_5e9,_5ea){
this.name=name;
if(_5e6){
this.superClass=_5e6;
}
if(_5e7){
this.ivars=_5e7;
}
if(_5e5){
this.instanceMethods=_5e8||Object.create(null);
this.classMethods=_5e9||Object.create(null);
}
if(_5ea){
this.protocols=_5ea;
}
};
_5e4.prototype.addInstanceMethod=function(_5eb){
this.instanceMethods[_5eb.name]=_5eb;
};
_5e4.prototype.addClassMethod=function(_5ec){
this.classMethods[_5ec.name]=_5ec;
};
_5e4.prototype.listOfNotImplementedMethodsForProtocols=function(_5ed){
var _5ee=[],_5ef=this.getInstanceMethods(),_5f0=this.getClassMethods();
for(var i=0,size=_5ed.length;i<size;i++){
var _5f1=_5ed[i],_5f2=_5f1.requiredInstanceMethods,_5f3=_5f1.requiredClassMethods,_5f4=_5f1.protocols;
if(_5f2){
for(var _5f5 in _5f2){
var _5f6=_5f2[_5f5];
if(!_5ef[_5f5]){
_5ee.push({"methodDef":_5f6,"protocolDef":_5f1});
}
}
}
if(_5f3){
for(var _5f5 in _5f3){
var _5f6=_5f3[_5f5];
if(!_5f0[_5f5]){
_5ee.push({"methodDef":_5f6,"protocolDef":_5f1});
}
}
}
if(_5f4){
_5ee=_5ee.concat(this.listOfNotImplementedMethodsForProtocols(_5f4));
}
}
return _5ee;
};
_5e4.prototype.getInstanceMethod=function(name){
var _5f7=this.instanceMethods;
if(_5f7){
var _5f8=_5f7[name];
if(_5f8){
return _5f8;
}
}
var _5f9=this.superClass;
if(_5f9){
return _5f9.getInstanceMethod(name);
}
return null;
};
_5e4.prototype.getClassMethod=function(name){
var _5fa=this.classMethods;
if(_5fa){
var _5fb=_5fa[name];
if(_5fb){
return _5fb;
}
}
var _5fc=this.superClass;
if(_5fc){
return _5fc.getClassMethod(name);
}
return null;
};
_5e4.prototype.getInstanceMethods=function(){
var _5fd=this.instanceMethods;
if(_5fd){
var _5fe=this.superClass,_5ff=Object.create(null);
if(_5fe){
var _600=_5fe.getInstanceMethods();
for(var _601 in _600){
_5ff[_601]=_600[_601];
}
}
for(var _601 in _5fd){
_5ff[_601]=_5fd[_601];
}
return _5ff;
}
return [];
};
_5e4.prototype.getClassMethods=function(){
var _602=this.classMethods;
if(_602){
var _603=this.superClass,_604=Object.create(null);
if(_603){
var _605=_603.getClassMethods();
for(var _606 in _605){
_604[_606]=_605[_606];
}
}
for(var _606 in _602){
_604[_606]=_602[_606];
}
return _604;
}
return [];
};
var _607=function(name,_608,_609,_60a){
this.name=name;
this.protocols=_608;
if(_609){
this.requiredInstanceMethods=_609;
}
if(_60a){
this.requiredClassMethods=_60a;
}
};
_607.prototype.addInstanceMethod=function(_60b){
(this.requiredInstanceMethods||(this.requiredInstanceMethods=Object.create(null)))[_60b.name]=_60b;
};
_607.prototype.addClassMethod=function(_60c){
(this.requiredClassMethods||(this.requiredClassMethods=Object.create(null)))[_60c.name]=_60c;
};
_607.prototype.getInstanceMethod=function(name){
var _60d=this.requiredInstanceMethods;
if(_60d){
var _60e=_60d[name];
if(_60e){
return _60e;
}
}
var _60f=this.protocols;
for(var i=0,size=_60f.length;i<size;i++){
var _610=_60f[i],_60e=_610.getInstanceMethod(name);
if(_60e){
return _60e;
}
}
return null;
};
_607.prototype.getClassMethod=function(name){
var _611=this.requiredClassMethods;
if(_611){
var _612=_611[name];
if(_612){
return _612;
}
}
var _613=this.protocols;
for(var i=0,size=_613.length;i<size;i++){
var _614=_613[i],_612=_614.getInstanceMethod(name);
if(_612){
return _612;
}
}
return null;
};
var _615=function(name){
this.name=name;
};
var _616=function(name,_617){
this.name=name;
this.types=_617;
};
var _618=_5ae.makePredicate("self _cmd undefined localStorage arguments");
var _619=_5ae.makePredicate("delete in instanceof new typeof void");
var _61a=_5ae.makePredicate("LogicalExpression BinaryExpression");
var _61b=_5ae.makePredicate("in instanceof");
var _61c={acornOptions:function(){
return Object.create(null);
},sourceMap:false,pass:2,classDefs:function(){
return Object.create(null);
},protocolDefs:function(){
return Object.create(null);
},typeDefs:function(){
return Object.create(null);
},generate:true,generateObjJ:false,formatDescription:null,indentationSpaces:4,indentationType:" ",includeComments:false,transformNamedFunctionDeclarationToAssignment:false,includeMethodFunctionNames:true,includeMethodArgumentTypeSignatures:true,includeIvarTypeSignatures:true,inlineMsgSendFunctions:true,};
function _61d(opts){
var _61e=Object.create(null);
for(var opt in _61c){
if(opts&&Object.prototype.hasOwnProperty.call(opts,opt)){
var _61f=opts[opt];
_61e[opt]=typeof _61f==="function"?_61f():_61f;
}else{
if(_61c.hasOwnProperty(opt)){
var _620=_61c[opt];
_61e[opt]=typeof _620==="function"?_620():_620;
}
}
}
return _61e;
};
var _621=function(_622,aURL,_623){
this.source=_622;
this.URL=aURL&&aURL.toString();
_623=_61d(_623);
this.options=_623;
this.pass=_623.pass;
this.classDefs=_623.classDefs;
this.protocolDefs=_623.protocolDefs;
this.typeDefs=_623.typeDefs;
this.generate=_623.generate;
this.createSourceMap=_623.sourceMap;
this.formatDescription=_623.formatDescription;
this.includeComments=_623.includeComments;
this.transformNamedFunctionDeclarationToAssignment=_623.transformNamedFunctionDeclarationToAssignment;
this.jsBuffer=new _2f1(this.createSourceMap,aURL);
this.imBuffer=null;
this.cmBuffer=null;
this.dependencies=[];
this.warningsAndErrors=[];
this.lastPos=0;
var _624=_623.acornOptions;
if(_624){
if(!_624.sourceFile&&this.URL){
_624.sourceFile=this.URL.substr(this.URL.lastIndexOf("/")+1);
}
if(_623.sourceMap&&!_624.locations){
_624.locations=true;
}
}else{
_624=_623.acornOptions=this.URL&&{sourceFile:this.URL.substr(this.URL.lastIndexOf("/")+1)};
if(_623.sourceMap){
_624.locations=true;
}
}
try{
this.tokens=_5ae.parse(_622,_623.acornOptions);
(this.pass===2&&(_623.includeComments||_623.formatDescription)?_625:_626)(this.tokens,new _5b0(null,{compiler:this}),this.pass===2?_627:_628);
}
catch(e){
if(e.lineStart!=null){
e.messageForLine=_622.substring(e.lineStart,e.lineEnd);
}
this.addWarning(e);
return;
}
this.setCompiledCode(this.jsBuffer);
};
_621.prototype.setCompiledCode=function(_629){
if(this.createSourceMap){
var s=_629.toString();
this.compiledCode=s.code;
this.sourceMap=s.map;
}else{
this.compiledCode=_629.toString();
}
};
_5ad.compileToExecutable=function(_62a,aURL,_62b){
_5ad.currentCompileFile=aURL;
return new _621(_62a,aURL,_62b).executable();
};
_5ad.compileToIMBuffer=function(_62c,aURL,_62d){
return new _621(_62c,aURL,_62d).IMBuffer();
};
_5ad.compile=function(_62e,aURL,_62f){
return new _621(_62e,aURL,_62f);
};
_5ad.compileFileDependencies=function(_630,aURL,_631){
_5ad.currentCompileFile=aURL;
(_631||(_631={})).pass=1;
return new _621(_630,aURL,_631);
};
_621.prototype.compilePass2=function(){
_5ad.currentCompileFile=this.URL;
this.pass=this.options.pass=2;
this.jsBuffer=new _2f1(this.createSourceMap,this.URL);
if(this.createSourceMap){
this.jsBuffer.concat("\n");
}
this.warningsAndErrors=[];
try{
_626(this.tokens,new _5b0(null,{compiler:this}),_627);
}
catch(e){
this.addWarning(e);
return null;
}
this.setCompiledCode(this.jsBuffer);
return this.compiledCode;
};
_621.prototype.addWarning=function(_632){
if(_632.path==null){
_632.path=this.URL;
}
this.warningsAndErrors.push(_632);
};
_621.prototype.getIvarForClass=function(_633,_634){
var ivar=_634.getIvarForCurrentClass(_633);
if(ivar){
return ivar;
}
var c=this.getClassDef(_634.currentClassName());
while(c){
var _635=c.ivars;
if(_635){
var _636=_635[_633];
if(_636){
return _636;
}
}
c=c.superClass;
}
};
_621.prototype.getClassDef=function(_637){
if(!_637){
return null;
}
var c=this.classDefs[_637];
if(c){
return c;
}
if(typeof objj_getClass==="function"){
var _638=objj_getClass(_637);
if(_638){
var _639=class_copyIvarList(_638),_63a=_639.length,_63b=Object.create(null),_63c=class_copyProtocolList(_638),_63d=_63c.length,_63e=Object.create(null),_63f=_621.methodDefsFromMethodList(class_copyMethodList(_638)),_640=_621.methodDefsFromMethodList(class_copyMethodList(_638.isa)),_641=class_getSuperclass(_638);
for(var i=0;i<_63a;i++){
var ivar=_639[i];
_63b[ivar.name]={"type":ivar.type,"name":ivar.name};
}
for(var i=0;i<_63d;i++){
var _642=_63c[i],_643=protocol_getName(_642),_644=this.getProtocolDef(_643);
_63e[_643]=_644;
}
c=new _5e4(true,_637,_641?this.getClassDef(_641.name):null,_63b,_63f,_640,_63e);
this.classDefs[_637]=c;
return c;
}
}
return null;
};
_621.prototype.getProtocolDef=function(_645){
if(!_645){
return null;
}
var p=this.protocolDefs[_645];
if(p){
return p;
}
if(typeof objj_getProtocol==="function"){
var _646=objj_getProtocol(_645);
if(_646){
var _647=protocol_getName(_646),_648=protocol_copyMethodDescriptionList(_646,true,true),_649=_621.methodDefsFromMethodList(_648),_64a=protocol_copyMethodDescriptionList(_646,true,false),_64b=_621.methodDefsFromMethodList(_64a),_64c=_646.protocols,_64d=[];
if(_64c){
for(var i=0,size=_64c.length;i<size;i++){
_64d.push(compiler.getProtocolDef(_64c[i].name));
}
}
p=new _607(_647,_64d,_649,_64b);
this.protocolDefs[_645]=p;
return p;
}
}
return null;
};
_621.prototype.getTypeDef=function(_64e){
if(!_64e){
return null;
}
var t=this.typeDefs[_64e];
if(t){
return t;
}
if(typeof objj_getTypeDef==="function"){
var _64f=objj_getTypeDef(_64e);
if(_64f){
var _650=typeDef_getName(_64f);
t=new _615(_650);
this.typeDefs[_650]=t;
return t;
}
}
return null;
};
_621.methodDefsFromMethodList=function(_651){
var _652=_651.length,_653=Object.create(null);
for(var i=0;i<_652;i++){
var _654=_651[i],_655=method_getName(_654);
_653[_655]=new _616(_655,_654.types);
}
return _653;
};
_621.prototype.executable=function(){
if(!this._executable){
this._executable=new _300(this.jsBuffer?this.jsBuffer.toString():null,this.dependencies,this.URL,null,this);
}
return this._executable;
};
_621.prototype.IMBuffer=function(){
return this.imBuffer;
};
_621.prototype.code=function(){
return this.compiledCode;
};
_621.prototype.ast=function(){
return JSON.stringify(this.tokens,null,_5df);
};
_621.prototype.map=function(){
return JSON.stringify(this.sourceMap);
};
_621.prototype.prettifyMessage=function(_656){
var line=_656.messageForLine,_657="\n"+line;
_657+=(new Array(_656.messageOnColumn+1)).join(" ");
_657+=(new Array(Math.min(1,line.length)+1)).join("^")+"\n";
_657+=_656.messageType+" line "+_656.messageOnLine+" in "+this.URL+": "+_656.message;
return _657;
};
_621.prototype.error_message=function(_658,node){
var pos=_5ae.getLineInfo(this.source,node.start),_659=new SyntaxError(_658);
_659.messageOnLine=pos.line;
_659.messageOnColumn=pos.column;
_659.path=this.URL;
_659.messageForNode=node;
_659.messageType="ERROR";
_659.messageForLine=this.source.substring(pos.lineStart,pos.lineEnd);
return _659;
};
_621.prototype.pushImport=function(url){
if(!_621.importStack){
_621.importStack=[];
}
_621.importStack.push(url);
};
_621.prototype.popImport=function(){
_621.importStack.pop();
};
function _5d3(_65a,node,code){
var _65b=_5ae.getLineInfo(code,node.start);
_65b.message=_65a;
_65b.messageOnLine=_65b.line;
_65b.messageOnColumn=_65b.column;
_65b.messageForNode=node;
_65b.messageType="WARNING";
_65b.messageForLine=code.substring(_65b.lineStart,_65b.lineEnd);
return _65b;
};
function _626(node,_65c,_65d){
function c(node,st,_65e){
_65d[_65e||node.type](node,st,c);
};
c(node,_65c);
};
function _625(node,_65f,_660){
var _661,_662;
function c(node,st,_663){
var _664=st.compiler,_665=_664.includeComments,_666=st.currentNode(),_667=_661,_668=_667===node;
_661=node;
if(_665&&!_668&&node.commentsBefore&&node.commentsBefore!==_662){
for(var i=0;i<node.commentsBefore.length;i++){
_664.jsBuffer.concat(node.commentsBefore[i]);
}
}
st.pushNode(node,_663);
var _669=st.formatDescription();
if(!_668&&_669&&_669.before){
_664.jsBuffer.concatFormat(_669.before);
}
_660[_663||node.type](node,st,c,_669);
if(!_668&&_669&&_669.after){
_664.jsBuffer.concatFormat(_669.after);
}
st.popNode();
if(_665&&!_668&&node.commentsAfter){
for(var i=0;i<node.commentsAfter.length;i++){
_664.jsBuffer.concat(node.commentsAfter[i]);
}
_662=node.commentsAfter;
}else{
_662=null;
}
};
c(node,_65f);
};
function _66a(node){
switch(node.type){
case "Literal":
case "Identifier":
return true;
case "ArrayExpression":
for(var i=0;i<node.elements.length;++i){
if(!_66a(node.elements[i])){
return false;
}
}
return true;
case "DictionaryLiteral":
for(var i=0;i<node.keys.length;++i){
if(!_66a(node.keys[i])){
return false;
}
if(!_66a(node.values[i])){
return false;
}
}
return true;
case "ObjectExpression":
for(var i=0;i<node.properties.length;++i){
if(!_66a(node.properties[i].value)){
return false;
}
}
return true;
case "FunctionExpression":
for(var i=0;i<node.params.length;++i){
if(!_66a(node.params[i])){
return false;
}
}
return true;
case "SequenceExpression":
for(var i=0;i<node.expressions.length;++i){
if(!_66a(node.expressions[i])){
return false;
}
}
return true;
case "UnaryExpression":
return _66a(node.argument);
case "BinaryExpression":
return _66a(node.left)&&_66a(node.right);
case "ConditionalExpression":
return _66a(node.test)&&_66a(node.consequent)&&_66a(node.alternate);
case "MemberExpression":
return _66a(node.object)&&(!node.computed||_66a(node.property));
case "Dereference":
return _66a(node.expr);
case "Reference":
return _66a(node.element);
default:
return false;
}
};
function _66b(st,node){
if(!_66a(node)){
throw st.compiler.error_message("Dereference of expression with side effects",node);
}
};
function _66c(c){
return function(node,st,_66d,_66e){
st.compiler.jsBuffer.concat("(");
c(node,st,_66d,_66e);
st.compiler.jsBuffer.concat(")");
};
};
var _66f={"*":3,"/":3,"%":3,"+":4,"-":4,"<<":5,">>":5,">>>":5,"<":6,"<=":6,">":6,">=":6,"in":6,"instanceof":6,"==":7,"!=":7,"===":7,"!==":7,"&":8,"^":9,"|":10,"&&":11,"||":12};
var _670={MemberExpression:0,CallExpression:1,NewExpression:2,FunctionExpression:3,UnaryExpression:4,UpdateExpression:4,BinaryExpression:5,LogicalExpression:6,ConditionalExpression:7,AssignmentExpression:8};
function _671(node,_672,_673){
var _674=node.type,_671=_670[_674]||-1,_675=_670[_672.type]||-1,_676,_677;
return _671<_675||(_671===_675&&_61a(_674)&&((_676=_66f[node.operator])<(_677=_66f[_672.operator])||(_673&&_676===_677)));
};
var _628=walk.make({ImportStatement:function(node,st,c){
var _678=node.filename.value;
st.compiler.dependencies.push({url:_678,isLocal:node.localfilepath});
}});
var _5e0=" ";
var _5df=4;
var _5e1=_5df*_5e0.length;
var _679=Array(_5df+1).join(_5e0);
var _5de="";
var _627=walk.make({Program:function(node,st,c){
var _67a=st.compiler,_67b=_67a.generate;
_5e0=_67a.options.indentationType;
_5df=_67a.options.indentationSpaces;
_5e1=_5df*_5e0.length;
_679=Array(_5df+1).join(_5e0);
_5de="";
for(var i=0;i<node.body.length;++i){
c(node.body[i],st,"Statement");
}
if(!_67b){
_67a.jsBuffer.concat(_67a.source.substring(_67a.lastPos,node.end));
}
var _67c=st.maybeWarnings();
if(_67c){
for(var i=0;i<_67c.length;i++){
var _67d=_67c[i];
if(_67d.checkIfWarning(st)){
_67a.addWarning(_67d.message);
}
}
}
},BlockStatement:function(node,st,c,_67e){
var _67f=st.compiler,_680=_67f.generate,_681=st.endOfScopeBody,_682;
if(_681){
delete st.endOfScopeBody;
}
if(_680){
var _683=st.skipIndentation;
_682=_67f.jsBuffer;
if(_67e){
_682.concat("{",node);
_682.concatFormat(_67e.afterLeftBrace);
}else{
if(_683){
delete st.skipIndentation;
}else{
_682.concat(_5de.substring(_5e1));
}
_682.concat("{\n",node);
}
}
for(var i=0;i<node.body.length;++i){
c(node.body[i],st,"Statement");
}
if(_680){
var _684=st.maxReceiverLevel;
if(_681&&_684){
_682.concat(_5de);
_682.concat("var ");
for(var i=0;i<_684;i++){
if(i){
_682.concat(", ");
}
_682.concat("___r");
_682.concat((i+1)+"");
}
_682.concat(";\n");
}
var _685=node.loc&&{loc:{start:{line:node.loc.end.line,column:node.loc.end.column-1}},source:node.loc.source};
if(_67e){
_682.concatFormat(_67e.beforeRightBrace);
_682.concat("}",_685);
}else{
_682.concat(_5de.substring(_5e1));
_682.concat("}",_685);
if(!_683&&st.isDecl!==false){
_682.concat("\n");
}
st.indentBlockLevel--;
}
}
},ExpressionStatement:function(node,st,c,_686){
var _687=st.compiler,_688=_687.generate&&!_686;
if(_688){
_687.jsBuffer.concat(_5de);
}
c(node.expression,st,"Expression");
if(_688){
_687.jsBuffer.concat(";\n");
}
},IfStatement:function(node,st,c,_689){
var _68a=st.compiler,_68b=_68a.generate,_68c;
if(_68b){
_68c=_68a.jsBuffer;
if(_689){
_68c.concat("if",node);
_68c.concatFormat(_689.beforeLeftParenthesis);
_68c.concat("(");
}else{
if(!st.superNodeIsElse){
_68c.concat(_5de);
}else{
delete st.superNodeIsElse;
}
_68c.concat("if (",node);
}
}
c(node.test,st,"Expression");
if(_68b){
if(_689){
_68c.concat(")");
_68c.concatFormat(_689.afterRightParenthesis);
}else{
_68c.concat(node.consequent.type==="EmptyStatement"?");\n":")\n");
}
}
_5de+=_679;
c(node.consequent,st,"Statement");
_5de=_5de.substring(_5e1);
var _68d=node.alternate;
if(_68d){
var _68e=_68d.type!=="IfStatement";
if(_68b){
if(_689){
_68c.concatFormat(_689.beforeElse);
_68c.concat("else");
_68c.concatFormat(_689.afterElse);
}else{
var _68f=_68d.type==="EmptyStatement";
_68c.concat(_5de);
_68c.concat(_68e?_68f?"else;\n":"else\n":"else ");
}
}
if(_68e){
_5de+=_679;
}else{
st.superNodeIsElse=true;
}
c(_68d,st,"Statement");
if(_68e){
_5de=_5de.substring(_5e1);
}
}
},LabeledStatement:function(node,st,c,_690){
var _691=st.compiler;
if(_691.generate){
var _692=_691.jsBuffer;
if(!_690){
_692.concat(_5de);
}
c(node.label,st,"IdentifierName");
if(_690){
_692.concat(":");
_692.concatFormat(_690.afterColon);
}else{
_692.concat(": ");
}
}
c(node.body,st,"Statement");
},BreakStatement:function(node,st,c,_693){
var _694=st.compiler;
if(_694.generate){
var _695=node.label,_696=_694.jsBuffer;
if(!_693){
_696.concat(_5de);
}
if(_695){
if(_693){
_696.concat("break",node);
_696.concatFormat(_693.beforeLabel);
}else{
_696.concat("break ",node);
}
c(_695,st,"IdentifierName");
if(!_693){
_696.concat(";\n");
}
}else{
_696.concat(_693?"break":"break;\n",node);
}
}
},ContinueStatement:function(node,st,c,_697){
var _698=st.compiler;
if(_698.generate){
var _699=node.label,_69a=_698.jsBuffer;
if(!_697){
_69a.concat(_5de);
}
if(_699){
if(_697){
_69a.concat("continue",node);
_69a.concatFormat(_697.beforeLabel);
}else{
_69a.concat("continue ",node);
}
c(_699,st,"IdentifierName");
if(!_697){
_69a.concat(";\n");
}
}else{
_69a.concat(_697?"continue":"continue;\n",node);
}
}
},WithStatement:function(node,st,c,_69b){
var _69c=st.compiler,_69d=_69c.generate,_69e;
if(_69d){
_69e=_69c.jsBuffer;
if(_69b){
_69e.concat("with",node);
_69e.concatFormat(_69b.beforeLeftParenthesis);
_69e.concat("(");
}else{
_69e.concat(_5de);
_69e.concat("with(",node);
}
}
c(node.object,st,"Expression");
if(_69d){
if(_69b){
_69e.concat(")");
_69e.concatFormat(_69b.afterRightParenthesis);
}else{
_69e.concat(")\n");
}
}
_5de+=_679;
c(node.body,st,"Statement");
_5de=_5de.substring(_5e1);
},SwitchStatement:function(node,st,c,_69f){
var _6a0=st.compiler,_6a1=_6a0.generate,_6a2;
if(_6a1){
_6a2=_6a0.jsBuffer;
if(_69f){
_6a2.concat("switch",node);
_6a2.concatFormat(_69f.beforeLeftParenthesis);
_6a2.concat("(",node);
}else{
_6a2.concat(_5de);
_6a2.concat("switch(",node);
}
}
c(node.discriminant,st,"Expression");
if(_6a1){
if(_69f){
_6a2.concat(")");
_6a2.concatFormat(_69f.afterRightParenthesis);
_6a2.concat("{");
_6a2.concatFormat(_69f.afterLeftBrace);
}else{
_6a2.concat(") {\n");
}
}
_5de+=_679;
for(var i=0;i<node.cases.length;++i){
var cs=node.cases[i];
if(cs.test){
if(_6a1){
if(_69f){
_6a2.concatFormat(_69f.beforeCase);
_6a2.concat("case",node);
_6a2.concatFormat(_69f.afterCase);
}else{
_6a2.concat(_5de);
_6a2.concat("case ");
}
}
c(cs.test,st,"Expression");
if(_6a1){
if(_69f){
_6a2.concat(":");
_6a2.concatFormat(_69f.afterColon);
}else{
_6a2.concat(":\n");
}
}
}else{
if(_6a1){
if(_69f){
_6a2.concatFormat(_69f.beforeCase);
_6a2.concat("default");
_6a2.concatFormat(_69f.afterCase);
_6a2.concat(":");
_6a2.concatFormat(_69f.afterColon);
}else{
_6a2.concat("default:\n");
}
}
}
_5de+=_679;
for(var j=0;j<cs.consequent.length;++j){
c(cs.consequent[j],st,"Statement");
}
_5de=_5de.substring(_5e1);
}
_5de=_5de.substring(_5e1);
if(_6a1){
if(_69f){
_6a2.concatFormat(_69f.beforeRightBrace);
_6a2.concat("}");
}else{
_6a2.concat(_5de);
_6a2.concat("}\n");
}
}
},ReturnStatement:function(node,st,c,_6a3){
var _6a4=st.compiler,_6a5=_6a4.generate,_6a6;
if(_6a5){
_6a6=_6a4.jsBuffer;
if(!_6a3){
_6a6.concat(_5de);
}
_6a6.concat("return",node);
}
if(node.argument){
if(_6a5){
_6a6.concatFormat(_6a3?_6a3.beforeExpression:" ");
}
c(node.argument,st,"Expression");
}
if(_6a5&&!_6a3){
_6a6.concat(";\n");
}
},ThrowStatement:function(node,st,c,_6a7){
var _6a8=st.compiler,_6a9=_6a8.generate,_6aa;
if(_6a9){
_6aa=_6a8.jsBuffer;
if(!_6a7){
_6aa.concat(_5de);
}
_6aa.concat("throw",node);
_6aa.concatFormat(_6a7?_6a7.beforeExpression:" ");
}
c(node.argument,st,"Expression");
if(_6a9&&!_6a7){
_6aa.concat(";\n");
}
},TryStatement:function(node,st,c,_6ab){
var _6ac=st.compiler,_6ad=_6ac.generate,_6ae;
if(_6ad){
_6ae=_6ac.jsBuffer;
if(!_6ab){
_6ae.concat(_5de);
}
_6ae.concat("try",node);
_6ae.concatFormat(_6ab?_6ab.beforeStatement:" ");
}
_5de+=_679;
if(!_6ab){
st.skipIndentation=true;
}
c(node.block,st,"Statement");
_5de=_5de.substring(_5e1);
if(node.handler){
var _6af=node.handler,_6b0=new _5b0(st),_6b1=_6af.param,name=_6b1.name;
_6b0.vars[name]={type:"catch clause",node:_6b1};
if(_6ad){
if(_6ab){
_6ae.concatFormat(_6ab.beforeCatch);
_6ae.concat("catch");
_6ae.concatFormat(_6ab.afterCatch);
_6ae.concat("(");
c(_6b1,st,"IdentifierName");
_6ae.concat(")");
_6ae.concatFormat(_6ab.beforeCatchStatement);
}else{
_6ae.concat("\n");
_6ae.concat(_5de);
_6ae.concat("catch(");
_6ae.concat(name);
_6ae.concat(") ");
}
}
_5de+=_679;
_6b0.skipIndentation=true;
_6b0.endOfScopeBody=true;
c(_6af.body,_6b0,"ScopeBody");
_5de=_5de.substring(_5e1);
_6b0.copyAddedSelfToIvarsToParent();
}
if(node.finalizer){
if(_6ad){
if(_6ab){
_6ae.concatFormat(_6ab.beforeCatch);
_6ae.concat("finally");
_6ae.concatFormat(_6ab.beforeCatchStatement);
}else{
_6ae.concat("\n");
_6ae.concat(_5de);
_6ae.concat("finally ");
}
}
_5de+=_679;
st.skipIndentation=true;
c(node.finalizer,st,"Statement");
_5de=_5de.substring(_5e1);
}
if(_6ad&&!_6ab){
_6ae.concat("\n");
}
},WhileStatement:function(node,st,c,_6b2){
var _6b3=st.compiler,_6b4=_6b3.generate,body=node.body,_6b5;
if(_6b4){
_6b5=_6b3.jsBuffer;
if(_6b2){
_6b5.concat("while",node);
_6b5.concatFormat(_6b2.beforeLeftParenthesis);
_6b5.concat("(");
}else{
_6b5.concat(_5de);
_6b5.concat("while (",node);
}
}
c(node.test,st,"Expression");
if(_6b4){
if(_6b2){
_6b5.concat(")");
_6b5.concatFormat(_6b2.afterRightParenthesis);
}else{
_6b5.concat(body.type==="EmptyStatement"?");\n":")\n");
}
}
_5de+=_679;
c(body,st,"Statement");
_5de=_5de.substring(_5e1);
},DoWhileStatement:function(node,st,c,_6b6){
var _6b7=st.compiler,_6b8=_6b7.generate,_6b9;
if(_6b8){
_6b9=_6b7.jsBuffer;
if(_6b6){
_6b9.concat("do",node);
_6b9.concatFormat(_6b6.beforeStatement);
}else{
_6b9.concat(_5de);
_6b9.concat("do\n",node);
}
}
_5de+=_679;
c(node.body,st,"Statement");
_5de=_5de.substring(_5e1);
if(_6b8){
if(_6b6){
_6b9.concat("while");
_6b9.concatFormat(_6b6.beforeLeftParenthesis);
_6b9.concat("(");
}else{
_6b9.concat(_5de);
_6b9.concat("while (");
}
}
c(node.test,st,"Expression");
if(_6b8){
_6b9.concatFormat(_6b6?")":");\n");
}
},ForStatement:function(node,st,c,_6ba){
var _6bb=st.compiler,_6bc=_6bb.generate,body=node.body,_6bd;
if(_6bc){
_6bd=_6bb.jsBuffer;
if(_6ba){
_6bd.concat("for",node);
_6bd.concatFormat(_6ba.beforeLeftParenthesis);
_6bd.concat("(");
}else{
_6bd.concat(_5de);
_6bd.concat("for (",node);
}
}
if(node.init){
c(node.init,st,"ForInit");
}
if(_6bc){
_6bd.concat(_6ba?";":"; ");
}
if(node.test){
c(node.test,st,"Expression");
}
if(_6bc){
_6bd.concat(_6ba?";":"; ");
}
if(node.update){
c(node.update,st,"Expression");
}
if(_6bc){
if(_6ba){
_6bd.concat(")");
_6bd.concatFormat(_6ba.afterRightParenthesis);
}else{
_6bd.concat(body.type==="EmptyStatement"?");\n":")\n");
}
}
_5de+=_679;
c(body,st,"Statement");
_5de=_5de.substring(_5e1);
},ForInStatement:function(node,st,c,_6be){
var _6bf=st.compiler,_6c0=_6bf.generate,body=node.body,_6c1;
if(_6c0){
_6c1=_6bf.jsBuffer;
if(_6be){
_6c1.concat("for",node);
_6c1.concatFormat(_6be.beforeLeftParenthesis);
_6c1.concat("(");
}else{
_6c1.concat(_5de);
_6c1.concat("for (",node);
}
}
c(node.left,st,"ForInit");
if(_6c0){
if(_6be){
_6c1.concatFormat(_6be.beforeIn);
_6c1.concat("in");
_6c1.concatFormat(_6be.afterIn);
}else{
_6c1.concat(" in ");
}
}
c(node.right,st,"Expression");
if(_6c0){
if(_6be){
_6c1.concat(")");
_6c1.concatFormat(_6be.afterRightParenthesis);
}else{
_6c1.concat(body.type==="EmptyStatement"?");\n":")\n");
}
}
_5de+=_679;
c(body,st,"Statement");
_5de=_5de.substring(_5e1);
},ForInit:function(node,st,c){
var _6c2=st.compiler,_6c3=_6c2.generate;
if(node.type==="VariableDeclaration"){
st.isFor=true;
c(node,st);
delete st.isFor;
}else{
c(node,st,"Expression");
}
},DebuggerStatement:function(node,st,c,_6c4){
var _6c5=st.compiler;
if(_6c5.generate){
var _6c6=_6c5.jsBuffer;
if(_6c4){
_6c6.concat("debugger",node);
}else{
_6c6.concat(_5de);
_6c6.concat("debugger;\n",node);
}
}
},Function:function(node,st,c,_6c7){
var _6c8=st.compiler,_6c9=_6c8.generate,_6ca=_6c8.jsBuffer,_6cb=new _5b0(st),decl=node.type=="FunctionDeclaration",id=node.id;
_6cb.isDecl=decl;
for(var i=0;i<node.params.length;++i){
_6cb.vars[node.params[i].name]={type:"argument",node:node.params[i]};
}
if(_6c9&&!_6c7){
_6ca.concat(_5de);
}
if(id){
var name=id.name;
(decl?st:_6cb).vars[name]={type:decl?"function":"function name",node:id};
if(_6c8.transformNamedFunctionDeclarationToAssignment){
if(_6c9){
_6ca.concat(name);
_6ca.concat(" = ");
}else{
_6ca.concat(_6c8.source.substring(_6c8.lastPos,node.start));
_6ca.concat(name);
_6ca.concat(" = function");
_6c8.lastPos=id.end;
}
}
}
if(_6c9){
_6ca.concat("function",node);
if(!_6c8.transformNamedFunctionDeclarationToAssignment&&id){
if(!_6c7){
_6ca.concat(" ");
}
c(id,st,"IdentifierName");
}
if(_6c7){
_6ca.concatFormat(_6c7.beforeLeftParenthesis);
}
_6ca.concat("(");
for(var i=0;i<node.params.length;++i){
if(i){
_6ca.concat(_6c7?",":", ");
}
c(node.params[i],st,"IdentifierName");
}
if(_6c7){
_6ca.concat(")");
_6ca.concatFormat(_6c7.afterRightParenthesis);
}else{
_6ca.concat(")\n");
}
}
_5de+=_679;
_6cb.endOfScopeBody=true;
c(node.body,_6cb,"ScopeBody");
_5de=_5de.substring(_5e1);
_6cb.copyAddedSelfToIvarsToParent();
},VariableDeclaration:function(node,st,c,_6cc){
var _6cd=st.compiler,_6ce=_6cd.generate,_6cf;
if(_6ce){
_6cf=_6cd.jsBuffer;
if(!st.isFor&&!_6cc){
_6cf.concat(_5de);
}
_6cf.concat(_6cc?"var":"var ",node);
}
for(var i=0;i<node.declarations.length;++i){
var decl=node.declarations[i],_6d0=decl.id.name;
if(i){
if(_6ce){
if(_6cc){
_6cf.concat(",");
}else{
if(st.isFor){
_6cf.concat(", ");
}else{
_6cf.concat(",\n");
_6cf.concat(_5de);
_6cf.concat("    ");
}
}
}
}
st.vars[_6d0]={type:"var",node:decl.id};
c(decl.id,st,"IdentifierName");
if(decl.init){
if(_6ce){
if(_6cc){
_6cf.concatFormat(_6cc.beforeEqual);
_6cf.concat("=");
_6cf.concatFormat(_6cc.afterEqual);
}else{
_6cf.concat(" = ");
}
}
c(decl.init,st,"Expression");
}
if(st.addedSelfToIvars){
var _6d1=st.addedSelfToIvars[_6d0];
if(_6d1){
var _6d2=st.compiler.jsBuffer.atoms;
for(var i=0,size=_6d1.length;i<size;i++){
var dict=_6d1[i];
_6d2[dict.index]="";
_6cd.addWarning(_5d3("Local declaration of '"+_6d0+"' hides instance variable",dict.node,_6cd.source));
}
st.addedSelfToIvars[_6d0]=[];
}
}
}
if(_6ce&&!_6cc&&!st.isFor){
_6cf.concat(";\n");
}
},ThisExpression:function(node,st,c){
var _6d3=st.compiler;
if(_6d3.generate){
_6d3.jsBuffer.concat("this",node);
}
},ArrayExpression:function(node,st,c,_6d4){
var _6d5=st.compiler,_6d6=_6d5.generate,_6d7;
if(_6d6){
_6d7=_6d5.jsBuffer;
_6d7.concat("[",node);
}
for(var i=0;i<node.elements.length;++i){
var elt=node.elements[i];
if(_6d6&&i!==0){
if(_6d4){
_6d7.concatFormat(_6d4.beforeComma);
_6d7.concat(",");
_6d7.concatFormat(_6d4.afterComma);
}else{
_6d7.concat(", ");
}
}
if(elt){
c(elt,st,"Expression");
}
}
if(_6d6){
_6d7.concat("]");
}
},ObjectExpression:function(node,st,c,_6d8){
var _6d9=st.compiler,_6da=_6d9.generate,_6db=node.properties,_6dc=_6d9.jsBuffer;
if(_6da){
_6dc.concat("{",node);
}
for(var i=0,size=_6db.length;i<size;++i){
var prop=_6db[i];
if(_6da){
if(i){
if(_6d8){
_6dc.concatFormat(_6d8.beforeComma);
_6dc.concat(",");
_6dc.concatFormat(_6d8.afterComma);
}else{
_6dc.concat(", ");
}
}
st.isPropertyKey=true;
c(prop.key,st,"Expression");
delete st.isPropertyKey;
if(_6d8){
_6dc.concatFormat(_6d8.beforeColon);
_6dc.concat(":");
_6dc.concatFormat(_6d8.afterColon);
}else{
_6dc.concat(": ");
}
}else{
if(prop.key.raw&&prop.key.raw.charAt(0)==="@"){
_6dc.concat(_6d9.source.substring(_6d9.lastPos,prop.key.start));
_6d9.lastPos=prop.key.start+1;
}
}
c(prop.value,st,"Expression");
}
if(_6da){
_6dc.concat("}");
}
},SequenceExpression:function(node,st,c,_6dd){
var _6de=st.compiler,_6df=_6de.generate,_6e0;
if(_6df){
_6e0=_6de.jsBuffer;
_6e0.concat("(");
}
for(var i=0;i<node.expressions.length;++i){
if(_6df&&i!==0){
if(_6dd){
_6e0.concatFormat(_6dd.beforeComma);
_6e0.concat(",");
_6e0.concatFormat(_6dd.afterComma);
}else{
_6e0.concat(", ");
}
}
c(node.expressions[i],st,"Expression");
}
if(_6df){
_6e0.concat(")");
}
},UnaryExpression:function(node,st,c){
var _6e1=st.compiler,_6e2=_6e1.generate,_6e3=node.argument;
if(_6e2){
var _6e4=_6e1.jsBuffer;
if(node.prefix){
_6e4.concat(node.operator,node);
if(_619(node.operator)){
_6e4.concat(" ");
}
(_671(node,_6e3)?_66c(c):c)(_6e3,st,"Expression");
}else{
(_671(node,_6e3)?_66c(c):c)(_6e3,st,"Expression");
_6e4.concat(node.operator);
}
}else{
c(_6e3,st,"Expression");
}
},UpdateExpression:function(node,st,c){
var _6e5=st.compiler,_6e6=_6e5.generate,_6e7=_6e5.jsBuffer;
if(node.argument.type==="Dereference"){
_66b(st,node.argument);
if(!_6e6){
_6e7.concat(_6e5.source.substring(_6e5.lastPos,node.start));
}
_6e7.concat((node.prefix?"":"(")+"(");
if(!_6e6){
_6e5.lastPos=node.argument.expr.start;
}
c(node.argument.expr,st,"Expression");
if(!_6e6){
_6e7.concat(_6e5.source.substring(_6e5.lastPos,node.argument.expr.end));
}
_6e7.concat(")(");
if(!_6e6){
_6e5.lastPos=node.argument.start;
}
c(node.argument,st,"Expression");
if(!_6e6){
_6e7.concat(_6e5.source.substring(_6e5.lastPos,node.argument.end));
}
_6e7.concat(" "+node.operator.substring(0,1)+" 1)"+(node.prefix?"":node.operator=="++"?" - 1)":" + 1)"));
if(!_6e6){
_6e5.lastPos=node.end;
}
return;
}
if(node.prefix){
if(_6e6){
_6e7.concat(node.operator,node);
if(_619(node.operator)){
_6e7.concat(" ");
}
}
(_6e6&&_671(node,node.argument)?_66c(c):c)(node.argument,st,"Expression");
}else{
(_6e6&&_671(node,node.argument)?_66c(c):c)(node.argument,st,"Expression");
if(_6e6){
_6e7.concat(node.operator);
}
}
},BinaryExpression:function(node,st,c,_6e8){
var _6e9=st.compiler,_6ea=_6e9.generate,_6eb=_61b(node.operator);
(_6ea&&_671(node,node.left)?_66c(c):c)(node.left,st,"Expression");
if(_6ea){
var _6ec=_6e9.jsBuffer;
_6ec.concatFormat(_6e8?_6e8.beforeOperator:" ");
_6ec.concat(node.operator);
_6ec.concatFormat(_6e8?_6e8.afterOperator:" ");
}
(_6ea&&_671(node,node.right,true)?_66c(c):c)(node.right,st,"Expression");
},LogicalExpression:function(node,st,c,_6ed){
var _6ee=st.compiler,_6ef=_6ee.generate;
(_6ef&&_671(node,node.left)?_66c(c):c)(node.left,st,"Expression");
if(_6ef){
var _6f0=_6ee.jsBuffer;
_6f0.concatFormat(_6ed?_6ed.beforeOperator:" ");
_6f0.concat(node.operator);
_6f0.concatFormat(_6ed?_6ed.afterOperator:" ");
}
(_6ef&&_671(node,node.right,true)?_66c(c):c)(node.right,st,"Expression");
},AssignmentExpression:function(node,st,c,_6f1){
var _6f2=st.compiler,_6f3=_6f2.generate,_6f4=st.assignment,_6f5=_6f2.jsBuffer;
if(node.left.type==="Dereference"){
_66b(st,node.left);
if(!_6f3){
_6f5.concat(_6f2.source.substring(_6f2.lastPos,node.start));
}
_6f5.concat("(");
if(!_6f3){
_6f2.lastPos=node.left.expr.start;
}
c(node.left.expr,st,"Expression");
if(!_6f3){
_6f5.concat(_6f2.source.substring(_6f2.lastPos,node.left.expr.end));
}
_6f5.concat(")(");
if(node.operator!=="="){
if(!_6f3){
_6f2.lastPos=node.left.start;
}
c(node.left,st,"Expression");
if(!_6f3){
_6f5.concat(_6f2.source.substring(_6f2.lastPos,node.left.end));
}
_6f5.concat(" "+node.operator.substring(0,1)+" ");
}
if(!_6f3){
_6f2.lastPos=node.right.start;
}
c(node.right,st,"Expression");
if(!_6f3){
_6f5.concat(_6f2.source.substring(_6f2.lastPos,node.right.end));
}
_6f5.concat(")");
if(!_6f3){
_6f2.lastPos=node.end;
}
return;
}
var _6f4=st.assignment,_6f6=node.left;
st.assignment=true;
if(_6f6.type==="Identifier"&&_6f6.name==="self"){
var lVar=st.getLvar("self",true);
if(lVar){
var _6f7=lVar.scope;
if(_6f7){
_6f7.assignmentToSelf=true;
}
}
}
(_6f3&&_671(node,_6f6)?_66c(c):c)(_6f6,st,"Expression");
if(_6f3){
_6f5.concatFormat(_6f1?_6f1.beforeOperator:" ");
_6f5.concat(node.operator);
_6f5.concatFormat(_6f1?_6f1.afterOperator:" ");
}
st.assignment=_6f4;
(_6f3&&_671(node,node.right,true)?_66c(c):c)(node.right,st,"Expression");
if(st.isRootScope()&&_6f6.type==="Identifier"&&!st.getLvar(_6f6.name)){
st.vars[_6f6.name]={type:"global",node:_6f6};
}
},ConditionalExpression:function(node,st,c,_6f8){
var _6f9=st.compiler,_6fa=_6f9.generate,_6fb;
(_6fa&&_671(node,node.test)?_66c(c):c)(node.test,st,"Expression");
if(_6fa){
_6fb=_6f9.jsBuffer;
if(_6f8){
_6fb.concatFormat(_6f8.beforeOperator);
_6fb.concat("?");
_6fb.concatFormat(_6f8.afterOperator);
}else{
_6fb.concat(" ? ");
}
}
c(node.consequent,st,"Expression");
if(_6fa){
if(_6f8){
_6fb.concatFormat(_6f8.beforeOperator);
_6fb.concat(":");
_6fb.concatFormat(_6f8.afterOperator);
}else{
_6fb.concat(" : ");
}
}
c(node.alternate,st,"Expression");
},NewExpression:function(node,st,c,_6fc){
var _6fd=st.compiler,_6fe=node.arguments,_6ff=_6fd.generate,_700;
if(_6ff){
_700=_6fd.jsBuffer;
_700.concat("new ",node);
}
(_6ff&&_671(node,node.callee)?_66c(c):c)(node.callee,st,"Expression");
if(_6ff){
_700.concat("(");
}
if(_6fe){
for(var i=0,size=_6fe.length;i<size;++i){
if(i&&_6ff){
_700.concatFormat(_6fc?",":", ");
}
c(_6fe[i],st,"Expression");
}
}
if(_6ff){
_700.concat(")");
}
},CallExpression:function(node,st,c,_701){
var _702=st.compiler,_703=node.arguments,_704=_702.generate,_705=node.callee,_706;
if(_705.type==="Identifier"&&_705.name==="eval"){
var _707=st.getLvar("self",true);
if(_707){
var _708=_707.scope;
if(_708){
_708.assignmentToSelf=true;
}
}
}
(_704&&_671(node,_705)?_66c(c):c)(_705,st,"Expression");
if(_704){
_706=_702.jsBuffer;
_706.concat("(");
}
if(_703){
for(var i=0,size=_703.length;i<size;++i){
if(i&&_704){
_706.concat(_701?",":", ");
}
c(_703[i],st,"Expression");
}
}
if(_704){
_706.concat(")");
}
},MemberExpression:function(node,st,c){
var _709=st.compiler,_70a=_709.generate,_70b=node.computed;
(_70a&&_671(node,node.object)?_66c(c):c)(node.object,st,"Expression");
if(_70a){
_709.jsBuffer.concat(_70b?"[":".",node);
}
st.secondMemberExpression=!_70b;
(_70a&&!_70b&&_671(node,node.property)?_66c(c):c)(node.property,st,"Expression");
st.secondMemberExpression=false;
if(_70a&&_70b){
_709.jsBuffer.concat("]");
}
},Identifier:function(node,st,c){
var _70c=st.compiler,_70d=_70c.generate,_70e=node.name;
if(st.currentMethodType()==="-"&&!st.secondMemberExpression&&!st.isPropertyKey){
var lvar=st.getLvar(_70e,true),ivar=_70c.getIvarForClass(_70e,st);
if(ivar){
if(lvar){
_70c.addWarning(_5d3("Local declaration of '"+_70e+"' hides instance variable",node,_70c.source));
}else{
var _70f=node.start;
if(!_70d){
do{
_70c.jsBuffer.concat(_70c.source.substring(_70c.lastPos,_70f));
_70c.lastPos=_70f;
}while(_70c.source.substr(_70f++,1)==="(");
}
((st.addedSelfToIvars||(st.addedSelfToIvars=Object.create(null)))[_70e]||(st.addedSelfToIvars[_70e]=[])).push({node:node,index:_70c.jsBuffer.length()});
_70c.jsBuffer.concat("self.",node);
}
}else{
if(!_618(_70e)){
var _710,_711=typeof _1[_70e]!=="undefined"||(typeof window!=="undefined"&&typeof window[_70e]!=="undefined")||_70c.getClassDef(_70e),_712=st.getLvar(_70e);
if(_711&&(!_712||_712.type!=="class")){
}else{
if(!_712){
if(st.assignment){
_710=new _5d1("Creating global variable inside function or method '"+_70e+"'",node,_70c.source);
st.vars[_70e]={type:"remove global warning",node:node};
}else{
_710=new _5d1("Using unknown class or uninitialized global variable '"+_70e+"'",node,_70c.source);
}
}
}
if(_710){
st.addMaybeWarning(_710);
}
}
}
}
if(_70d){
_70c.jsBuffer.concat(_70e,node);
}
},IdentifierName:function(node,st,c){
var _713=st.compiler;
if(_713.generate){
_713.jsBuffer.concat(node.name,node);
}
},Literal:function(node,st,c){
var _714=st.compiler,_715=_714.generate;
if(_715){
if(node.raw){
if(node.raw.charAt(0)==="@"){
_714.jsBuffer.concat(node.raw.substring(1),node);
}else{
_714.jsBuffer.concat(node.raw,node);
}
}else{
var _716=node.value,_717=_716.indexOf("\"")!==-1;
_714.jsBuffer.concat(_717?"'":"\"",node);
_714.jsBuffer.concat(_716);
_714.jsBuffer.concat(_717?"'":"\"");
}
}else{
if(node.raw.charAt(0)==="@"){
_714.jsBuffer.concat(_714.source.substring(_714.lastPos,node.start));
_714.lastPos=node.start+1;
}
}
},ArrayLiteral:function(node,st,c){
var _718=st.compiler,_719=_718.generate,_71a=_718.jsBuffer,_71b=_718.options.generateObjJ,_71c=node.elements.length;
if(!_719){
_71a.concat(_718.source.substring(_718.lastPos,node.start));
_718.lastPos=node.start;
}
if(!_719){
_71a.concat(" ");
}
if(!st.receiverLevel){
st.receiverLevel=0;
}
if(_71b){
_71a.concat("@[");
}else{
if(!_71c){
if(_718.options.inlineMsgSendFunctions){
_71a.concat("(___r");
_71a.concat(++st.receiverLevel+"");
_71a.concat(" = (CPArray.isa.method_msgSend[\"alloc\"] || _objj_forward)(CPArray, \"alloc\"), ___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(" == null ? null : (___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(".isa.method_msgSend[\"init\"] || _objj_forward)(___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(", \"init\"))");
}else{
_71a.concat("(___r");
_71a.concat(++st.receiverLevel+"");
_71a.concat(" = CPArray.isa.objj_msgSend0(CPArray, \"alloc\"), ___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(" == null ? null : ___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(".isa.objj_msgSend0(___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(", \"init\"))");
}
if(!(st.maxReceiverLevel>=st.receiverLevel)){
st.maxReceiverLevel=st.receiverLevel;
}
}else{
if(_718.options.inlineMsgSendFunctions){
_71a.concat("(___r");
_71a.concat(++st.receiverLevel+"");
_71a.concat(" = (CPArray.isa.method_msgSend[\"alloc\"] || _objj_forward)(CPArray, \"alloc\"), ___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(" == null ? null : (___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(".isa.method_msgSend[\"initWithObjects:count:\"] || _objj_forward)(___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(", \"initWithObjects:count:\", [");
}else{
_71a.concat("(___r");
_71a.concat(++st.receiverLevel+"");
_71a.concat(" = CPArray.isa.objj_msgSend0(CPArray, \"alloc\"), ___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(" == null ? null : ___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(".isa.objj_msgSend2(___r");
_71a.concat(st.receiverLevel+"");
_71a.concat(", \"initWithObjects:count:\", [");
}
if(!(st.maxReceiverLevel>=st.receiverLevel)){
st.maxReceiverLevel=st.receiverLevel;
}
}
}
if(_71c){
for(var i=0;i<_71c;i++){
var elt=node.elements[i];
if(i){
_71a.concat(", ");
}
if(!_719){
_718.lastPos=elt.start;
}
c(elt,st,"Expression");
if(!_719){
_71a.concat(_718.source.substring(_718.lastPos,elt.end));
}
}
if(!_71b){
_71a.concat("], "+_71c+"))");
}
}
if(_71b){
_71a.concat("]");
}else{
st.receiverLevel--;
}
if(!_719){
_718.lastPos=node.end;
}
},DictionaryLiteral:function(node,st,c){
var _71d=st.compiler,_71e=_71d.generate,_71f=_71d.jsBuffer,_720=_71d.options.generateObjJ,_721=node.keys.length;
if(!_71e){
_71f.concat(_71d.source.substring(_71d.lastPos,node.start));
_71d.lastPos=node.start;
}
if(!_71e){
_71f.concat(" ");
}
if(!st.receiverLevel){
st.receiverLevel=0;
}
if(_720){
_71f.concat("@{");
for(var i=0;i<_721;i++){
if(i!==0){
_71f.concat(",");
}
c(node.keys[i],st,"Expression");
_71f.concat(":");
c(node.values[i],st,"Expression");
}
_71f.concat("}");
}else{
if(!_721){
if(_71d.options.inlineMsgSendFunctions){
_71f.concat("(___r");
_71f.concat(++st.receiverLevel+"");
_71f.concat(" = (CPDictionary.isa.method_msgSend[\"alloc\"] || _objj_forward)(CPDictionary, \"alloc\"), ___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(" == null ? null : (___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(".isa.method_msgSend[\"init\"] || _objj_forward)(___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(", \"init\"))");
}else{
_71f.concat("(___r");
_71f.concat(++st.receiverLevel+"");
_71f.concat(" = CPDictionary.isa.objj_msgSend0(CPDictionary, \"alloc\"), ___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(" == null ? null : ___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(".isa.objj_msgSend0(___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(", \"init\"))");
}
if(!(st.maxReceiverLevel>=st.receiverLevel)){
st.maxReceiverLevel=st.receiverLevel;
}
}else{
if(_71d.options.inlineMsgSendFunctions){
_71f.concat("(___r");
_71f.concat(++st.receiverLevel+"");
_71f.concat(" = (CPDictionary.isa.method_msgSend[\"alloc\"] || _objj_forward)(CPDictionary, \"alloc\"), ___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(" == null ? null : (___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(".isa.method_msgSend[\"initWithObjects:forKeys:\"] || _objj_forward)(___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(", \"initWithObjects:forKeys:\", [");
}else{
_71f.concat("(___r");
_71f.concat(++st.receiverLevel+"");
_71f.concat(" = CPDictionary.isa.objj_msgSend0(CPDictionary, \"alloc\"), ___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(" == null ? null : ___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(".isa.objj_msgSend2(___r");
_71f.concat(st.receiverLevel+"");
_71f.concat(", \"initWithObjects:forKeys:\", [");
}
if(!(st.maxReceiverLevel>=st.receiverLevel)){
st.maxReceiverLevel=st.receiverLevel;
}
for(var i=0;i<_721;i++){
var _722=node.values[i];
if(i){
_71f.concat(", ");
}
if(!_71e){
_71d.lastPos=_722.start;
}
c(_722,st,"Expression");
if(!_71e){
_71f.concat(_71d.source.substring(_71d.lastPos,_722.end));
}
}
_71f.concat("], [");
for(var i=0;i<_721;i++){
var key=node.keys[i];
if(i){
_71f.concat(", ");
}
if(!_71e){
_71d.lastPos=key.start;
}
c(key,st,"Expression");
if(!_71e){
_71f.concat(_71d.source.substring(_71d.lastPos,key.end));
}
}
_71f.concat("]))");
}
}
if(!_720){
st.receiverLevel--;
}
if(!_71e){
_71d.lastPos=node.end;
}
},ImportStatement:function(node,st,c){
var _723=st.compiler,_724=_723.generate,_725=_723.jsBuffer,_726=node.localfilepath,_727=_723.options.generateObjJ;
if(!_724){
_725.concat(_723.source.substring(_723.lastPos,node.start));
}
if(_727){
_725.concat("@import ");
_725.concat(_726?"\"":"<");
_725.concat(node.filename.value);
_725.concat(_726?"\"":">");
}else{
_725.concat("objj_executeFile(\"",node);
_725.concat(node.filename.value);
_725.concat(_726?"\", YES);":"\", NO);");
}
if(!_724){
_723.lastPos=node.end;
}
},ClassDeclarationStatement:function(node,st,c,_728){
var _729=st.compiler,_72a=_729.generate,_72b=_729.jsBuffer,_72c=node.classname.name,_72d=_729.getClassDef(_72c),_72e=new _5b0(st),_72f=node.type==="InterfaceDeclarationStatement",_730=node.protocols,_731=_729.options.generateObjJ;
_729.imBuffer=new _2f1(_729.createSourceMap,_729.URL);
_729.cmBuffer=new _2f1(_729.createSourceMap),_729.URL;
_729.classBodyBuffer=new _2f1(_729.createSourceMap,_729.URL);
if(_729.getTypeDef(_72c)){
throw _729.error_message(_72c+" is already declared as a type",node.classname);
}
if(!_72a){
_72b.concat(_729.source.substring(_729.lastPos,node.start));
}
if(node.superclassname){
if(_72d&&_72d.ivars){
throw _729.error_message("Duplicate class "+_72c,node.classname);
}
if(_72f&&_72d&&_72d.instanceMethods&&_72d.classMethods){
throw _729.error_message("Duplicate interface definition for class "+_72c,node.classname);
}
var _732=_729.getClassDef(node.superclassname.name);
if(!_732){
var _733="Can't find superclass "+node.superclassname.name;
if(_621.importStack){
for(var i=_621.importStack.length;--i>=0;){
_733+="\n"+Array((_621.importStack.length-i)*2+1).join(" ")+"Imported by: "+_621.importStack[i];
}
}
throw _729.error_message(_733,node.superclassname);
}
_72d=new _5e4(!_72f,_72c,_732,Object.create(null));
if(!_731){
_72b.concat("\n{var the_class = objj_allocateClassPair("+node.superclassname.name+", \""+_72c+"\"),\nmeta_class = the_class.isa;",node);
}
}else{
if(node.categoryname){
_72d=_729.getClassDef(_72c);
if(!_72d){
throw _729.error_message("Class "+_72c+" not found ",node.classname);
}
if(!_731){
_72b.concat("{\nvar the_class = objj_getClass(\""+_72c+"\")\n",node);
_72b.concat("if(!the_class) throw new SyntaxError(\"*** Could not find definition for class \\\""+_72c+"\\\"\");\n");
_72b.concat("var meta_class = the_class.isa;");
}
}else{
_72d=new _5e4(!_72f,_72c,null,Object.create(null));
if(!_731){
_72b.concat("{var the_class = objj_allocateClassPair(Nil, \""+_72c+"\"),\nmeta_class = the_class.isa;",node);
}
}
}
if(_731){
_72b.concat(_72f?"@interface ":"@implementation ");
_72b.concat(_72c);
if(node.superclassname){
_72b.concat(" : ");
c(node.superclassname,st,"IdentifierName");
}else{
if(node.categoryname){
_72b.concat(" (");
c(node.categoryname,st,"IdentifierName");
_72b.concat(")");
}
}
}
if(_730){
for(var i=0,size=_730.length;i<size;i++){
if(_731){
if(i){
_72b.concat(", ");
}else{
_72b.concat(" <");
}
c(_730[i],st,"IdentifierName");
if(i===size-1){
_72b.concat(">");
}
}else{
_72b.concat("\nvar aProtocol = objj_getProtocol(\""+_730[i].name+"\");",_730[i]);
_72b.concat("\nif (!aProtocol) throw new SyntaxError(\"*** Could not find definition for protocol \\\""+_730[i].name+"\\\"\");");
_72b.concat("\nclass_addProtocol(the_class, aProtocol);");
}
}
}
_72e.classDef=_72d;
_729.currentSuperClass="objj_getClass(\""+_72c+"\").super_class";
_729.currentSuperMetaClass="objj_getMetaClass(\""+_72c+"\").super_class";
var _734=true,_735=_72d.ivars,_736=[],_737=false;
if(node.ivardeclarations){
if(_731){
_72b.concat("{");
_5de+=_679;
}
for(var i=0;i<node.ivardeclarations.length;++i){
var _738=node.ivardeclarations[i],_739=_738.ivartype?_738.ivartype.name:null,_73a=_738.ivartype?_738.ivartype.typeisclass:false,_73b=_738.id,_73c=_73b.name,ivar={"type":_739,"name":_73c},_73d=_738.accessors;
var _73e=function(_73f,_740){
if(_73f.ivars[_73c]){
throw _729.error_message("Instance variable '"+_73c+"' is already declared for class "+_72c+(_73f.name!==_72c?" in superclass "+_73f.name:""),_738.id);
}
if(_73f.superClass){
_740(_73f.superClass,_740);
}
};
_73e(_72d,_73e);
var _741=!_73a||typeof _1[_739]!=="undefined"||typeof window[_739]!=="undefined"||_729.getClassDef(_739)||_729.getTypeDef(_739)||_739==_72d.name;
if(!_741){
_729.addWarning(_5d3("Unknown type '"+_739+"' for ivar '"+_73c+"'",_738.ivartype,_729.source));
}
if(_731){
c(_738,st,"IvarDeclaration");
}else{
if(_734){
_734=false;
_72b.concat("class_addIvars(the_class, [");
}else{
_72b.concat(", ");
}
if(_729.options.includeIvarTypeSignatures){
_72b.concat("new objj_ivar(\""+_73c+"\", \""+_739+"\")",node);
}else{
_72b.concat("new objj_ivar(\""+_73c+"\")",node);
}
}
if(_738.outlet){
ivar.outlet=true;
}
_736.push(ivar);
if(!_72e.ivars){
_72e.ivars=Object.create(null);
}
_72e.ivars[_73c]={type:"ivar",name:_73c,node:_73b,ivar:ivar};
if(_73d){
var _742=(_73d.property&&_73d.property.name)||_73c,_743=(_73d.getter&&_73d.getter.name)||_742;
_72d.addInstanceMethod(new _616(_743,[_739]));
if(!_73d.readonly){
var _744=_73d.setter?_73d.setter.name:null;
if(!_744){
var _745=_742.charAt(0)=="_"?1:0;
_744=(_745?"_":"")+"set"+_742.substr(_745,1).toUpperCase()+_742.substring(_745+1)+":";
}
_72d.addInstanceMethod(new _616(_744,["void",_739]));
}
_737=true;
}
}
}
if(_731){
_5de=_5de.substring(_5e1);
_72b.concatFormat("\n}");
}else{
if(!_734){
_72b.concat("]);");
}
}
if(!_731&&!_72f&&_737){
var _746=new _2f1(_729.createSourceMap,_729.URL);
_746.concat(_729.source.substring(node.start,node.endOfIvars).replace(/<.*>/g,""));
_746.concat("\n");
for(var i=0;i<node.ivardeclarations.length;++i){
var _738=node.ivardeclarations[i],_739=_738.ivartype?_738.ivartype.name:null,_73c=_738.id.name,_73d=_738.accessors;
if(!_73d){
continue;
}
var _742=(_73d.property&&_73d.property.name)||_73c,_743=(_73d.getter&&_73d.getter.name)||_742,_747="- ("+(_739?_739:"id")+")"+_743+"\n{\nreturn "+_73c+";\n}\n";
_746.concat(_747);
if(_73d.readonly){
continue;
}
var _744=_73d.setter?_73d.setter.name:null;
if(!_744){
var _745=_742.charAt(0)=="_"?1:0;
_744=(_745?"_":"")+"set"+_742.substr(_745,1).toUpperCase()+_742.substring(_745+1)+":";
}
var _748="- (void)"+_744+"("+(_739?_739:"id")+")newValue\n{\n";
if(_73d.copy){
_748+="if ("+_73c+" !== newValue)\n"+_73c+" = [newValue copy];\n}\n";
}else{
_748+=_73c+" = newValue;\n}\n";
}
_746.concat(_748);
}
_746.concat("\n@end");
var b=_746.toString().replace(/@accessors(\(.*\))?/g,"");
var _749=_5ad.compileToIMBuffer(b,"Accessors",_729.options);
_729.imBuffer.concat(_749);
}
for(var _74a=_736.length,i=0;i<_74a;i++){
var ivar=_736[i],_73c=ivar.name;
_735[_73c]=ivar;
}
_729.classDefs[_72c]=_72d;
var _74b=node.body,_74c=_74b.length;
if(_74c>0){
if(!_72a){
_729.lastPos=_74b[0].start;
}
for(var i=0;i<_74c;++i){
var body=_74b[i];
c(body,_72e,"Statement");
}
if(!_72a){
_72b.concat(_729.source.substring(_729.lastPos,body.end));
}
}
if(!_731&&!_72f&&!node.categoryname){
_72b.concat("objj_registerClassPair(the_class);\n");
}
if(!_731&&_729.imBuffer.isEmpty()){
_72b.concat("class_addMethods(the_class, [");
_72b.appendStringBuffer(_729.imBuffer);
_72b.concat("]);\n");
}
if(!_731&&_729.cmBuffer.isEmpty()){
_72b.concat("class_addMethods(meta_class, [");
_72b.appendStringBuffer(_729.cmBuffer);
_72b.concat("]);\n");
}
if(!_731){
_72b.concat("}\n");
}
_729.jsBuffer=_72b;
if(!_72a){
_729.lastPos=node.end;
}
if(_731){
_72b.concat("\n@end");
}
if(_730){
var _74d=[];
for(var i=0,size=_730.length;i<size;i++){
var _74e=_730[i],_74f=_729.getProtocolDef(_74e.name);
if(!_74f){
throw _729.error_message("Cannot find protocol declaration for '"+_74e.name+"'",_74e);
}
_74d.push(_74f);
}
var _750=_72d.listOfNotImplementedMethodsForProtocols(_74d);
if(_750&&_750.length>0){
for(var j=0,_751=_750.length;j<_751;j++){
var _752=_750[j],_753=_752.methodDef,_74f=_752.protocolDef;
_729.addWarning(_5d3("Method '"+_753.name+"' in protocol '"+_74f.name+"' is not implemented",node.classname,_729.source));
}
}
}
},ProtocolDeclarationStatement:function(node,st,c){
var _754=st.compiler,_755=_754.generate,_756=_754.jsBuffer,_757=node.protocolname.name,_758=_754.getProtocolDef(_757),_759=node.protocols,_75a=new _5b0(st),_75b=[],_75c=_754.options.generateObjJ;
if(_758){
throw _754.error_message("Duplicate protocol "+_757,node.protocolname);
}
_754.imBuffer=new _2f1(_754.createSourceMap,_754.URL);
_754.cmBuffer=new _2f1(_754.createSourceMap),_754.URL;
if(!_755){
_756.concat(_754.source.substring(_754.lastPos,node.start));
}
if(_75c){
_756.concat("@protocol ");
c(node.protocolname,st,"IdentifierName");
}else{
_756.concat("{var the_protocol = objj_allocateProtocol(\""+_757+"\");",node);
}
if(_759){
if(_75c){
_756.concat(" <");
}
for(var i=0,size=_759.length;i<size;i++){
var _75d=_759[i],_75e=_75d.name,_75f=_754.getProtocolDef(_75e);
if(!_75f){
throw _754.error_message("Can't find protocol "+_75e,_75d);
}
if(_75c){
if(i){
_756.concat(", ");
}
c(_75d,st,"IdentifierName");
}else{
_756.concat("\nvar aProtocol = objj_getProtocol(\""+_75e+"\");",node);
_756.concat("\nif (!aProtocol) throw new SyntaxError(\"*** Could not find definition for protocol \\\""+_757+"\\\"\");",node);
_756.concat("\nprotocol_addProtocol(the_protocol, aProtocol);",node);
}
_75b.push(_75f);
}
if(_75c){
_756.concat(">");
}
}
_758=new _607(_757,_75b);
_754.protocolDefs[_757]=_758;
_75a.protocolDef=_758;
var _760=node.required;
if(_760){
var _761=_760.length;
if(_761>0){
for(var i=0;i<_761;++i){
var _762=_760[i];
if(!_755){
_754.lastPos=_762.start;
}
c(_762,_75a,"Statement");
}
if(!_755){
_756.concat(_754.source.substring(_754.lastPos,_762.end));
}
}
}
if(_75c){
_756.concatFormat("\n@end");
}else{
_756.concat("\nobjj_registerProtocol(the_protocol);\n");
if(_754.imBuffer.isEmpty()){
_756.concat("protocol_addMethodDescriptions(the_protocol, [");
_756.appendStringBuffer(_754.imBuffer);
_756.concat("], true, true);\n");
}
if(_754.cmBuffer.isEmpty()){
_756.concat("protocol_addMethodDescriptions(the_protocol, [");
_756.appendStringBuffer(_754.cmBuffer);
_756.concat("], true, false);\n");
}
_756.concat("}");
}
_754.jsBuffer=_756;
if(!_755){
_754.lastPos=node.end;
}
},IvarDeclaration:function(node,st,c,_763){
var _764=st.compiler,_765=_764.jsBuffer;
if(node.outlet){
_765.concat("@outlet ");
}
c(node.ivartype,st,"IdentifierName");
_765.concat(" ");
c(node.id,st,"IdentifierName");
if(node.accessors){
_765.concat(" @accessors");
}
},MethodDeclarationStatement:function(node,st,c){
var _766=st.compiler,_767=_766.generate,_768=_766.jsBuffer,_769=new _5b0(st),_76a=node.methodtype==="-",_76b=node.selectors,_76c=node.arguments,_76d=node.returntype,_76e=[_76d?_76d.name:(node.action?"void":"id")],_76f=_76d?_76d.protocols:null,_770=_76b[0].name,_771=_766.options.generateObjJ;
if(_76f){
for(var i=0,size=_76f.length;i<size;i++){
var _772=_76f[i];
if(!_766.getProtocolDef(_772.name)){
_766.addWarning(_5d3("Cannot find protocol declaration for '"+_772.name+"'",_772,_766.source));
}
}
}
if(!_767){
_768.concat(_766.source.substring(_766.lastPos,node.start));
}
if(_771){
_766.jsBuffer.concat(_76a?"- (":"+ (");
_766.jsBuffer.concat(_76e[0]);
_766.jsBuffer.concat(")");
}else{
_766.jsBuffer=_76a?_766.imBuffer:_766.cmBuffer;
}
var size=_76c.length;
if(size>0){
for(var i=0;i<_76c.length;i++){
var _773=_76c[i],_774=_773.type,_775=_774?_774.name:"id",_776=_774?_774.protocols:null;
_76e.push(_775);
if(i===0){
_770+=":";
}else{
_770+=(_76b[i]?_76b[i].name:"")+":";
}
if(_776){
for(var j=0,size=_776.length;j<size;j++){
var _777=_776[j];
if(!_766.getProtocolDef(_777.name)){
_766.addWarning(_5d3("Cannot find protocol declaration for '"+_777.name+"'",_777,_766.source));
}
}
}
if(_771){
var _778=_76b[i];
if(i){
_766.jsBuffer.concat(" ");
}
_766.jsBuffer.concat((_778?_778.name:"")+":");
_766.jsBuffer.concat("(");
_766.jsBuffer.concat(_775);
if(_776){
_766.jsBuffer.concat(" <");
for(var j=0,size=_776.length;j<size;j++){
var _777=_776[j];
if(j){
_766.jsBuffer.concat(", ");
}
_766.jsBuffer.concat(_777.name);
}
_766.jsBuffer.concat(">");
}
_766.jsBuffer.concat(")");
c(_773.identifier,st,"IdentifierName");
}
}
}else{
if(_771){
var _779=_76b[0];
_766.jsBuffer.concat(_779.name,_779);
}
}
if(_771){
if(node.parameters){
_766.jsBuffer.concat(", ...");
}
}else{
if(_766.jsBuffer.isEmpty()){
_766.jsBuffer.concat(", ");
}
_766.jsBuffer.concat("new objj_method(sel_getUid(\"",node);
_766.jsBuffer.concat(_770);
_766.jsBuffer.concat("\"), ");
}
if(node.body){
if(!_771){
_766.jsBuffer.concat("function");
if(_766.options.includeMethodFunctionNames){
_766.jsBuffer.concat(" $"+st.currentClassName()+"__"+_770.replace(/:/g,"_"));
}
_766.jsBuffer.concat("(self, _cmd");
}
_769.methodType=node.methodtype;
_769.vars["self"]={type:"method base",scope:_769};
_769.vars["_cmd"]={type:"method base",scope:_769};
if(_76c){
for(var i=0;i<_76c.length;i++){
var _773=_76c[i],_77a=_773.identifier.name;
if(!_771){
_766.jsBuffer.concat(", ");
_766.jsBuffer.concat(_77a,_773.identifier);
}
_769.vars[_77a]={type:"method argument",node:_773};
}
}
if(!_771){
_766.jsBuffer.concat(")\n");
}
if(!_767){
_766.lastPos=node.startOfBody;
}
_5de+=_679;
_769.endOfScopeBody=true;
c(node.body,_769,"Statement");
_5de=_5de.substring(_5e1);
if(!_767){
_766.jsBuffer.concat(_766.source.substring(_766.lastPos,node.body.end));
}
if(!_771){
_766.jsBuffer.concat("\n");
}
}else{
if(_771){
_766.jsBuffer.concat(";");
}else{
_766.jsBuffer.concat("Nil\n");
}
}
if(!_771){
if(_766.options.includeMethodArgumentTypeSignatures){
_766.jsBuffer.concat(","+JSON.stringify(_76e));
}
_766.jsBuffer.concat(")");
_766.jsBuffer=_768;
}
if(!_767){
_766.lastPos=node.end;
}
var def=st.classDef,_77b;
if(def){
_77b=_76a?def.getInstanceMethod(_770):def.getClassMethod(_770);
}else{
def=st.protocolDef;
}
if(!def){
throw "InternalError: MethodDeclaration without ClassDeclaration or ProtocolDeclaration at line: "+_5ae.getLineInfo(_766.source,node.start).line;
}
if(!_77b){
var _77c=def.protocols;
if(_77c){
for(var i=0,size=_77c.length;i<size;i++){
var _77d=_77c[i],_77b=_76a?_77d.getInstanceMethod(_770):_77d.getClassMethod(_770);
if(_77b){
break;
}
}
}
}
if(_77b){
var _77e=_77b.types;
if(_77e){
var _77f=_77e.length;
if(_77f>0){
var _780=_77e[0];
if(_780!==_76e[0]&&!(_780==="id"&&_76d&&_76d.typeisclass)){
_766.addWarning(_5d3("Conflicting return type in implementation of '"+_770+"': '"+_780+"' vs '"+_76e[0]+"'",_76d||node.action||_76b[0],_766.source));
}
for(var i=1;i<_77f;i++){
var _781=_77e[i];
if(_781!==_76e[i]&&!(_781==="id"&&_76c[i-1].type.typeisclass)){
_766.addWarning(_5d3("Conflicting parameter types in implementation of '"+_770+"': '"+_781+"' vs '"+_76e[i]+"'",_76c[i-1].type||_76c[i-1].identifier,_766.source));
}
}
}
}
}
var _782=new _616(_770,_76e);
if(_76a){
def.addInstanceMethod(_782);
}else{
def.addClassMethod(_782);
}
},MessageSendExpression:function(node,st,c){
var _783=st.compiler,_784=_783.generate,_785=_783.options.inlineMsgSendFunctions,_786=_783.jsBuffer,_787=node.object,_788=node.selectors,_789=node.arguments,_78a=_789.length,_78b=_788[0],_78c=_78b?_78b.name:"",_78d=node.parameters,_78e=_783.options.generateObjJ;
for(var i=0;i<_78a;i++){
if(i!==0){
var _78f=_788[i];
if(_78f){
_78c+=_78f.name;
}
}
_78c+=":";
}
if(!_784){
_786.concat(_783.source.substring(_783.lastPos,node.start));
_783.lastPos=_787?_787.start:node.arguments.length?node.arguments[0].start:node.end;
}else{
if(!_785){
var _790=_78a;
if(_78d){
_790+=_78d.length;
}
}
}
if(node.superObject){
if(!_784){
_786.concat(" ");
}
if(_78e){
_786.concat("[super ");
}else{
if(_785){
_786.concat("(");
_786.concat(st.currentMethodType()==="+"?_783.currentSuperMetaClass:_783.currentSuperClass);
_786.concat(".method_dtable[\"");
_786.concat(_78c);
_786.concat("\"] || _objj_forward)(self");
}else{
_786.concat("objj_msgSendSuper");
if(_790<4){
_786.concat(""+_790);
}
_786.concat("({ receiver:self, super_class:"+(st.currentMethodType()==="+"?_783.currentSuperMetaClass:_783.currentSuperClass)+" }");
}
}
}else{
if(_784){
var _791=_787.type==="Identifier"&&!(st.currentMethodType()==="-"&&_783.getIvarForClass(_787.name,st)&&!st.getLvar(_787.name,true)),_792,_793;
if(_791){
var name=_787.name,_792=st.getLvar(name);
if(name==="self"){
_793=!_792||!_792.scope||_792.scope.assignmentToSelf;
}else{
_793=!!_792||!_783.getClassDef(name);
}
if(_793){
_786.concat("(");
c(_787,st,"Expression");
_786.concat(" == null ? null : ");
}
if(_785){
_786.concat("(");
}
c(_787,st,"Expression");
}else{
_793=true;
if(!st.receiverLevel){
st.receiverLevel=0;
}
_786.concat("((___r");
_786.concat(++st.receiverLevel+"");
_786.concat(" = ");
c(_787,st,"Expression");
_786.concat("), ___r");
_786.concat(st.receiverLevel+"");
_786.concat(" == null ? null : ");
if(_785){
_786.concat("(");
}
_786.concat("___r");
_786.concat(st.receiverLevel+"");
if(!(st.maxReceiverLevel>=st.receiverLevel)){
st.maxReceiverLevel=st.receiverLevel;
}
}
if(_785){
_786.concat(".isa.method_msgSend[\"");
_786.concat(_78c);
_786.concat("\"] || _objj_forward)");
}else{
_786.concat(".isa.objj_msgSend");
}
}else{
_786.concat(" ");
_786.concat("objj_msgSend(");
_786.concat(_783.source.substring(_783.lastPos,_787.end));
}
}
if(_78e){
for(var i=0;i<_78a||(_78a===0&&i===0);i++){
var _78c=_788[i];
_786.concat(" ");
_786.concat(_78c?_78c.name:"");
if(_78a>0){
var _794=_789[i];
_786.concat(":");
c(_794,st,"Expression");
}
}
if(_78d){
for(var i=0,size=_78d.length;i<size;++i){
var _795=_78d[i];
_786.concat(", ");
c(_795,st,"Expression");
}
}
_786.concat("]");
}else{
if(_784&&!node.superObject){
if(!_785){
if(_790<4){
_786.concat(""+_790);
}
}
if(_791){
_786.concat("(");
c(_787,st,"Expression");
}else{
_786.concat("(___r");
_786.concat(st.receiverLevel+"");
}
}
_786.concat(", \"");
_786.concat(_78c);
_786.concat("\"");
if(_789){
for(var i=0;i<_789.length;i++){
var _794=_789[i];
_786.concat(", ");
if(!_784){
_783.lastPos=_794.start;
}
c(_794,st,"Expression");
if(!_784){
_786.concat(_783.source.substring(_783.lastPos,_794.end));
_783.lastPos=_794.end;
}
}
}
if(_78d){
for(var i=0;i<_78d.length;++i){
var _795=_78d[i];
_786.concat(", ");
if(!_784){
_783.lastPos=_795.start;
}
c(_795,st,"Expression");
if(!_784){
_786.concat(_783.source.substring(_783.lastPos,_795.end));
_783.lastPos=_795.end;
}
}
}
if(_784&&!node.superObject){
if(_793){
_786.concat(")");
}
if(!_791){
st.receiverLevel--;
}
}
_786.concat(")");
}
if(!_784){
_783.lastPos=node.end;
}
},SelectorLiteralExpression:function(node,st,c){
var _796=st.compiler,_797=_796.jsBuffer,_798=_796.generate,_799=_796.options.generateObjJ;
if(!_798){
_797.concat(_796.source.substring(_796.lastPos,node.start));
_797.concat(" ");
}
_797.concat(_799?"@selector(":"sel_getUid(\"",node);
_797.concat(node.selector);
_797.concat(_799?")":"\")");
if(!_798){
_796.lastPos=node.end;
}
},ProtocolLiteralExpression:function(node,st,c){
var _79a=st.compiler,_79b=_79a.jsBuffer,_79c=_79a.generate,_79d=_79a.options.generateObjJ;
if(!_79c){
_79b.concat(_79a.source.substring(_79a.lastPos,node.start));
_79b.concat(" ");
}
_79b.concat(_79d?"@protocol(":"objj_getProtocol(\"",node);
c(node.id,st,"IdentifierName");
_79b.concat(_79d?")":"\")");
if(!_79c){
_79a.lastPos=node.end;
}
},Reference:function(node,st,c){
var _79e=st.compiler,_79f=_79e.jsBuffer,_7a0=_79e.generate,_7a1=_79e.options.generateObjJ;
if(!_7a0){
_79f.concat(_79e.source.substring(_79e.lastPos,node.start));
_79f.concat(" ");
}
if(_7a1){
_79f.concat("@ref(",node);
_79f.concat(node.element.name,node.element);
_79f.concat(")",node);
}else{
_79f.concat("function(__input) { if (arguments.length) return ",node);
c(node.element,st,"Expression");
_79f.concat(" = __input; return ");
c(node.element,st,"Expression");
_79f.concat("; }");
}
if(!_7a0){
_79e.lastPos=node.end;
}
},Dereference:function(node,st,c){
var _7a2=st.compiler,_7a3=_7a2.jsBuffer,_7a4=_7a2.generate,_7a5=_7a2.options.generateObjJ;
_66b(st,node.expr);
if(!_7a4){
_7a3.concat(_7a2.source.substring(_7a2.lastPos,node.start));
_7a2.lastPos=node.expr.start;
}
if(_7a5){
_7a3.concat("@deref(");
}
c(node.expr,st,"Expression");
if(!_7a4){
_7a3.concat(_7a2.source.substring(_7a2.lastPos,node.expr.end));
}
if(_7a5){
_7a3.concat(")");
}else{
_7a3.concat("()");
}
if(!_7a4){
_7a2.lastPos=node.end;
}
},ClassStatement:function(node,st,c){
var _7a6=st.compiler,_7a7=_7a6.jsBuffer,_7a8=_7a6.options.generateObjJ;
if(!_7a6.generate){
_7a7.concat(_7a6.source.substring(_7a6.lastPos,node.start));
_7a6.lastPos=node.start;
_7a7.concat("//");
}
if(_7a8){
_7a7.concat("@class ");
c(node.id,st,"IdentifierName");
}
var _7a9=node.id.name;
if(_7a6.getTypeDef(_7a9)){
throw _7a6.error_message(_7a9+" is already declared as a type",node.id);
}
if(!_7a6.getClassDef(_7a9)){
_7a6.classDefs[_7a9]=new _5e4(false,_7a9);
}
st.vars[node.id.name]={type:"class",node:node.id};
},GlobalStatement:function(node,st,c){
var _7aa=st.compiler,_7ab=_7aa.jsBuffer,_7ac=_7aa.options.generateObjJ;
if(!_7aa.generate){
_7ab.concat(_7aa.source.substring(_7aa.lastPos,node.start));
_7aa.lastPos=node.start;
_7ab.concat("//");
}
if(_7ac){
_7ab.concat("@global ");
c(node.id,st,"IdentifierName");
}
st.rootScope().vars[node.id.name]={type:"global",node:node.id};
},PreprocessStatement:function(node,st,c){
var _7ad=st.compiler;
if(!_7ad.generate){
_7ad.jsBuffer.concat(_7ad.source.substring(_7ad.lastPos,node.start));
_7ad.lastPos=node.start;
_7ad.jsBuffer.concat("//");
}
},TypeDefStatement:function(node,st,c){
var _7ae=st.compiler,_7af=_7ae.generate,_7b0=_7ae.jsBuffer,_7b1=node.typedefname.name,_7b2=_7ae.getTypeDef(_7b1),_7b3=new _5b0(st);
if(_7b2){
throw _7ae.error_message("Duplicate type definition "+_7b1,node.typedefname);
}
if(_7ae.getClassDef(_7b1)){
throw _7ae.error_message(_7b1+" is already declared as class",node.typedefname);
}
if(!_7af){
_7b0.concat(_7ae.source.substring(_7ae.lastPos,node.start));
}
_7b0.concat("{var the_typedef = objj_allocateTypeDef(\""+_7b1+"\");");
_7b2=new _615(_7b1);
_7ae.typeDefs[_7b1]=_7b2;
_7b3.typeDef=_7b2;
_7b0.concat("\nobjj_registerTypeDef(the_typedef);\n");
_7b0.concat("}");
if(!_7af){
_7ae.lastPos=node.end;
}
}});
});
function _32f(aURL,_7b4){
this._URL=aURL;
this._isLocal=_7b4;
};
_2.FileDependency=_32f;
_32f.prototype.URL=function(){
return this._URL;
};
_32f.prototype.isLocal=function(){
return this._isLocal;
};
_32f.prototype.toMarkedString=function(){
var _7b5=this.URL().absoluteString();
return (this.isLocal()?_264:_263)+";"+_7b5.length+";"+_7b5;
};
_32f.prototype.toString=function(){
return (this.isLocal()?"LOCAL: ":"STD: ")+this.URL();
};
var _7b6=0,_7b7=1,_7b8=2,_7b9=0;
function _300(_7ba,_7bb,aURL,_7bc,_7bd,_7be){
if(arguments.length===0){
return this;
}
this._code=_7ba;
this._function=_7bc||null;
this._URL=_1e2(aURL||new CFURL("(Anonymous"+(_7b9++)+")"));
this._compiler=_7bd||null;
this._fileDependencies=_7bb;
this._filenameTranslateDictionary=_7be;
if(_7bb.length){
this._fileDependencyStatus=_7b6;
this._fileDependencyCallbacks=[];
}else{
this._fileDependencyStatus=_7b8;
}
if(this._function){
return;
}
if(!_7bd){
this.setCode(_7ba);
}
};
_2.Executable=_300;
_300.prototype.path=function(){
return this.URL().path();
};
_300.prototype.URL=function(){
return this._URL;
};
_300.prototype.functionParameters=function(){
var _7bf=["global","objj_executeFile","objj_importFile"];
return _7bf;
};
_300.prototype.functionArguments=function(){
var _7c0=[_1,this.fileExecuter(),this.fileImporter()];
return _7c0;
};
_300.prototype.execute=function(){
if(this._compiler){
var _7c1=this.fileDependencies(),_9d=0,_7c2=_7c1.length;
this._compiler.pushImport(this.URL().lastPathComponent());
for(;_9d<_7c2;++_9d){
var _7c3=_7c1[_9d],_7c4=_7c3.isLocal(),URL=_7c3.URL();
this.fileExecuter()(URL,_7c4);
}
this._compiler.popImport();
this.setCode(this._compiler.compilePass2());
if(_7c5.printWarningsAndErrors(this._compiler,_2.messageOutputFormatInXML)){
throw "Compilation error";
}
this._compiler=null;
}
var _7c6=_7c7;
_7c7=CFBundle.bundleContainingURL(this.URL());
var _7c8=this._function.apply(_1,this.functionArguments());
_7c7=_7c6;
return _7c8;
};
_300.prototype.code=function(){
return this._code;
};
_300.prototype.setCode=function(code){
this._code=code;
var _7c9=this.functionParameters().join(",");
this._function=new Function(_7c9,code);
};
_300.prototype.fileDependencies=function(){
return this._fileDependencies;
};
_300.prototype.hasLoadedFileDependencies=function(){
return this._fileDependencyStatus===_7b8;
};
var _7ca=0,_7cb=[],_7cc={};
_300.prototype.loadFileDependencies=function(_7cd){
var _7ce=this._fileDependencyStatus;
if(_7cd){
if(_7ce===_7b8){
return _7cd();
}
this._fileDependencyCallbacks.push(_7cd);
}
if(_7ce===_7b6){
if(_7ca){
throw "Can't load";
}
_7cf(this);
}
};
function _7cf(_7d0){
_7cb.push(_7d0);
_7d0._fileDependencyStatus=_7b7;
var _7d1=_7d0.fileDependencies(),_9d=0,_7d2=_7d1.length,_7d3=_7d0.referenceURL(),_7d4=_7d3.absoluteString(),_7d5=_7d0.fileExecutableSearcher();
_7ca+=_7d2;
for(;_9d<_7d2;++_9d){
var _7d6=_7d1[_9d],_7d7=_7d6.isLocal(),URL=_7d6.URL(),_7d8=(_7d7&&(_7d4+" ")||"")+URL;
if(_7cc[_7d8]){
if(--_7ca===0){
_7d9();
}
continue;
}
_7cc[_7d8]=YES;
_7d5(URL,_7d7,_7da);
}
};
function _7da(_7db){
--_7ca;
if(_7db._fileDependencyStatus===_7b6){
_7cf(_7db);
}else{
if(_7ca===0){
_7d9();
}
}
};
function _7d9(){
var _7dc=_7cb,_9d=0,_7dd=_7dc.length;
_7cb=[];
for(;_9d<_7dd;++_9d){
_7dc[_9d]._fileDependencyStatus=_7b8;
}
for(_9d=0;_9d<_7dd;++_9d){
var _7de=_7dc[_9d],_7df=_7de._fileDependencyCallbacks,_7e0=0,_7e1=_7df.length;
for(;_7e0<_7e1;++_7e0){
_7df[_7e0]();
}
_7de._fileDependencyCallbacks=[];
}
};
_300.prototype.referenceURL=function(){
if(this._referenceURL===_2f){
this._referenceURL=new CFURL(".",this.URL());
}
return this._referenceURL;
};
_300.prototype.fileImporter=function(){
return _300.fileImporterForURL(this.referenceURL());
};
_300.prototype.fileExecuter=function(){
return _300.fileExecuterForURL(this.referenceURL());
};
_300.prototype.fileExecutableSearcher=function(){
return _300.fileExecutableSearcherForURL(this.referenceURL());
};
var _7e2={};
_300.fileExecuterForURL=function(aURL){
var _7e3=_1e2(aURL),_7e4=_7e3.absoluteString(),_7e5=_7e2[_7e4];
if(!_7e5){
_7e5=function(aURL,_7e6,_7e7){
_300.fileExecutableSearcherForURL(_7e3)(aURL,_7e6,function(_7e8){
if(!_7e8.hasLoadedFileDependencies()){
throw "No executable loaded for file at URL "+aURL;
}
_7e8.execute(_7e7);
});
};
_7e2[_7e4]=_7e5;
}
return _7e5;
};
var _7e9={};
_300.fileImporterForURL=function(aURL){
var _7ea=_1e2(aURL),_7eb=_7ea.absoluteString(),_7ec=_7e9[_7eb];
if(!_7ec){
_7ec=function(aURL,_7ed,_7ee){
_17b();
_300.fileExecutableSearcherForURL(_7ea)(aURL,_7ed,function(_7ef){
_7ef.loadFileDependencies(function(){
_7ef.execute();
_17c();
if(_7ee){
_7ee();
}
});
});
};
_7e9[_7eb]=_7ec;
}
return _7ec;
};
var _7f0={},_7f1={};
function _28f(x){
var _7f2=0;
for(var k in x){
if(x.hasOwnProperty(k)){
++_7f2;
}
}
return _7f2;
};
_300.resetCachedFileExecutableSearchers=function(){
_7f0={};
_7f1={};
_7e9={};
_7e2={};
_7cc={};
};
_300.fileExecutableSearcherForURL=function(_7f3){
var _7f4=_7f3.absoluteString(),_7f5=_7f0[_7f4],_7f6=_300.filenameTranslateDictionary?_300.filenameTranslateDictionary():null;
cachedSearchResults={};
if(!_7f5){
_7f5=function(aURL,_7f7,_7f8){
var _7f9=(_7f7&&_7f3||"")+aURL,_7fa=_7f1[_7f9];
if(_7fa){
return _7fb(_7fa);
}
var _7fc=(aURL instanceof CFURL)&&aURL.scheme();
if(_7f7||_7fc){
if(!_7fc){
aURL=new CFURL(aURL,_7f3);
}
_1cb.resolveResourceAtURL(aURL,NO,_7fb,_7f6);
}else{
_1cb.resolveResourceAtURLSearchingIncludeURLs(aURL,_7fb);
}
function _7fb(_7fd){
if(!_7fd){
var _7fe=_2.ObjJCompiler?_2.ObjJCompiler.currentCompileFile:null;
throw new Error("Could not load file at "+aURL+(_7fe?" when compiling "+_7fe:""));
}
_7f1[_7f9]=_7fd;
_7f8(new _7c5(_7fd.URL(),_7f6));
};
};
_7f0[_7f4]=_7f5;
}
return _7f5;
};
var _7ff={};
var _800={};
var _801="";
function _7c5(aURL,_802){
aURL=_1e2(aURL);
var _803=aURL.absoluteString(),_804=_7ff[_803];
if(_804){
return _804;
}
_7ff[_803]=this;
var _805=_1cb.resourceAtURL(aURL).contents(),_806=NULL,_807=aURL.pathExtension().toLowerCase();
if(_805.match(/^@STATIC;/)){
_806=_808(_805,aURL);
}else{
if((_807==="j"||!_807)&&!_805.match(/^{/)){
var _809=_2.ObjJCompiler.compileFileDependencies(_805,aURL,_800||{});
if(_7c5.printWarningsAndErrors(_809,_2.messageOutputFormatInXML)){
throw "Compilation error";
}
var _80a=_809.dependencies.map(function(_80b){
return new _32f(new CFURL(_80b.url),_80b.isLocal);
});
_806=new _300(_809.jsBuffer?_809.jsBuffer.toString():null,_80a,_809.URL,null,_809);
}else{
_806=new _300(_805,[],aURL);
}
}
_300.apply(this,[_806.code(),_806.fileDependencies(),aURL,_806._function,_806._compiler,_802]);
this._hasExecuted=NO;
};
_2.FileExecutable=_7c5;
_7c5.prototype=new _300();
_7c5.resetFileExecutables=function(){
_7ff={};
_80c={};
};
_7c5.prototype.execute=function(_80d){
if(this._hasExecuted&&!_80d){
return;
}
this._hasExecuted=YES;
_300.prototype.execute.call(this);
};
_7c5.prototype.hasExecuted=function(){
return this._hasExecuted;
};
function _808(_80e,aURL){
var _80f=new _11d(_80e);
var _810=NULL,code="",_811=[];
while(_810=_80f.getMarker()){
var text=_80f.getString();
if(_810===_262){
code+=text;
}else{
if(_810===_263){
_811.push(new _32f(new CFURL(text),NO));
}else{
if(_810===_264){
_811.push(new _32f(new CFURL(text),YES));
}
}
}
}
var fn=_7c5._lookupCachedFunction(aURL);
if(fn){
return new _300(code,_811,aURL,fn);
}
return new _300(code,_811,aURL);
};
var _80c={};
_7c5._cacheFunction=function(aURL,fn){
aURL=typeof aURL==="string"?aURL:aURL.absoluteString();
_80c[aURL]=fn;
};
_7c5._lookupCachedFunction=function(aURL){
aURL=typeof aURL==="string"?aURL:aURL.absoluteString();
return _80c[aURL];
};
_7c5.setCurrentGccCompilerFlags=function(_812){
if(_801===_812){
return;
}
_801=_812;
var args=_812.split(" "),_813=args.length,_814={};
for(var _815=0;_815<_813;++_815){
var _816=args[_815];
if(_816.indexOf("-g")===0){
_814.includeMethodFunctionNames=true;
}else{
if(_816.indexOf("-O")===0){
_814.inlineMsgSendFunctions=true;
if(_816.length>2){
_814.inlineMsgSendFunctions=true;
}
}else{
if(_816.indexOf("-T")===0){
_814.includeIvarTypeSignatures=false;
_814.includeMethodArgumentTypeSignatures=false;
}
}
}
}
_7c5.setCurrentCompilerFlags(_814);
};
_7c5.currentGccCompilerFlags=function(_817){
return _801;
};
_7c5.setCurrentCompilerFlags=function(_818){
_800=_818;
if(_800.transformNamedFunctionDeclarationToAssignment==null){
_800.transformNamedFunctionDeclarationToAssignment=true;
}
if(_800.sourceMap==null){
_800.sourceMap=false;
}
if(_800.inlineMsgSendFunctions==null){
_800.inlineMsgSendFunctions=false;
}
};
_7c5.currentCompilerFlags=function(_819){
return _800;
};
_7c5.printWarningsAndErrors=function(_81a,_81b){
var _81c=[],_81d=false;
for(var i=0;i<_81a.warningsAndErrors.length;i++){
var _81e=_81a.warningsAndErrors[i],_81f=_81a.prettifyMessage(_81e);
_81d=_81d||_81e.messageType==="ERROR";
console.log(_81f);
}
return _81d;
};
_7c5.setCurrentCompilerFlags({});
var _820=1,_821=2,_822=4,_823=8;
objj_ivar=function(_824,_825){
this.name=_824;
this.type=_825;
};
objj_method=function(_826,_827,_828){
var _829=_827||function(_82a,_82b){
CPException.isa.objj_msgSend2(CPException,"raise:reason:",CPInternalInconsistencyException,_82a.isa.method_msgSend0(self,"className")+" does not have an implementation for selector '"+_82b+"'");
};
_829.method_name=_826;
_829.method_imp=_827;
_829.method_types=_828;
return _829;
};
objj_class=function(_82c){
this.isa=NULL;
this.version=0;
this.super_class=NULL;
this.sub_classes=[];
this.name=NULL;
this.info=0;
this.ivar_list=[];
this.ivar_store=function(){
};
this.ivar_dtable=this.ivar_store.prototype;
this.method_list=[];
this.method_store=function(){
};
this.method_dtable=this.method_store.prototype;
this.protocol_list=[];
this.allocator=function(){
};
this._UID=-1;
};
objj_protocol=function(_82d){
this.name=_82d;
this.instance_methods={};
this.class_methods={};
};
objj_object=function(){
this.isa=NULL;
this._UID=-1;
};
objj_typeDef=function(_82e){
this.name=_82e;
};
class_getName=function(_82f){
if(_82f==Nil){
return "";
}
return _82f.name;
};
class_isMetaClass=function(_830){
if(!_830){
return NO;
}
return ((_830.info&(_821)));
};
class_getSuperclass=function(_831){
if(_831==Nil){
return Nil;
}
return _831.super_class;
};
class_setSuperclass=function(_832,_833){
_832.super_class=_833;
_832.isa.super_class=_833.isa;
};
class_addIvar=function(_834,_835,_836){
var _837=_834.allocator.prototype;
if(typeof _837[_835]!="undefined"){
return NO;
}
var ivar=new objj_ivar(_835,_836);
_834.ivar_list.push(ivar);
_834.ivar_dtable[_835]=ivar;
_837[_835]=NULL;
return YES;
};
class_addIvars=function(_838,_839){
var _83a=0,_83b=_839.length,_83c=_838.allocator.prototype;
for(;_83a<_83b;++_83a){
var ivar=_839[_83a],name=ivar.name;
if(typeof _83c[name]==="undefined"){
_838.ivar_list.push(ivar);
_838.ivar_dtable[name]=ivar;
_83c[name]=NULL;
}
}
};
class_copyIvarList=function(_83d){
return _83d.ivar_list.slice(0);
};
class_addMethod=function(_83e,_83f,_840,_841){
var _842=new objj_method(_83f,_840,_841);
_83e.method_list.push(_842);
_83e.method_dtable[_83f]=_842;
if(!((_83e.info&(_821)))&&(((_83e.info&(_821)))?_83e:_83e.isa).isa===(((_83e.info&(_821)))?_83e:_83e.isa)){
class_addMethod((((_83e.info&(_821)))?_83e:_83e.isa),_83f,_840,_841);
}
return YES;
};
class_addMethods=function(_843,_844){
var _845=0,_846=_844.length,_847=_843.method_list,_848=_843.method_dtable;
for(;_845<_846;++_845){
var _849=_844[_845];
_847.push(_849);
_848[_849.method_name]=_849;
}
if(!((_843.info&(_821)))&&(((_843.info&(_821)))?_843:_843.isa).isa===(((_843.info&(_821)))?_843:_843.isa)){
class_addMethods((((_843.info&(_821)))?_843:_843.isa),_844);
}
};
class_getInstanceMethod=function(_84a,_84b){
if(!_84a||!_84b){
return NULL;
}
var _84c=_84a.method_dtable[_84b];
return _84c?_84c:NULL;
};
class_getInstanceVariable=function(_84d,_84e){
if(!_84d||!_84e){
return NULL;
}
var _84f=_84d.ivar_dtable[_84e];
return _84f;
};
class_getClassMethod=function(_850,_851){
if(!_850||!_851){
return NULL;
}
var _852=(((_850.info&(_821)))?_850:_850.isa).method_dtable[_851];
return _852?_852:NULL;
};
class_respondsToSelector=function(_853,_854){
return class_getClassMethod(_853,_854)!=NULL;
};
class_copyMethodList=function(_855){
return _855.method_list.slice(0);
};
class_getVersion=function(_856){
return _856.version;
};
class_setVersion=function(_857,_858){
_857.version=parseInt(_858,10);
};
class_replaceMethod=function(_859,_85a,_85b){
if(!_859||!_85a){
return NULL;
}
var _85c=_859.method_dtable[_85a],_85d=_85c.method_imp,_85e=new objj_method(_85c.method_name,_85b,_85c.method_types);
_85e.displayName=_85c.displayName;
_859.method_dtable[_85a]=_85e;
var _85f=_859.method_list.indexOf(_85c);
if(_85f!==-1){
_859.method_list[_85f]=_85e;
}else{
_859.method_list.push(_85e);
}
return _85d;
};
class_addProtocol=function(_860,_861){
if(!_861||class_conformsToProtocol(_860,_861)){
return;
}
(_860.protocol_list||(_860.protocol_list==[])).push(_861);
return true;
};
class_conformsToProtocol=function(_862,_863){
if(!_863){
return false;
}
while(_862){
var _864=_862.protocol_list,size=_864?_864.length:0;
for(var i=0;i<size;i++){
var p=_864[i];
if(p.name===_863.name){
return true;
}
if(protocol_conformsToProtocol(p,_863)){
return true;
}
}
_862=class_getSuperclass(_862);
}
return false;
};
class_copyProtocolList=function(_865){
var _866=_865.protocol_list;
return _866?_866.slice(0):[];
};
protocol_conformsToProtocol=function(p1,p2){
if(!p1||!p2){
return false;
}
if(p1.name===p2.name){
return true;
}
var _867=p1.protocol_list,size=_867?_867.length:0;
for(var i=0;i<size;i++){
var p=_867[i];
if(p.name===p2.name){
return true;
}
if(protocol_conformsToProtocol(p,p2)){
return true;
}
}
return false;
};
var _868=Object.create(null);
objj_allocateProtocol=function(_869){
var _86a=new objj_protocol(_869);
return _86a;
};
objj_registerProtocol=function(_86b){
_868[_86b.name]=_86b;
};
protocol_getName=function(_86c){
return _86c.name;
};
protocol_addMethodDescription=function(_86d,_86e,_86f,_870,_871){
if(!_86d||!_86e){
return;
}
if(_870){
(_871?_86d.instance_methods:_86d.class_methods)[_86e]=new objj_method(_86e,null,_86f);
}
};
protocol_addMethodDescriptions=function(_872,_873,_874,_875){
if(!_874){
return;
}
var _876=0,_877=_873.length,_878=_875?_872.instance_methods:_872.class_methods;
for(;_876<_877;++_876){
var _879=_873[_876];
_878[_879.method_name]=_879;
}
};
protocol_copyMethodDescriptionList=function(_87a,_87b,_87c){
if(!_87b){
return [];
}
var _87d=_87c?_87a.instance_methods:_87a.class_methods,_87e=[];
for(var _87f in _87d){
if(_87d.hasOwnProperty(_87f)){
_87e.push(_87d[_87f]);
}
}
return _87e;
};
protocol_addProtocol=function(_880,_881){
if(!_880||!_881){
return;
}
(_880.protocol_list||(_880.protocol_list=[])).push(_881);
};
var _882=Object.create(null);
objj_allocateTypeDef=function(_883){
var _884=new objj_typeDef(_883);
return _884;
};
objj_registerTypeDef=function(_885){
_882[_885.name]=_885;
};
typeDef_getName=function(_886){
return _886.name;
};
var _887=function(_888){
var meta=(((_888.info&(_821)))?_888:_888.isa);
if((_888.info&(_821))){
_888=objj_getClass(_888.name);
}
if(_888.super_class&&!((((_888.super_class.info&(_821)))?_888.super_class:_888.super_class.isa).info&(_822))){
_887(_888.super_class);
}
if(!(meta.info&(_822))&&!(meta.info&(_823))){
meta.info=(meta.info|(_823))&~(0);
_888.objj_msgSend=objj_msgSendFast;
_888.objj_msgSend0=objj_msgSendFast0;
_888.objj_msgSend1=objj_msgSendFast1;
_888.objj_msgSend2=objj_msgSendFast2;
_888.objj_msgSend3=objj_msgSendFast3;
meta.objj_msgSend=objj_msgSendFast;
meta.objj_msgSend0=objj_msgSendFast0;
meta.objj_msgSend1=objj_msgSendFast1;
meta.objj_msgSend2=objj_msgSendFast2;
meta.objj_msgSend3=objj_msgSendFast3;
_888.method_msgSend=_888.method_dtable;
meta.method_msgSend=meta.method_dtable;
meta.objj_msgSend0(_888,"initialize");
meta.info=(meta.info|(_822))&~(_823);
}
};
_objj_forward=function(self,_889){
var isa=self.isa,meta=(((isa.info&(_821)))?isa:isa.isa);
if(!(meta.info&(_822))&&!(meta.info&(_823))){
_887(isa);
}
var _88a=isa.method_msgSend[_889];
if(_88a){
return _88a.apply(isa,arguments);
}
_88a=isa.method_dtable[_88b];
if(_88a){
var _88c=_88a(self,_88b,_889);
if(_88c&&_88c!==self){
arguments[0]=_88c;
return _88c.isa.objj_msgSend.apply(_88c.isa,arguments);
}
}
_88a=isa.method_dtable[_88d];
if(_88a){
var _88e=isa.method_dtable[_88f];
if(_88e){
var _890=_88a(self,_88d,_889);
if(_890){
var _891=objj_lookUpClass("CPInvocation");
if(_891){
var _892=_891.isa.objj_msgSend1(_891,_893,_890),_9d=0,_894=arguments.length;
if(_892!=null){
var _895=_892.isa;
for(;_9d<_894;++_9d){
_895.objj_msgSend2(_892,_896,arguments[_9d],_9d);
}
}
_88e(self,_88f,_892);
return _892==null?null:_895.objj_msgSend0(_892,_897);
}
}
}
}
_88a=isa.method_dtable[_898];
if(_88a){
return _88a(self,_898,_889);
}
throw class_getName(isa)+" does not implement doesNotRecognizeSelector:. Did you forget a superclass for "+class_getName(isa)+"?";
};
class_getMethodImplementation=function(_899,_89a){
if(!((((_899.info&(_821)))?_899:_899.isa).info&(_822))){
_887(_899);
}
var _89b=_899.method_dtable[_89a]||_objj_forward;
return _89b;
};
var _89c=Object.create(null);
objj_enumerateClassesUsingBlock=function(_89d){
for(var key in _89c){
_89d(_89c[key]);
}
};
objj_allocateClassPair=function(_89e,_89f){
var _8a0=new objj_class(_89f),_8a1=new objj_class(_89f),_8a2=_8a0;
if(_89e){
_8a2=_89e;
while(_8a2.superclass){
_8a2=_8a2.superclass;
}
_8a0.allocator.prototype=new _89e.allocator;
_8a0.ivar_dtable=_8a0.ivar_store.prototype=new _89e.ivar_store;
_8a0.method_dtable=_8a0.method_store.prototype=new _89e.method_store;
_8a1.method_dtable=_8a1.method_store.prototype=new _89e.isa.method_store;
_8a0.super_class=_89e;
_8a1.super_class=_89e.isa;
}else{
_8a0.allocator.prototype=new objj_object();
}
_8a0.isa=_8a1;
_8a0.name=_89f;
_8a0.info=_820;
_8a0._UID=objj_generateObjectUID();
_8a1.isa=_8a2.isa;
_8a1.name=_89f;
_8a1.info=_821;
_8a1._UID=objj_generateObjectUID();
return _8a0;
};
var _7c7=nil;
objj_registerClassPair=function(_8a3){
_1[_8a3.name]=_8a3;
_89c[_8a3.name]=_8a3;
_1e9(_8a3,_7c7);
};
objj_resetRegisterClasses=function(){
for(var key in _89c){
delete _1[key];
}
_89c=Object.create(null);
_868=Object.create(null);
_882=Object.create(null);
_1ec();
};
class_createInstance=function(_8a4){
if(!_8a4){
throw new Error("*** Attempting to create object with Nil class.");
}
var _8a5=new _8a4.allocator();
_8a5.isa=_8a4;
_8a5._UID=objj_generateObjectUID();
return _8a5;
};
var _8a6=function(){
};
_8a6.prototype.member=false;
with(new _8a6()){
member=true;
}
if(new _8a6().member){
var _8a7=class_createInstance;
class_createInstance=function(_8a8){
var _8a9=_8a7(_8a8);
if(_8a9){
var _8aa=_8a9.isa,_8ab=_8aa;
while(_8aa){
var _8ac=_8aa.ivar_list,_8ad=_8ac.length;
while(_8ad--){
_8a9[_8ac[_8ad].name]=NULL;
}
_8aa=_8aa.super_class;
}
_8a9.isa=_8ab;
}
return _8a9;
};
}
object_getClassName=function(_8ae){
if(!_8ae){
return "";
}
var _8af=_8ae.isa;
return _8af?class_getName(_8af):"";
};
objj_lookUpClass=function(_8b0){
var _8b1=_89c[_8b0];
return _8b1?_8b1:Nil;
};
objj_getClass=function(_8b2){
var _8b3=_89c[_8b2];
if(!_8b3){
}
return _8b3?_8b3:Nil;
};
objj_getClassList=function(_8b4,_8b5){
for(var _8b6 in _89c){
_8b4.push(_89c[_8b6]);
if(_8b5&&--_8b5===0){
break;
}
}
return _8b4.length;
};
objj_getMetaClass=function(_8b7){
var _8b8=objj_getClass(_8b7);
return (((_8b8.info&(_821)))?_8b8:_8b8.isa);
};
objj_getProtocol=function(_8b9){
return _868[_8b9];
};
objj_getTypeDef=function(_8ba){
return _882[_8ba];
};
ivar_getName=function(_8bb){
return _8bb.name;
};
ivar_getTypeEncoding=function(_8bc){
return _8bc.type;
};
objj_msgSend=function(_8bd,_8be){
if(_8bd==nil){
return nil;
}
var isa=_8bd.isa;
if(!((((isa.info&(_821)))?isa:isa.isa).info&(_822))){
_887(isa);
}
var _8bf=isa.method_dtable[_8be]||_objj_forward;
switch(arguments.length){
case 2:
return _8bf(_8bd,_8be);
case 3:
return _8bf(_8bd,_8be,arguments[2]);
case 4:
return _8bf(_8bd,_8be,arguments[2],arguments[3]);
}
return _8bf.apply(_8bd,arguments);
};
objj_msgSendSuper=function(_8c0,_8c1){
var _8c2=_8c0.super_class;
arguments[0]=_8c0.receiver;
if(!((((_8c2.info&(_821)))?_8c2:_8c2.isa).info&(_822))){
_887(_8c2);
}
var _8c3=_8c2.method_dtable[_8c1]||_objj_forward;
return _8c3.apply(_8c0.receiver,arguments);
};
objj_msgSendSuper0=function(_8c4,_8c5){
return (_8c4.super_class.method_dtable[_8c5]||_objj_forward)(_8c4.receiver,_8c5);
};
objj_msgSendSuper1=function(_8c6,_8c7,arg0){
return (_8c6.super_class.method_dtable[_8c7]||_objj_forward)(_8c6.receiver,_8c7,arg0);
};
objj_msgSendSuper2=function(_8c8,_8c9,arg0,arg1){
return (_8c8.super_class.method_dtable[_8c9]||_objj_forward)(_8c8.receiver,_8c9,arg0,arg1);
};
objj_msgSendSuper3=function(_8ca,_8cb,arg0,arg1,arg2){
return (_8ca.super_class.method_dtable[_8cb]||_objj_forward)(_8ca.receiver,_8cb,arg0,arg1,arg2);
};
objj_msgSendFast=function(_8cc,_8cd){
return (this.method_dtable[_8cd]||_objj_forward).apply(_8cc,arguments);
};
var _8ce=function(_8cf,_8d0){
_887(this);
return this.objj_msgSend.apply(this,arguments);
};
objj_msgSendFast0=function(_8d1,_8d2){
return (this.method_dtable[_8d2]||_objj_forward)(_8d1,_8d2);
};
var _8d3=function(_8d4,_8d5){
_887(this);
return this.objj_msgSend0(_8d4,_8d5);
};
objj_msgSendFast1=function(_8d6,_8d7,arg0){
return (this.method_dtable[_8d7]||_objj_forward)(_8d6,_8d7,arg0);
};
var _8d8=function(_8d9,_8da,arg0){
_887(this);
return this.objj_msgSend1(_8d9,_8da,arg0);
};
objj_msgSendFast2=function(_8db,_8dc,arg0,arg1){
return (this.method_dtable[_8dc]||_objj_forward)(_8db,_8dc,arg0,arg1);
};
var _8dd=function(_8de,_8df,arg0,arg1){
_887(this);
return this.objj_msgSend2(_8de,_8df,arg0,arg1);
};
objj_msgSendFast3=function(_8e0,_8e1,arg0,arg1,arg2){
return (this.method_dtable[_8e1]||_objj_forward)(_8e0,_8e1,arg0,arg1,arg2);
};
var _8e2=function(_8e3,_8e4,arg0,arg1,arg2){
_887(this);
return this.objj_msgSend3(_8e3,_8e4,arg0,arg1,arg2);
};
method_getName=function(_8e5){
return _8e5.method_name;
};
method_copyReturnType=function(_8e6){
var _8e7=_8e6.method_types;
if(_8e7){
var _8e8=_8e7[0];
return _8e8!=NULL?_8e8:NULL;
}else{
return NULL;
}
};
method_copyArgumentType=function(_8e9,_8ea){
switch(_8ea){
case 0:
return "id";
case 1:
return "SEL";
default:
var _8eb=_8e9.method_types;
if(_8eb){
var _8ec=_8eb[_8ea-1];
return _8ec!=NULL?_8ec:NULL;
}else{
return NULL;
}
}
};
method_getNumberOfArguments=function(_8ed){
var _8ee=_8ed.method_types;
return _8ee?_8ee.length+1:((_8ed.method_name.match(/:/g)||[]).length+2);
};
method_getImplementation=function(_8ef){
return _8ef.method_imp;
};
method_setImplementation=function(_8f0,_8f1){
var _8f2=_8f0.method_imp;
_8f0.method_imp=_8f1;
return _8f2;
};
method_exchangeImplementations=function(lhs,rhs){
var _8f3=method_getImplementation(lhs),_8f4=method_getImplementation(rhs);
method_setImplementation(lhs,_8f4);
method_setImplementation(rhs,_8f3);
};
sel_getName=function(_8f5){
return _8f5?_8f5:"<null selector>";
};
sel_getUid=function(_8f6){
return _8f6;
};
sel_isEqual=function(lhs,rhs){
return lhs===rhs;
};
sel_registerName=function(_8f7){
return _8f7;
};
objj_class.prototype.toString=objj_object.prototype.toString=function(){
var isa=this.isa;
if(class_getInstanceMethod(isa,_8f8)){
return isa.objj_msgSend0(this,_8f8);
}
if(class_isMetaClass(isa)){
return this.name;
}
return "["+isa.name+" Object](-description not implemented)";
};
objj_class.prototype.objj_msgSend=_8ce;
objj_class.prototype.objj_msgSend0=_8d3;
objj_class.prototype.objj_msgSend1=_8d8;
objj_class.prototype.objj_msgSend2=_8dd;
objj_class.prototype.objj_msgSend3=_8e2;
objj_class.prototype.method_msgSend=Object.create(null);
var _8f8=sel_getUid("description"),_88b=sel_getUid("forwardingTargetForSelector:"),_88d=sel_getUid("methodSignatureForSelector:"),_88f=sel_getUid("forwardInvocation:"),_898=sel_getUid("doesNotRecognizeSelector:"),_893=sel_getUid("invocationWithMethodSignature:"),_8f9=sel_getUid("setTarget:"),_8fa=sel_getUid("setSelector:"),_896=sel_getUid("setArgument:atIndex:"),_897=sel_getUid("returnValue");
objj_eval=function(_8fb){
var url=_2.pageURL;
var _8fc=_2.asyncLoader;
_2.asyncLoader=NO;
var _8fd=_2.preprocess(_8fb,url,0);
if(!_8fd.hasLoadedFileDependencies()){
_8fd.loadFileDependencies();
}
_1._objj_eval_scope={};
_1._objj_eval_scope.objj_executeFile=_300.fileExecuterForURL(url);
_1._objj_eval_scope.objj_importFile=_300.fileImporterForURL(url);
var code="with(_objj_eval_scope){"+_8fd._code+"\n//*/\n}";
var _8fe;
_8fe=eval(code);
_2.asyncLoader=_8fc;
return _8fe;
};
_2.objj_eval=objj_eval;
_17b();
var _8ff=new CFURL(window.location.href),_900=document.getElementsByTagName("base"),_901=_900.length;
if(_901>0){
var _902=_900[_901-1],_903=_902&&_902.getAttribute("href");
if(_903){
_8ff=new CFURL(_903,_8ff);
}
}
if(typeof OBJJ_COMPILER_FLAGS!=="undefined"){
var _904={};
for(var i=0;i<OBJJ_COMPILER_FLAGS.length;i++){
switch(OBJJ_COMPILER_FLAGS[i]){
case "IncludeDebugSymbols":
_904.includeMethodFunctionNames=true;
break;
case "IncludeTypeSignatures":
_904.includeIvarTypeSignatures=true;
_904.includeMethodArgumentTypeSignatures=true;
break;
case "InlineMsgSend":
_904.inlineMsgSendFunctions=true;
break;
}
}
_7c5.setCurrentCompilerFlags(_904);
}
var _905=new CFURL(window.OBJJ_MAIN_FILE||"main.j"),_1e8=new CFURL(".",new CFURL(_905,_8ff)).absoluteURL(),_906=new CFURL("..",_1e8).absoluteURL();
if(_1e8===_906){
_906=new CFURL(_906.schemeAndAuthority());
}
_1cb.resourceAtURL(_906,YES);
_2.pageURL=_8ff;
_2.bootstrap=function(){
_907();
};
function _907(){
_1cb.resolveResourceAtURL(_1e8,YES,function(_908){
var _909=_1cb.includeURLs(),_9d=0,_90a=_909.length;
for(;_9d<_90a;++_9d){
_908.resourceAtURL(_909[_9d],YES);
}
_300.fileImporterForURL(_1e8)(_905.lastPathComponent(),YES,function(){
_17c();
_910(function(){
var _90b=window.location.hash.substring(1),args=[];
if(_90b.length){
args=_90b.split("/");
for(var i=0,_90a=args.length;i<_90a;i++){
args[i]=decodeURIComponent(args[i]);
}
}
var _90c=window.location.search.substring(1).split("&"),_90d=new CFMutableDictionary();
for(var i=0,_90a=_90c.length;i<_90a;i++){
var _90e=_90c[i].split("=");
if(!_90e[0]){
continue;
}
if(_90e[1]==null){
_90e[1]=true;
}
_90d.setValueForKey(decodeURIComponent(_90e[0]),decodeURIComponent(_90e[1]));
}
main(args,_90d);
});
});
});
};
var _90f=NO;
function _910(_911){
if(_90f||document.readyState==="complete"){
return _911();
}
if(window.addEventListener){
window.addEventListener("load",_911,NO);
}else{
if(window.attachEvent){
window.attachEvent("onload",_911);
}
}
};
_910(function(){
_90f=YES;
});
if(typeof OBJJ_AUTO_BOOTSTRAP==="undefined"||OBJJ_AUTO_BOOTSTRAP){
_2.bootstrap();
}
function _1e2(aURL){
if(aURL instanceof CFURL&&aURL.scheme()){
return aURL;
}
return new CFURL(aURL,_1e8);
};
objj_importFile=_300.fileImporterForURL(_1e8);
objj_executeFile=_300.fileExecuterForURL(_1e8);
objj_import=function(){
CPLog.warn("objj_import is deprecated, use objj_importFile instead");
objj_importFile.apply(this,arguments);
};
})(window,ObjectiveJ);
