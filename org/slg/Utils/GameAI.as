package org.slg.Utils
{
	
	/**
	 * ...
	 * @author ...
	 */
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	import flash.sampler.NewObjectSample;
	import flash.system.ApplicationDomain;
	import org.slg.Map.*;
	import org.slg.Map.data.*;
	import org.slg.Unit.data.*;
	import org.slg.Events.UnitEvent;
	import org.slg.Events.PathFindEvent;
	import org.slg.Config;
	import de.polygonal.ds.Array2;
	import flash.utils.*;
	import org.casalib.util.ArrayUtil;
	import com.hexagonstar.util.debug.Debug;
	import de.polygonal.ds.HashMap;
	
	public class GameAI extends EventDispatcher
	{
		private var mapStatus:Array2;//从mapStatus.mapStatus中获取，mapStatus::MapData
		private var unitArray:Array2;//从mapObject对象中获取每个格子中的Unit对象
		private var tileArray:Array2;
		private var unitQueue:Array;//所有在场景中的Unit数组
		private var baseCity:Array;//各方城堡的坐标
		
		private var dbuffer:Array2;			//当前Unit可攻击范围内所有攻击点的对象数组
		private var walkableArray:Array2;	//当前Unit可以走动的范围。数据结构：walkable=0/1, distance=起点开始的距离, path={寻路数组}
		
		private var unit:Unit;
		private var mapSize:int;
		private var startPos:Point;
		
		private var pathArray:Array;//专门用于寻路的数组，因为每次寻路会因为底座的不同而不同，另外，也通过此数组缩小搜索范围，从而提高速度
		private var pathFindArray:Array = new Array();
		private var currentRow, currentCol:int;
		private var pathfindId:int = 0;
		private var marchPathFindId:int = 0;
		public var targetPoint:Point = new Point(20, 17);
		private var marchMinDistance:int = 999;
		private var marchTo:Array;//行军状态时可选的目的点
		
		
		public function GameAI(map:MapData, thisUnit:Unit, allUnitsArrary:Array = null) 
		{
			mapStatus = map.status;
			unitArray = map.unit;
			tileArray = map.tile;
			
			baseCity = map.playerBase;
			unitQueue = allUnitsArrary;
			unit = thisUnit;
			mapSize = map.mapHeight;
			
			initDataArray();
		}
		
		private function initDataArray():void
		{
			//trace("dbuffer初始化");
			dbuffer = new Array2(mapSize, mapSize);
			walkableArray = new Array2(mapSize, mapSize);
			dbuffer.fill(new AttackablePointData());
			walkableArray.fill(new WalkArea());
		}
		//=======================================================================================
		//伤害算法,行军步数算法,获取攻击对象算法，获取行军目标算法, 对方最弱者算法
		//=======================================================================================
		public static function getDamagePoint(thisUnit:Unit, targetUnit:Unit):Number
		{
			//伤害值算法
			//var dmg:Number = thisUnit.data.dmg * (1 + (thisUnit.data.atk - targetUnit.data.dfs) * 0.01);
			var dmg:int = thisUnit.data.dmg + ((thisUnit.data.atk - targetUnit.data.dfs) >= 1?0.001:0.001) * (thisUnit.data.atk - targetUnit.data.dfs) * thisUnit.data.dmg;
			//trace("dmg1=" + thisUnit.data.dmg + ", atk1=" + thisUnit.data.atk + ", dfs2=" + targetUnit.data.dfs + ", 伤害值: " + dmg);
			if (dmg > 1)
				dmg = Math.floor(dmg);
			else
				dmg = 1;
			//DMG1 + (IF(ATK1 - DEF2) >= 1, 0.001, 0.001)) * (ATK1 - DEF2) * DMG1
			return dmg;
		}
		private function get marchStep():int
		{
			//计算行军步长算法
			var speed:int;
			//if (unit.data.rng_max > 1) speed = Math.floor(unit.data.spd / 3);//如果是远程攻击单位，行军距离为1/3XSPEED
			//else speed = Math.floor(unit.data.spd / 2);//如果是近程攻击单位，行军距离为1/2
			//speed = Math.random() * (unit.data.spd + 1) + 1;//随意走
			speed = unit.data.spd;//最大行走
			return speed;
		}
		private function getBestAttackTarget(buff:Array2):AttackablePointData
		{
			//获取最佳攻击目标算法，如果没有null
			var minHP:int = 999;
			var minDistance:int = 999;
			var maxDamage:int = -999;
			var bestAPD_hp:AttackablePointData;
			var bestAPD_distance:AttackablePointData;
			var bestAPD_damage:AttackablePointData;
			var bestAPD:AttackablePointData = null;
			
			//计算dBuffer中的所有点，找出最小HP，最大伤害值，最短行进距离
			for (var i:int = 0; i < buff.height; i++)
			{
				for (var j:int = 0; j < buff.width; j++)
				{
					var apd:AttackablePointData = buff.get(j, i);
					if (apd.hasTarget)
					{
						//如果有攻击目标
						if (apd.targetHP < minHP) { minHP = apd.targetHP; bestAPD_hp = apd;}
						if (apd.targetDistance < minDistance) { minDistance = apd.targetDistance; bestAPD_distance = apd;}
						if (apd.targetDMG > maxDamage) { maxDamage = apd.targetDMG; bestAPD_damage = apd;}
					}
				}
			}
			//评价顺序算法
			if (minDistance != 999)
			{
				//就近原则优先
				bestAPD = bestAPD_distance;
			}
			else if (minHP != 999)
			{
				//就弱原则其次
				bestAPD = bestAPD_hp;
			}
			else if (maxDamage != -999)
			{
				//就上海最大化原则最后
				bestAPD = bestAPD_damage;
			}
			return bestAPD;
		}
		private function getMarchTargetPoint(mc:Unit):Point
		{
			//如果没有攻击目标，获取行军的目标点
			var tp:Point = null;
			switch(mc.data.marchTarget)//获取目标方向的点坐标
			{
				case "city"://对方城堡方向
					if (unit.data.team == 1 && unit.data.team == 2)
					{
						//如果己方为东北方
						if (baseCity[2] != null) tp = baseCity[2];
						else if (baseCity[3] != null) tp = baseCity[3];
						else trace("对方城堡位置不存在");
					}
					else if (unit.data.team == 3 && unit.data.team == 4)
					{
						//如果己方为西南方
						if (baseCity[0] != null) tp = baseCity[0];
						else if (baseCity[1] != null) tp = baseCity[1];
						else trace("对方城堡位置不存在");
					}
					break;
				case "special"://特殊物品方向
					trace("行军方向为特殊物品方向");
					break;
				case "weak"://对方最弱者方向
					var u:Unit = getWeakestOpponent(unit);
					if (u != null)
						tp = u.position;
					else 
						trace("不存在最弱的对手");
					break;
			}
			return tp;
		}

		private function getWeakestOpponent(u:Unit):Unit
		{
			//获取对方最弱者
			var minHP:int = 999;
			var re:Unit = null;
			for (var i:int = 0; i < unitQueue.length; i++)
			{
				if (unitQueue[i].data.isLive && minHP > unitQueue[i].data.hp && unitQueue[i].data.team != u.data.team)
				{
					minHP = unitQueue[i].data.hp;
					re = unitQueue[i];
				}
			}
			return re;
		}
		
		//=======================================================================================
		//常用工具代码
		//=======================================================================================
		private function getNormalDistance(p1:Point, p2:Point):int
		{
			//获取一般距离，不是通过寻路算法得到的距离
			return Math.abs(p2.x - p1.x) + Math.abs(p2.y - p1.y);
		}
		
		private function getDistance(start:Point, end:Point, speed:int):void
		{
			//通过寻路获取距离
			//用A*算法求两点之间需要走的步数
			var pathFinder = new FindPath(pathArray);
			//需要设定pathFinder的事件，侦听寻路完成，否则寻路速度太慢，会造成寻路冲突
			pathFinder.addEventListener(PathFindEvent.PATH_FIND_FINISHED, onPathFoundHandler);
			pathFinder.addEventListener(PathFindEvent.PATH_FIND_FAIL, onPathFoundFailHandler);
			//trace("speed: " + speed + ", xPos: " + String(end.x - start.x + speed) + ", yPos: " + String(end.y - start.y + speed));
			pathFinder.getPath4(new Point(speed, speed), new Point(end.x - start.x + speed, end.y - start.y + speed));
		}
		
		private function onPathFoundHandler(evt:PathFindEvent):void
		{
			evt.currentTarget.removeEventListener(PathFindEvent.PATH_FIND_FINISHED, onPathFoundHandler);
			evt.currentTarget.removeEventListener(PathFindEvent.PATH_FIND_FAIL, onPathFoundFailHandler);
			var pfResult:Array = evt.params as Array;
			var distance:int = pfResult.length - 1;
			//trace(unit.position + "->" + currentCol + ", " + currentRow + " = " + distance + "->" + mapStatus[currentCol][currentRow] + " -> " + pfResult);
			var st:int = mapStatus.get(currentCol, currentRow);
			var canPathFound:Boolean;
			if (magicId == 0)
			{
				canPathFound = (st == 0) || (st == 2 && unit.data.canFly);
			}
			else
			{
				//另外，如果是技能攻击的话，有单位的格子也是可以寻到
				canPathFound = (st == 0) || (st == 2 && unit.data.canFly) || unitArray.get(currentCol, currentRow) != null;
			}
			if(canPathFound && distance <= unit.data.spd)
			{
				//如果目标点不是起点，且目标点可以走动，或者对于飞行单位不可走动但是可以飞行的砖块。且目标点到起点的最短路径<=spd
				//trace("可以走动(" + currentCol + "," + currentRow + ")");
				var walkArea:WalkArea = new WalkArea();
				walkArea.distance = distance;
				walkArea.path = trans(pfResult);//将小矩阵寻路的结果转换成整图寻路结果
				walkArea.walkable = 0;
				walkableArray.set(currentCol, currentRow, walkArea);//如果可以走动设为0
				if (unit.data.standsize == 2)
				{
					//如果是占4格的单位,显示所有能够放置的范围。其中只有第一条是主路径，能够行走
					walkableArray.set(currentCol, currentRow, walkArea);//主行走路径
					//walkableArray.set(currentCol + 1, currentRow + 1, walkArea);
					//walkableArray.set(currentCol, currentRow + 1, walkArea);
					//walkableArray.set(currentCol + 1, currentRow, walkArea);
				}
			}
			pathfindId++
			getAreaByTile();
		}
		
		private function onPathFoundFailHandler(evt:PathFindEvent):void
		{
			evt.currentTarget.removeEventListener(PathFindEvent.PATH_FIND_FAIL, onPathFoundFailHandler);
			evt.currentTarget.removeEventListener(PathFindEvent.PATH_FIND_FINISHED, onPathFoundHandler);
			pathfindId++;
			getAreaByTile();
		}
		
		
		private function trans(dat:Array):Array
		{
			//将寻路数组中的小矩阵坐标转整图坐标
			var re:Array = new Array();
			for (var i:int = 0; i < dat.length; i++)
			{
				var x:int = dat[i].x - unit.data.spd + startPos.x;
				var y:int = dat[i].y - unit.data.spd + startPos.y;
				re.push(new Point(x, y));
			}
			return re;
		}
		//=======================================================================================
		//以下是行走范围处理
		//=======================================================================================
		public function get walkableArea():Array2
		{
			return walkableArray;
		}
		private var magicId:int;
		private var walkSpeed:int;
		private var searchId:int;
		public function getArea(start:Point, _magicId:int = 0):void
		{
			//可移动范围的格子，二维，0-不可移动，1-可移动
			magicId = _magicId;
			startPos = start;
			if (magicId == 0)
				walkSpeed = unit.data.spd;//如果magicId为0，则寻找行走路径
			else
				walkSpeed = unit.data.magicArray[magicId].rng_max;//如果是使用技能，则找出技能作用范围
				
			//缩小寻路地图范围，局限在以当前所在位置为中心，长宽为2 x walkSpeed + 1的范围内。否则，全局搜索耗时太长
			getPathFindArea(startPos, walkSpeed, (magicId == 0));//如果是寻找行走路径，需要避开单位，如果是技能寻路，无需避开单位
			if (unit.data.standsize != 2)
			{
				pathfindId = 0;
				searchId = 0;//全象限搜索
				searchType = "small";
				currentCenter = startPos;
				this.addEventListener(PathFindEvent.ONESIDE_PATH_FOUND, onOneSidePathFound);
				getAreaByTile();
			}
			else
			{
				//处理2x2单位寻路
				searchId = 1;//从第一象限开始搜索
				searchType = "big";
				getBigStandPath(startPos);
			}
		}
		private var searchType:String;//搜索类型，小单位"small", 大单位"big"
		private function getBigStandPath(center:Point):void
		{
			//处理2x2单位行走路径
			if (searchId <= 4)
			{
				pathfindId = 0;
				this.addEventListener(PathFindEvent.ONESIDE_PATH_FOUND, onOneSidePathFound);
				currentCenter = getBigStandCenter(center, searchId);
				getAreaByTile();
			}
			else
			{
				//4个方向全部搜索完毕
				var params:Object = walkableArea;
				dispatchEvent(new PathFindEvent(PathFindEvent.PATH_FIND_COMPLETED, { mc:unit, path:params } ));
			}
		}
		private var currentCenter:Point;
		private function getBigStandCenter(center:Point, searchId:int):Point
		{
			//返回2x2单位在不同象限搜索时的起点坐标
			var p:Point;
			var a:int = center.x;
			var b:int = center.y;
			switch(searchId)
			{
				case 1://第一象限
					p = new Point(a + 1, b);
					break;
				case 2:
					p = new Point(a, b);
					break;
				case 3:
					p = new Point(a, b + 1);
					break;
				case 4:
					p = new Point(a + 1, b + 1);
					break;
			}
			return p;
		}
		private function getSearchArea(id:int):Object
		{
			//获取搜索象限
			var obj:Object = new Object();
			var speed:int = unit.data.spd;
			switch(id)
			{
				case 0://全部象限
					obj.fromX = -speed;
					obj.toX = speed;
					obj.fromY = -speed;
					obj.toY = speed;
					break;
				case 1://第一象限
					obj.fromX = 0;
					obj.toX = speed;
					obj.fromY = -speed;
					obj.toY = 0;
					break;
				case 2://第二象限
					obj.fromX = -speed;
					obj.toX = 0;
					obj.fromY = -speed;
					obj.toY = 0;
					break;
				case 3://第三象限
					obj.fromX = -speed;
					obj.toX = 0;
					obj.fromY = 0;
					obj.toY = speed;
					break;
				case 4://第四象限
					obj.fromX = 0;
					obj.toX = speed;
					obj.fromY = 0;
					obj.toY = speed;
					break;
			}
			return obj;
		}
		private function getAreaByTile():void
		{
			//fromX...参考getAttackArea部分,作为象限限定，注意有正负号
			var smallMapWidth:int = walkSpeed * 2 + 1;
			var maxPathfindId:int = smallMapWidth * smallMapWidth;//搜索长度
			var row:int = currentCenter.y;
			var col:int = currentCenter.x;
			
			if (pathfindId < maxPathfindId)
			{
				currentCol = col - walkSpeed + pathfindId % smallMapWidth;//x
				currentRow = row - walkSpeed + Math.floor(pathfindId / smallMapWidth);//y
				var st:int = mapStatus.get(currentCol, currentRow);
				var preCheck:Boolean = true;
				//过滤掉不在要搜索象限中的点
				var searchArea:Object = getSearchArea(searchId);
				//trace("pos: " + new Point(currentCol, currentRow) + " in " + new Point(col + searchArea.fromX, row + searchArea.fromY) + "->" + new Point(col + searchArea.toX, row + searchArea.toY));
				preCheck = (currentCol >= col + searchArea.fromX) && (currentRow >= row + searchArea.fromY) && (currentCol <= col + searchArea.toX) && (currentRow <= row + searchArea.toY);
				//if (preCheck) trace("象限预审通过");
				//else trace("象限预审未通过");
				if (magicId == 0)
				{
					//如果是寻找行走路径
					//如果该点的数据存在，合法，且预审通过（即ABS(y-row)+abs(x-col)<=walkSpeed
					//另外，删掉了	&& !(currentCol == col && currentRow == row)，即当前所在格子也是可以走动的范围
					preCheck = preCheck && !isNaN(st) && (st == 0 || (st == 2 && unit.data.canFly)) && !(currentCol == col && currentRow == row) && Math.abs(currentRow - row) + Math.abs(currentCol - col) <= walkSpeed;
				}
				else
				{
					//如果是寻找技能路径，不需要判断飞行情况，并且把有单位的格子也作为可以寻到的路径
					var u:Unit = unitArray.get(currentCol, currentRow) as Unit;
					preCheck = preCheck && !isNaN(st) && (st == 0 || st == 2 || u != null) && !(currentCol == col && currentRow == row) && (Math.abs(currentRow - row) + Math.abs(currentCol - col) <= walkSpeed);
				}
				
				if (preCheck)
				{
					//trace(new Point(currentCol, currentRow) + ", preCheck=" + preCheck);
					getDistance(currentCenter, new Point(currentCol, currentRow), walkSpeed);
				}
				else
				{
					//如果预审不通过，不需要pathfind，直接递归
					//trace("不需要递归 " + mapStatus[currentCol][currentRow]);
					pathfindId++;
					getAreaByTile();
				}
			}
			else
			{
				//寻路结束
				dispatchEvent(new PathFindEvent(PathFindEvent.ONESIDE_PATH_FOUND));
			}
		}
		private function onOneSidePathFound(evt:PathFindEvent):void
		{
			evt.currentTarget.removeEventListener(PathFindEvent.ONESIDE_PATH_FOUND, onOneSidePathFound);
			if (searchType == "small")
			{
				var params:Object = walkableArea;
				dispatchEvent(new PathFindEvent(PathFindEvent.PATH_FIND_COMPLETED, { mc:unit, path:params } ));
			}
			else if (searchType == "big")
			{
				searchId++;
				getBigStandPath(startPos);
			}
		}
		private function getPathFindArea(center:Point, range:int, isWalkPathfound:Boolean = true):void
		{
			//获取小范围寻路数组
			pathArray = new Array();
			for (var i:int = center.y - range; i <= center.y + range; i++)
			{
				//var str:String = "";
				var pathFindRow:Array = new Array();
				for (var j:int = center.x - range; j <= center.x + range; j++)
				{
					try{
					if (unit.data.standsize == 2)
					{
						//对于占4格的单位
						if (unit.data.canFly)
						{
							//对于可以飞行的单位
							if ((mapStatus.get(j, i) == 0 || mapStatus.get(j, i) == 2) && (mapStatus.get(j + 1, i) == 0 || mapStatus.get(j + 1, i) == 2) && (mapStatus.get(j + 1, i + 1) == 0 || mapStatus.get(j + 1, i + 1) == 2) && (mapStatus.get(j, i + 1) == 0 || mapStatus.get(j, i + 1) == 2))
							{
								//只有当所检测的格子右边，下边，右下的三个格子全部为可以走动，该格才能设为走动
								pathFindRow.push(0);
							}
							else if (!isWalkPathfound && unitArray.get(j, i) != null)
							{
								//如果是使用技能寻路，且格子上有单位，也设为可以走动
								pathFindRow.push(0);
							}
							else
							{
								pathFindRow.push(1);
							}
						}
						else
						{
							//对于不能飞行的单位
							if (mapStatus.get(j, i) == 0 && mapStatus.get(j + 1, i) == 0 && mapStatus.get(j + 1, i + 1) == 0 && mapStatus.get(j, i + 1) == 0)
							{
								//只有当所检测的格子右边，下边，右下的三个格子全部为可以走动，该格才能设为走动
								pathFindRow.push(0);
							}
							else if (!isWalkPathfound && unitArray.get(j, i) != null)
							{
								pathFindRow.push(0);
							}
							else
							{
								pathFindRow.push(1);
							}
						}
					}
					else
					{
						//对于占一格的单位
						if (unit.data.canFly)
						{
							//如果是飞行单位
							if (mapStatus.get(j, i) == 0 || mapStatus.get(j, i) == 2)
							{
								//对于可飞行和可走动砖块都可以走
								pathFindRow.push(0);
							}
							else if (!isWalkPathfound && unitArray.get(j, i) != null)
							{
								pathFindRow.push(0);
							}
							else
							{
								pathFindRow.push(1);
							}
						}
						else
						{
							//如果是行走单位
							if (mapStatus.get(j, i) == 0)
							{
								//只有行走砖块才能走
								pathFindRow.push(0);
							}
							else if (!isWalkPathfound && unitArray.get(j, i) != null)
							{
								pathFindRow.push(0);
							}
							else
							{
								pathFindRow.push(1);
							}
						}
					}
					}
					catch (err:Error)
					{
						trace(err);
					}
				}
				pathArray.push(pathFindRow);
			}
		}
		
		
		//===============================================================================
		//以下是攻击算法
		//===============================================================================
		public var attackRange:Array2;
		public function searchAttackPoint(_walkRange:Array2):Array2
		{
			//可攻击范围格子的数组，二维，数组对象为AttackablePointData
			//只用于机器人AI处理，玩家不需要进行此处理
			for (var i:int = 0; i < _walkRange.height; i++)
			{
				for (var j:int = 0; j < _walkRange.width; j++)
				{
					if (_walkRange.get(j, i).walkable == 0)
					{
						//只对可以走动的格子进行处理
						//trace("==" + new Point(j, i));
						getAttackRange(j, i);//获取可走动范围格子的攻击数据
					}
				}
			}
			return dbuffer;
		}
		public function getAttackRange(x:int, y:int):Array
		{
			var re:Array;
			attackRange = new Array2(mapSize, mapSize);
			attackRange.fill(new Object());//0为不可攻击范围，初始化
			targetArray = new Array();//目标数组
			var standsize:int = unit.data.standsize;//根据不同的standsize设定查找攻击范围的中心点和坐标象限
			if (standsize == 1)
			{
				getAttackableDataByTile(x, y, -unit.data.rng_max, unit.data.rng_max, -unit.data.rng_max, unit.data.rng_max);
			}
			if (standsize == 2)
			{
				//如果攻击单位是2x2的，需要做特殊处理，即将该单位所在的4个格子分成4个象限，每个象限分别处理
				getAttackableDataByTile(x + 1, y, 0, unit.data.rng_max, -unit.data.rng_max, 0);//第一象限
				getAttackableDataByTile(x, y, -unit.data.rng_max, 0, -unit.data.rng_max, 0);//第二象限
				getAttackableDataByTile(x, y + 1, -unit.data.rng_max, 0, 0, unit.data.rng_max);//第三象限
				getAttackableDataByTile(x + 1, y + 1, 0, unit.data.rng_max, 0, unit.data.rng_max);//第四象限
			}
			//将targetArray中的数据进行整理，把相同目标单位，但是距离最短的攻击点保留
			/*
			var distandHash:HashMap = new HashMap();//hash表，key为攻击对象Unit, 值为到达可攻击该单位要走的最短距离
			trace("targetArray.length = " + targetArray.length);
			for (var i:int = 0; i < targetArray.length; i++)
			{
				var obj:Object = new Object();
				obj = targetArray[i];
				trace(unit.data.name + "行动目标[" + i + "]: " + obj.unit.data.name + ", 距离：" + obj.distance);
				if (!distandHash.containsKey(obj.unit)) distandHash.insert(obj.unit, obj.distance);
			}
			//if(!distandHash.isEmpty()) trace("Distance Hash: " + distandHash.dump());
			distandHash = null;
			*/
			return targetArray;
		}
		private var targetArray:Array;
		private function getAttackableDataByTile(_col:int, _row:int, fromX:int, toX:int, fromY:int, toY:int):void
		{
			//获取某点可攻击范围内的对方AttackablePointData对象
			//用于玩家和机器人攻击范围搜索
			//from代表搜索的范围起点，to代表搜索范围终点。
			//如十字全范围搜索，则fromX=-unit.data.rng_max, toX=unit.data.rng_max, fromY = -unit.data.rng_max, toY = unit.data.rng_max
			//如只搜索以(_col, _row)为中心的第一象限，则fromX = 0, toX = unit.data.rng_max, fromY = -unit.data.rng_max, toY = 0
			//如只搜索以(_col, _row)为中心的第二象限，则fromX = -unit.data.rng_max, toX = 0, fromY = -unit.data.rng_max, toY = 0
			//如只搜索以(_col, _row)为中心的第三象限，则fromX = -unit.data.rng_max, toX = 0, fromY = 0, toY = unit.data.rng_max
			//如只搜索以(_col, _row)为中心的第四象限，则fromX = 0, toX = unit.data.rng_max, fromY = 0, toY = unit.data.rng_max
			//注意fromX<toX, fromY<toY;
			
			var x, y:int;
			
			var min_range = unit.data.rng_min;
			var max_range = unit.data.rng_max;
			
			var attatckType:String = unit.data.attackType;
			var hasTarget:Boolean = false;
			var isInAttackableArea:Boolean = false;//是否在可攻击范围内
			
			var attackRangeObject:Object;//攻击范围数据对象，包括canAttack：能否攻击，和距离distance
			//trace("x: " + fromX + "->" + toX + ", y: " + fromY + "->" + toY);
			for (y = _row + fromY; y <= _row + toY; y++)
			{
				for (x = _col + fromX; x <= _col + toX; x++)
				{
					//trace("攻击点: " + new Point(x, y));
					if (x<=mapSize && x>=0 && y<=mapSize && y>=0 && !(x == _col && y == _row))
					{
						//如果攻击点在地图范围内,并且不是中心点（即当前单位所在位置）
						hasTarget = false;
						isInAttackableArea = false;
						if (attatckType == "normal")
						{
							//如果是面攻击方式
							var distance:int = getNormalDistance(new Point(x, y), new Point(_col, _row));//攻击距离
							if (distance >= min_range && distance <= max_range)
							{
								//如果攻击距离在Unit的范围之内
								isInAttackableArea = true;//无论是否有目标都设为true
								//攻击数据对象
								attackRangeObject = new Object();
								attackRangeObject.canAttack = true;
								attackRangeObject.distance = distance;
								attackRange.set(x, y, attackRangeObject);
								if (unitArray.get(x, y) != null && unitArray.get(x, y) != undefined && unitArray.get(x, y).data.team != unit.data.team && unitArray.get(x, y).data.isLive) 
								{
									hasTarget = true;//如果攻击范围的格子中unitArray有单位，且该单位和本方不在一个队伍
									var t:Unit = unitArray.get(x, y) as Unit;
									//var obj:Object = { unit:t, walkTarget:new Point(_col, _row), distance:getNormalDistance(new Point(_col, _row), startPos) };
									//trace("格子:" + new Point(_col, _row) + "中找到目标" + t.data.name);
									targetArray.push(t);
								}
							}
						}
						else if (attatckType == "line")
						{
							//如果是线攻击方式，判断是否在一条线上，并且范围在min_range 和 max_range 之间
							if (x == _col && y != _row) distance = Math.abs(y - _row);
							if (y == _row && x != _col) distance = Math.abs(x - _col);
							if ((x==_col && distance<=max_range && distance>=min_range)||(y==_row && distance<=max_range && distance>=min_range))
							{
								attackRangeObject = new Object();
								isInAttackableArea = true;//无论是否有目标都设为true
								attackRangeObject.canAttack = true;
								attackRangeObject.distance = distance;
								attackRange.set(x, y, attackRangeObject);
								if (unitArray.get(x, y) != null && unitArray.get(x, y) != undefined && unitArray.get(x, y).data.team != unit.data.team && unitArray.get(x, y) != null && unitArray.get(x, y).data.isLive) 
								{
									hasTarget = true;//如果攻击范围的格子中unitArray有单位，且该单位和本方不在一个队伍
									t = unitArray.get(x, y) as Unit;
									//obj = { unit:t, walkTarget:new Point(_col, _row), distance:getNormalDistance(new Point(_col, _row), startPos) };
									//trace("格子:" + new Point(_col, _row) + "中找到目标" + t.data.name);
									targetArray.push(t);
								}
							}
						}
						//以下代码用于机器人找目标
						if (unit.data.userId == Config.computerTeam)
						{
							var re:AttackablePointData = new AttackablePointData();
							if (hasTarget)
							{
								//如果找到目标
								re.x = x;
								re.y = y;
								re.attackFrom = new Point(_col, _row);
								re.targetHP = unitArray.get(x, y).data.hp;
								re.targetDMG = getDamagePoint(unit, unitArray.get(x, y));
								re.targetDistance = getNormalDistance(currentCenter, re.attackFrom);
								//trace("行走范围内找到攻击目标: " + re.toString());
								
								re.hasTarget = true;
								re.inAttackedArea = true;
								dbuffer.set(_col, _row, re);
							}
							else if(isInAttackableArea)
							{
								//trace("行走范围内没有目标,但是在攻击范围之内");
								re.hasTarget = false;
								re.inAttackedArea = true;
								if (!dbuffer.get(_col, _row).hasTarget) 
								{
									dbuffer.set(_col, _row, re);
								}
							}
						}
					}
				}
			}
		}
		
		//=====================================================================================
		//机器人智能处理
		//=====================================================================================
		private var walkRange:Array2;
		private var walkRangeForPathFind:Array;//生成全图0-1图，供FindPath类使用。只能是1维数组
		
		private function getWalkRangeForPathFind():void
		{
			walkRangeForPathFind = new Array();
			for (var i:int = 0; i < mapStatus.height; i++)
			{
				var rowArr:Array = new Array();
				for (var j:int = 0; j < mapStatus.width; j++)
				{
					if (mapStatus.get(j, i) == 0 || (mapStatus.get(j, i) == 2 && unit.data.canFly))
					{
						rowArr.push(0);//可以走动
					}
					else
						rowArr.push(1);//不可以走动
				}
				walkRangeForPathFind.push(rowArr);
			}
		}
		public function checkDBuffer(buff:Array2, _walkRange:Array2):void
		{
			//处理在攻击范围内的所有格子数据，即AI的核心部分
			walkRange = _walkRange;
			marchTo = new Array();
			//trace("==========");
			//trace("1");
			getWalkRangeForPathFind();
			//trace("2");
			var bestAPD:AttackablePointData = getBestAttackTarget(buff);//获取最佳攻击对象
			//trace("3");
			if (bestAPD != null && bestAPD.attackFrom == this.startPos)
			{
				//===================================================================================================原地攻击
				//trace("4");
				dispatchMarchEvent(null, new Point(bestAPD.x, bestAPD.y));
			}
			else if(bestAPD != null && bestAPD.attackFrom != this.startPos)
			{
				//===================================================================================================移动后攻击
				//通过传进来的walkRange中WalkArea类直接获得
				var a:Point = bestAPD.attackFrom;
				//trace("5");
				var wr:WalkArea = walkRange.get(a.x, a.y) as WalkArea;
				if (wr != null)
				{
					//trace("5.3");
					if (wr.path == null || wr.path.length == 0)
					{
						//trace("5.5");
						dispatchMarchEvent(null, new Point(bestAPD.x, bestAPD.y));//=======================================原地攻击
					}
					else
					{
						//trace("5.6");
						dispatchMarchEvent(walkRange.get(a.x, a.y).path, new Point(bestAPD.x, bestAPD.y));
					}
					//trace("6");
				}
			}
			else if (bestAPD == null)
			{
				//如果没有攻击目标
				//trace("7");
				var attackRate:int = Math.random() * 100;//产生攻击偏好随机数，用于和用户的攻击偏好对比，从而产生攻击概率
				//trace("8");
				if (attackRate < unit.data.attackAttend)
				{
					//如果随机数落在攻击偏好中
					//trace("找不到攻击对象，攻击种子: " + attackRate + ", 开始行军");
					//trace("9");
					targetPoint = getMarchTargetPoint(unit);
					//trace("10");
					if (targetPoint != null)
					{
						//trace("10.4");
						getNearestPointFromWalkableArea(targetPoint);//=============================================移动后待命
					}
					else
					{
						//trace("10.8");
						dispatchMarchEvent(null, null);//===========================================================原地待命
					}
				}
				else
				{
					//如果随机数落在攻击偏好外，则不动。============================================================原地待命
					//trace("找不到攻击对象，攻击种子: " + attackRate + ", 不移动");
					//trace("11");
					dispatchMarchEvent(null, null);
				}
			}
		}
		private function dispatchMarchEvent(path:Array, target:Point):void
		{
			var obj:Object = new Object();
			obj.path = path;
			obj.target = target;
			obj.mc = unit;
			this.dispatchEvent(new PathFindEvent(PathFindEvent.MARCH_PATH_FOUND, obj));					
		}
		
		//=============================================================================================
		private function getNearestPointFromWalkableArea(point:Point):void
		{
			//在walkRange中找到离目标点最近的位置
			var row:int = unit.position.y;//单位当前所在位置
			var col:int = unit.position.x;
			var speed:int = marchStep;
			//trace("A");
			var smallMapWidth:int = speed * 2 + 1;
			var maxPathfindId:int = speed == 0? 0: smallMapWidth * smallMapWidth;//搜索长度
			//只需要搜索可行走范围中最外圈，中间不需要寻路
			if (marchPathFindId < maxPathfindId)
			{
				//trace("B====" + marchPathFindId + ", maxPathfindId: " + maxPathfindId);
				currentCol = col - speed + marchPathFindId % smallMapWidth;
				currentRow = row - speed + Math.floor(marchPathFindId / smallMapWidth);
				
				if (walkRange.get(currentCol, currentRow) != undefined && walkRange.get(currentCol, currentRow).walkable == 0 
					&& !(currentCol == col && currentRow == row) && Math.abs(currentRow - row) + Math.abs(currentCol - col) <= speed)
				//如果该点的数据存在，且可以走到，且预审通过（即ABS(y-row)+abs(x-col)<=speed
				{
					//trace("C");
					getMarchDistance(point, new Point(currentCol, currentRow));
				}
				else
				{
					//trace("D");
					//如果预审不通过，不需要pathfind，直接递归
					marchPathFindId++;
					getNearestPointFromWalkableArea(point);
				}
			}
			else
			{
				//寻路结束，获取marchTo数组，其中保存着每个可以移动点中到达目标的距离: distance和行走目标点: point
				//trace("E");
				var bestPosition:Point = getBestMarchPoint(marchTo, point);//从marchTo数组中找出最佳点
				if (bestPosition == null)
				{
					trace("原地待命");
					dispatchMarchEvent(null, null);//======================================================================原地待命
				}
				else
				{
					var pa:Array = walkRange.get(bestPosition.x, bestPosition.y).path;//找到最佳点的寻路数组
					if (pa == null || pa.length == 0)
					{
						trace("原地待命");
						dispatchMarchEvent(null, null);//======================================================================原地待命
					}
					else
					{
						trace("移动后待命");
						dispatchMarchEvent(pa, null);//========================================================================移动后待命
					}
				}
			}
		}
		var minMarchDistance:int;
		private function getBestMarchPoint(marchArray:Array, target:Point):Point
		{
			//trace("D.3");
			var bestPoint:Point;
			sortMarchArray(marchTo);//排序，Flash自带的排序有问题
			//trace("D.4: marchTo.length=" + marchTo.length);
			if (marchTo.length > 0)
			{
				minMarchDistance = marchArray[0].distance;
				//trace("D.5");
				var minStepMarchPoint:Array = marchArray.filter(getMinimStepPoint);//将有与目标点相同距离的点全部找出，生成数组
				//trace("D.8");
				//对所有有相同距离的点，通过勾股定理找出直线最近点
				var bestDistance:int = 999;
				for (var i:int = 0; i < minStepMarchPoint.length; i++)
				{
					var linedistance:int = lineDistance(minStepMarchPoint[i].point, target);
					if (linedistance < bestDistance)
					{
						bestDistance = linedistance;
						bestPoint = minStepMarchPoint[i].point;
					}
				}
				//trace("5");
			}
			else
			{
				bestPoint = null;
			}
			return bestPoint;
		}
		private function sortMarchArray(arr:Array):void
		{
			for (var i:int = 0; i < arr.length - 1; i++)
			{
				for (var j:int = 0; j < arr.length - i - 1; j++)
				{
					if (arr[j].distance > arr[j + 1].distance)
					{
						var a:Object = arr[j];
						arr[j] = arr[j + 1];
						arr[j + 1] = a;
					}
				}
			}
		}
		private function getMinimStepPoint(element:*, index:int, arr:Array):Boolean
		{
			return element.distance == minMarchDistance;
		}
		private function lineDistance(a:Point, b:Point):Number
		{
			//通过勾股定理找直线距离,为了加快速度，只返回平方值
			return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
		}
		private function getMarchDistance(startPoint:Point, endPoint:Point):void
		{
			//用A*算法求两点之间需要走的步数
			//trace("C.1");
			var pathFinder = new FindPath(walkRangeForPathFind);
			//trace("C.2");
			//需要设定pathFinder的事件，侦听寻路完成，否则寻路速度太慢，会造成寻路冲突
			pathFinder.addEventListener(PathFindEvent.PATH_FIND_FINISHED, onOneMarchPathFoundHandler);
			pathFinder.addEventListener(PathFindEvent.PATH_FIND_FAIL, onMarchPathFoundFailHandler);
			pathFinder.getPath4(startPoint, endPoint);
		}
		
		private function onOneMarchPathFoundHandler(evt:PathFindEvent):void
		{
			evt.currentTarget.removeEventListener(PathFindEvent.PATH_FIND_FINISHED, onOneMarchPathFoundHandler);
			//trace("C.3");
			var pfResult:Array = evt.params as Array;
			var distance:int = pfResult.length - 1;
			
			var obj:Object = new Object();
			obj.point = (evt.currentTarget as FindPath).endPoint;
			obj.distance = distance;
			marchTo.push(obj);//将每个可以走到的点和目的点的距离放入数组，原因，需要得到一个与目的点距离相同的所有点的集合
			marchPathFindId++;
			getNearestPointFromWalkableArea(targetPoint);
		}
		
		private function onMarchPathFoundFailHandler(evt:PathFindEvent):void
		{
			evt.currentTarget.removeEventListener(PathFindEvent.PATH_FIND_FAIL, onMarchPathFoundFailHandler);
			//trace("C.5");
			marchPathFindId++;
			getNearestPointFromWalkableArea(targetPoint);
		}
	}
}
