/** 
* @link http://www.klstudio.com 
* @author Kinglong 
* @usage flash player 7 
* @version 0.1 
*/  
package org.slg.Utils
{
	import flash.net.SharedObject;
	import flash.display.*;
	
	public class Cookie extends MovieClip{  
		private var _time:Number;  
		private var _name:String;  
    	private var _so:SharedObject;  
		
    	public function Cookie(name:String,time:Number)
		{          
        	_name = name;//(name == null)?"klstudio":name;  
        	_time = time;//(time == NaN)?36000:time;  
        	_so = SharedObject.getLocal(_name,"/");  
		}
     	
		public function clearTimeOut():void
		{  
         	var obj:Object = _so.data.cookie;  
         	if(obj == null)
			{  
             	return;  
         	}  
         	for(var key in obj){  
            	if(obj[key] == undefined || obj[key].time == undefined || isTimeOut(obj[key].time)){  
                	delete obj[key];  
            	}  
        	}  
         	_so.data.cookie = obj;  
         	_so.flush();  
     	}  
     private function isTimeOut(time:Number):Boolean{  
         var today:Date = new Date();
         if (time + _time * 1000 < today.getTime()) return true;
		 else return false;
     }  
       
     public function getTime():Number{  
         return _time;  
     }     
     public function getName():String{  
         return _name;  
     }  
     public function clear():void{  
         _so.clear();  
     }
     public function put(key:String,value:Object):void{  
        var today:Date = new Date();  
         key = "key_"+key;  
        value.time = today.getTime();  
        if(_so.data.cookie == undefined){  
            var obj:Object = {};  
            obj[key] = value;  
            _so.data.cookie = obj;  
         }else{  
             _so.data.cookie[key] = value;  
         }  
         _so.flush();  
     }  
    public function remove(key:String):void {  
         if (contain(key)) {  
            delete _so.data.cookie["key_" + key];  
             _so.flush();  
         }  
     }  
     public function get(key:String):Object{       
         return contain(key)?_so.data.cookie["key_"+key]:null;  
     }     
     public function contain(key:String):Boolean{  
         key = "key_" + key;
         return _so.data.cookie != undefined && _so.data.cookie[key] != undefined;  
    }  
}  
}