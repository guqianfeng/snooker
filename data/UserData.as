package data 
{
	/**
	 * ...
	 * @author JackyGu
	 * 用户数据
	 */
	public class UserData extends Object{
		public var userid:int;//tbluser中的id
		public var name:String;//用户名，注意不是中文名，而是人人网的uid
		public var sysuserid:int;//sfs系统的id编号
		public var playerId:int;//用户在游戏房间内的编号
		public var userType:int;
		public var playTimes:int;
		public var winTimes:int;
		public var lossTimes:int;
		public var tieTimes:int;
		public var gold:int;
		public var score:int;
		public var grade:int;//用户等级
		public var tillUpGrade:int;//距离下一个等级需要的积分
		public var snsName:String;
		public var activeItemId:int;
		public var gunUsedTimes:int;
		public var gunTotalTimes:int;
		public var gunId:int;
		public var gunName:String;
		public var gunDescription:String;
		public var gunPictureClass:String;
		public var gunType:int;
		public var maxAngle:Number;
		public var power:Number;
		public var rank:int;//积分排名
		public var goldRank:int;//金币排名，财富排行
		public var quickestSingle:int;//单人最快速度记录
		public var totalUsers:int;//一共多少用户
		
		public function UserData(actionscriptObject:Object, playerId:int):void {
			//根据用户playerId返回用户复杂数据
			if (playerId == 1) {
				this.name = actionscriptObject.p1_userid;
				this.activeItemId = int(actionscriptObject.p1_activeItemId);
				this.sysuserid = int(actionscriptObject.p1_sysuserid);
				this.gold = int(actionscriptObject.p1_gold);
				this.gunDescription = actionscriptObject.p1_gundescription;
				this.gunId = int(actionscriptObject.p1_gunid);
				this.gunName = actionscriptObject.p1_gunname;
				this.gunPictureClass = actionscriptObject.p1_gunpictureclass;
				this.gunTotalTimes = int(actionscriptObject.p1_gunTotalTimes);
				this.gunType = int(actionscriptObject.p1_guntype);
				this.gunUsedTimes = int(actionscriptObject.p1_gunUsedTimes);
				this.lossTimes = int(actionscriptObject.p1_lossTimes);
				this.maxAngle = int(actionscriptObject.p1_maxAngle);
				this.playTimes = int(actionscriptObject.p1_playTimes);
				this.power = int(actionscriptObject.p1_power);
				this.score = int(actionscriptObject.p1_score);
				this.grade = int(actionscriptObject.p1_grade);
				this.tillUpGrade = int(actionscriptObject.p1_tillUpGrade);
				this.snsName = actionscriptObject.p1_snsname;
				this.tieTimes = int(actionscriptObject.p1_tieTimes);
				this.winTimes = int(actionscriptObject.p1_winTimes);
				this.userType = int(actionscriptObject.p1_userType);
				this.rank = int(actionscriptObject.p1_rank);
				this.goldRank = int(actionscriptObject.p1_goldRank);
				this.quickestSingle = int(actionscriptObject.p1_quickestSingle);
				this.totalUsers = int(actionscriptObject.p1_totalUsers);
			}else if (playerId == 2) {
				this.name = actionscriptObject.p2_userid;
				this.activeItemId = int(actionscriptObject.p2_activeItemId);
				this.sysuserid = int(actionscriptObject.p2_sysuserid);
				this.gold = int(actionscriptObject.p2_gold);
				this.gunDescription = actionscriptObject.p2_gundescription;
				this.gunId = int(actionscriptObject.p2_gunid);
				this.gunName = actionscriptObject.p2_gunname;
				this.gunPictureClass = actionscriptObject.p2_gunpictureclass;
				this.gunTotalTimes = int(actionscriptObject.p2_gunTotalTimes);
				this.gunType = int(actionscriptObject.p2_guntype);
				this.gunUsedTimes = int(actionscriptObject.p2_gunUsedTimes);
				this.lossTimes = int(actionscriptObject.p2_lossTimes);
				this.maxAngle = int(actionscriptObject.p2_maxAngle);
				this.playTimes = int(actionscriptObject.p2_playTimes);
				this.power = int(actionscriptObject.p2_power);
				this.score = int(actionscriptObject.p2_score);
				this.grade = int(actionscriptObject.p2_grade);
				this.tillUpGrade = int(actionscriptObject.p2_tillUpGrade);
				this.snsName = actionscriptObject.p2_snsname;
				this.tieTimes = int(actionscriptObject.p2_tieTimes);
				this.winTimes = int(actionscriptObject.p2_winTimes);
				this.userType = int(actionscriptObject.p2_userType);
				this.rank = int(actionscriptObject.p2_rank);
				this.goldRank = int(actionscriptObject.p2_goldRank);
				this.quickestSingle = int(actionscriptObject.p2_quickestSingle);
				this.totalUsers = int(actionscriptObject.p2_totalUsers);
			}
		}
		public function toString():String {
			return "name = " + name + ", activeItemId = " + activeItemId + ", gold = " + gold + ", gunName = " + gunName + ", gunPictureClass = " + gunPictureClass
				+ ", gunTotalTimes = " + gunTotalTimes + ", gunUsedTimes = " + gunUsedTimes + ", gunType = " + gunType + ", playerTimes = " + playTimes + ", winTimes = " 
				+ winTimes + ", score = " + score + ", power = " + power + ", maxAngle = " + maxAngle + ", userType = " + userType;
		}
	}

}