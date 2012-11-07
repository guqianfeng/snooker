package data 
{
	import Box2D.Common.Math.b2Vec2;
	import com.adobe.utils.IntUtil;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.media.Sound;
	/**
	 * ...
	 * @author Jacky Gu
	 */
	public class Config
	{
		public static const ipAddress:String = "125.65.110.84";
		public static const port:int = 9339;
		
		public static const tableX:int = 100;//球桌x
		public static const tableY:int = 20;//球桌y
		public static const tableWidth:int = 500;//球桌宽和高
		public static const tableFrameWidth:int = 10;//球桌边得宽度
		
		public static const RedPart:int = 1;//红方playerId
		public static const BlackPart:int = 2;//黑方playId
		
		//在棋盘外在套一个转45度角的大正方形，用于瞄准
		//这个正方形的4条边直线方程分别为LINE1,LINE2,LINE3,LINE4，对应的斜率k和截距a
		public static const k_1 = 1;
		public static const a_1 = -580;
		public static const k_2 = -1;
		public static const a_2 = 120;
		public static const k_3 = 1;
		public static const a_3 = 420;
		public static const k_4 = -1;
		public static const a_4 = 1120;
		
		public static const turnSeconds:int = 30;//每次击球限时秒数
		public static const alertSeconds:int = 8;//开始警告时的余下秒数
		//public static const MaxPrecisionAngle:Number = 5;//最大误差角度，例如如果是5，则代表击打将发生在10度得范围内
		
		public static const LaobanBallRadius:Number = 15;//老板球半径
		public static const SmallBallRadius:Number = 13;//子球放大后半径
		public static const SmallBallOriginalRadius:Number = 10;//子球原始半径
		
		public static const insideSquareLength:int = 350;//棋盘内部大方块的边长
		public static const insideSquareLeftTop:int = 75;//棋盘内部大方块在棋盘坐标内的位置
		public static const ltHole:Point = new Point(91.5 + tableX, 91.5 + tableY);//棋盘内部大方块四个角的位置
		public static const lbHole:Point = new Point(91.5 + tableX, 408.5 + tableY);
		public static const rbHole:Point = new Point(408.5 + tableX, 408.5 + tableY);
		public static const rtHole:Point = new Point(408.5 + tableX, 91.5 + tableY);
		public static const smallHoleRadius:int = 16;//四个角上圆圈的半径
		public static const upLineY:int = insideSquareLeftTop + tableY;
		public static const downLineY:int = insideSquareLeftTop + insideSquareLength + tableY;
		public static const leftLineX:int = insideSquareLeftTop + smallHoleRadius + tableX;
		public static const rightLineX:int = insideSquareLeftTop + insideSquareLength - smallHoleRadius + tableX;
		
		public static const BallQnty:uint = 33;//球的个数，包括一个老板球
		public static const FrameRate:int = 40;//帧频
		public static const laobanBallClassname:String = "laoban";//老板球的类名
		public static const wallName:String = "wall";
		public static const holeRadius:int = 30;//四个角的洞的半径
		public static const stopMinVelocityDiff:Number = 0.2;//用于检测粒子是否静止，数字越小越精确，但是时间越长
		public static const maxGunPull:int = 80;//枪棒后拉最长距离
		public static const placeQiziStep:uint = 5;//放置棋子是为了防止重叠，而移位的步长
		public static const passHoleMinSpeed:uint = 20;//最低速度
		public static var ifSound:Boolean = true;//是否播放音效
		
		//public static const MaxPower:Number = 50;//最大力量
		
		public static const wallDensity:int = 0;//墙体密度
		public static const laobanDensity:int = 5;//老板球密度
		public static const qiziDensity:int = 2;//棋子的密度
		
		public static const worldFriction:Number = 0.1;//碰撞体之间的摩擦力系数
		public static const wallFriction:Number = 0.1;//墙的摩擦力系数
		public static const worldRestitution:Number = 1;//世界的弹力系数
		public static const angularDamping:Number = 0.8;//角速度阻尼
		public static const linearDamping:Number = 0.7;//线速度阻尼，系数越大，阻力越大
		
		public static const holePositionArray:Array = new Array(new Point(54, 54), new Point(446, 54), new Point(54, 446), new Point(446, 446));
		public static const qiziOriginalArray:Array = new Array("black_shuai", "black_ju", "black_ju", "black_ma", "black_ma", "black_pao", "black_pao", 
			"black_zu", "black_zu", "black_zu", "black_zu", "black_zu", "black_xiang", "black_xiang", "black_shi", "black_shi", 
			"red_shuai", "red_ju", "red_ju", "red_ma", "red_ma", "red_pao", "red_pao", "red_zu", "red_zu", "red_zu", "red_zu", 
			"red_zu", "red_xiang", "red_xiang", "red_shi", "red_shi");
			
		public static var qiziArray:Array;
		public static function randomQiziArray(sequence:Array):void {
			//将qiziOriginalArray随机生产qiziArray，随机序列为sequence
			qiziArray = new Array();
			for (var i = 0; i < sequence.length; i++) {
				qiziArray.push(qiziOriginalArray[sequence[i]]);
			}
		}
		public static const qiziPosition:Array = new Array(
														   new Point(205, 25),
														   new Point(235, 25),
														   new Point(265, 25),
														   new Point(295, 25),
														   
														   new Point(205, 205),
														   new Point(235, 205),
														   new Point(265, 205),
														   new Point(295, 205),
														   
														   new Point(205, 235),
														   new Point(235, 235),
														   new Point(265, 235),
														   new Point(295, 235),
														   
														   new Point(205, 265),
														   new Point(235, 265),
														   new Point(265, 265),
														   new Point(295, 265),
														   
														   new Point(205, 295),
														   new Point(235, 295),
														   new Point(265, 295),
														   new Point(295, 295),
														   
														   new Point(205, 475),
														   new Point(235, 475),
														   new Point(265, 475),
														   new Point(295, 475),
														   
														   new Point(25, 205),
														   new Point(25, 235),
														   new Point(25, 265),
														   new Point(25, 295),

   														   new Point(475, 205),
														   new Point(475, 235),
														   new Point(475, 265),
														   new Point(475, 295));
		public static const laobanBollInitPosition:Array = new Array(new Point(250, 436), new Point(250, 440), new Point(250, 64), new Point(80, 80));
		
		public static const prepareGame_NOOPPONENT:String = "没有找到对战康乐球的对手！\n请选择继续寻找，或进入练习模式。";
		public static const prepareRoom_KO:String = "游戏初始化失败！请选择继续寻找，或进入练习模式。";
		public static const userUnloadBrower_OK:String = "对方已离开游戏，此局你胜出！\n请按确认按钮继续找其他玩家对战，或按取消按钮玩单机练习。";
		public static const opponentContinue:String = "对方想和你再玩一次，请按确认继续，或按取消退出。";
		public static const opponentExitToLobbyAfterFinishedGame:String = "对方已离开游戏，请按确认按钮找其他玩家，或者按练习模式进行单机练习。";
		public static const prepareGame_INVITE:String = " 邀请你一起对战康乐球，请选择是否接受？";
		public static const stopSingleGame:String = "您已终止练习模式，您可以重新来一次，或按取消回到游戏大厅。";
		public static const finishSingleGame:String = "恭喜！棋子已全部打完！" ;
		public static const ifContinueText:String = "是否和该用户继续对战，或按取消按钮退回游戏大厅";
		public static const gameStopAlert:String = "您正在双人对战游戏中，现在退出，将判对方胜！请确认是否退出。";
		
	}
}