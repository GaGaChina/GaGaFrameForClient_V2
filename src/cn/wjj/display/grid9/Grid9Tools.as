package cn.wjj.display.grid9
{
	import cn.wjj.g;
	
	/**
	 * 九宫格工具类
	 * 
	 * @author GaGa
	 */
	public class Grid9Tools 
	{
		
		public function Grid9Tools() { }
		
		
		/**
		 * 设置信息的最小尺寸
		 * 2面九宫格
		 * 		1 0 (1为水平拉伸)
		 * 3面九宫格
		 * 		0 1 2 (1为水平拉伸)
		 * 6面九宫格
		 * 		0 1 2
		 * 		3 4 5 (1, 3, 5 3个方向, 4 四方向拉伸)
		 * 9面九宫格
		 * 		0 1 2 (1水平拉伸)
		 * 		3 4 5 (3, 5 垂直拉伸 , 4 四方向拉伸)
		 * 		6 7 8 (7水平拉伸)
		 * 
		 * @param	o
		 * @param	error	当出现尺寸不复合规范的时候,弹出警告回调函数
		 */
		public static function setInfoMinSize(o:Grid9Info, error:Function):void
		{
			//获取一个合适的宽度或高度
			switch (o.face)
			{
				case 2:
					o.width = o.list[1].r_width + o.list[0].r_width;
					o.height = o.list[0].r_height;
					if (o.height < o.list[1].r_height)
					{
						o.height = o.list[1].r_height;
					}
					break;
				case 3:
					o.width = o.list[0].r_width + o.list[1].r_width + o.list[2].r_width;
					o.height = o.list[0].r_height;
					if (o.height < o.list[1].r_height)
					{
						o.height = o.list[1].r_height;
					}
					if (o.height < o.list[2].r_height)
					{
						o.height = o.list[2].r_height;
					}
					if (o.list[0].r_height != o.list[2].r_height)
					{
						error("九宫高度不一致 : " + o.list[0].r_height + " - " + o.list[1].r_height + " - " + o.list[2].r_height);
					}
					break;
				case 6:
					o.width = o.list[0].r_width + o.list[1].r_width + o.list[2].r_width;
					if (o.width < (o.list[3].r_width + o.list[4].r_width + o.list[5].r_width))
					{
						o.width = o.list[3].r_width + o.list[4].r_width + o.list[5].r_width;
					}
					o.height = o.list[0].r_height + o.list[3].r_height;
					if (o.height < o.list[1].r_height + o.list[4].r_height)
					{
						o.height = o.list[1].r_height + o.list[4].r_height;
					}
					if (o.height < o.list[3].r_height + o.list[6].r_height)
					{
						o.height = o.list[3].r_height + o.list[6].r_height;
					}
					if (o.list[0].r_width != o.list[2].r_width)
					{
						error("九宫上面对角宽度 : " + o.list[0].r_width + " - " + o.list[2].r_width);
					}
					if (o.list[0].height != o.list[2].height)
					{
						error("九宫上面对角高度 : " + o.list[0].r_height + " - " + o.list[2].r_height);
					}
					break;
				case 9:
					o.width = o.list[0].r_width + o.list[1].r_width + o.list[2].r_width;
					if (o.width < (o.list[3].r_width + o.list[4].r_width + o.list[5].r_width))
					{
						o.width = o.list[3].r_width + o.list[4].r_width + o.list[5].r_width;
					}
					if (o.width < (o.list[6].r_width + o.list[7].r_width + o.list[8].r_width))
					{
						o.width = o.list[6].r_width + o.list[7].r_width + o.list[8].r_width;
					}
					o.height = o.list[0].r_height + o.list[3].r_height + o.list[6].r_height;
					if (o.height < o.list[1].r_height + o.list[4].r_height + o.list[7].r_height)
					{
						o.height = o.list[1].r_height + o.list[4].r_height + o.list[7].r_height;
					}
					if (o.height < o.list[2].r_height + o.list[5].r_height + o.list[8].r_height)
					{
						o.height = o.list[2].r_height + o.list[5].r_height + o.list[8].r_height;
					}
					if (o.list[0].r_width != o.list[2].r_width)
					{
						error("九宫上面对角宽度 : " + o.list[0].r_width + " - " + o.list[2].r_width);
					}
					if (o.list[0].height != o.list[2].height)
					{
						error("九宫上面对角高度 : " + o.list[0].r_height + " - " + o.list[2].r_height);
					}
					
					if (o.list[6].r_width != o.list[8].r_width)
					{
						error("九宫下面对角宽度 : " + o.list[0].r_width + " - " + o.list[2].r_width);
					}
					if (o.list[6].height != o.list[8].height)
					{
						error("九宫下面对角高度 : " + o.list[0].r_height + " - " + o.list[2].r_height);
					}
					break;
			}
		}
		
		
		/**
		 * 通过旋转来改变旋转后的尺寸
		 * @param	o	每个节点的数据
		 */
		public static function setPieceRSize(o:Grid9InfoPiece):void
		{
			switch (o.r) 
			{
				case 0://0度 (OK)
					o.r_x = o.x;
					o.r_y = o.y;
					o.r_width = o.width;
					o.r_height = o.height;
					break;
				case 1://90度,顺时针旋转, 高 宽互换, x.y坐标 (OK)
					o.r_width = o.height;
					o.r_height = o.width;
					o.r_x = -o.height - o.y;
					o.r_y = o.x;
					break;
				case 2://180度, 高宽不变, x,y坐标和高宽互差 (OK)
					o.r_x = -o.width - o.x;
					o.r_y = -o.height - o.y;
					o.r_width = o.width;
					o.r_height = o.height;
					break;
				case 3://270度 (OK)
					o.r_width = o.height;
					o.r_height = o.width;
					o.r_x = -o.x;
					o.r_y = -o.width - o.x;
					break;
				case 4://水平对折 (OK)
					o.r_x = -o.width - o.x;
					o.r_y = o.y;
					o.r_width = o.width;
					o.r_height = o.height;
					break;
				case 5://垂直对折 (OK)
					o.r_x = o.x;
					o.r_y = -o.height - o.y;
					o.r_width = o.width;
					o.r_height = o.height;
					break;
			}
		}
	}
}