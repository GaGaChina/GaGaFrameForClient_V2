package cn.wjj.display.grid9
{
	import cn.wjj.g;
	import cn.wjj.display.ui2d.U2Bitmap;
	import cn.wjj.display.ui2d.U2Timer;
	import cn.wjj.gagaframe.client.factory.FShape;
	import flash.display.DisplayObject;
	
	/**
	 * 对 Grid9Sprite 进行操作
	 * 
	 * 每个顶点不管U2还是普通的都要移动到顶点对齐
	 * 
	 * 
	 * @author GaGa
	 */
	public class Grid9EngineSprite 
	{
		
		/** 临时字符串 **/
		private static var __s:String;
		/** 临时字符串 **/
		private static var __s2:String;
		/** 临时int **/
		private static var __i:int;
		/** 临时Boolean **/
		private static var __b:Boolean;
		/** 临时Boolean **/
		private static var __b2:Boolean;
		
		/** 计算的时候的临时变量 **/
		private static var __sx:Number, __sy:Number;
		
		public function Grid9EngineSprite() { }
		
		
		/**
		 * 对本对象及子对象数据进行设置
		 * 缓存全部的显示对象
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
		 * @param	display		显示对象
		 * @param	o			信息
		 * @param	cache		是否启用播放缓存控制
		 */
		public static function init(display:Grid9Sprite, o:Grid9Info, width:uint = 0, height:uint = 0, sx:Number = 1, sy:Number = 1, refresh:Boolean = false):void
		{
			
			if (display.timer)
			{
				display.timer.display = null;
				display.timer.dispose();
				display.timer = null;
			}
			Grid9Sprite.clear(display);
			if (width == 0 || height == 0)
			{
				width = o.width;
				height = o.height;
			}
			//开始根据width和height分配高度
			display.data = o;
			display.setSize(width, height, sx, sy, refresh);
		}
		
		/**
		 * 当是2面的时候
		 * 1 0 (1为水平拉伸)
		 */
		internal static function face_2(d9:Grid9Sprite, w:uint, h:uint, _ox:int, _oy:int):void
		{
			//临时变量
			var _i1:int, _i2:int, _i3:int, _i4:int, _i5:int;
			//边角的图片
			var _d:DisplayObject;
			//遮罩
			var _s:FShape;
			//临时的时间
			var _t:U2Timer;
			//临时变量
			var _w:int, _h:int;
			//临时变量,定位下一张图用的位置坐标
			var _nx:int, _ny:int;
			//临时变量,宽度, 高度最后个需要遮罩么
			var _wm:Boolean, _hm:Boolean;
			//临时变量,宽度, 高度最后个需要遮罩么
			var _wmd:Boolean, _hmd:Boolean;
			var _p:Grid9InfoPiece;
			//---------------------------------------------------------------------------第一张图(开始)右边的图
			if (d9.data.list.length > 0 && d9.data.list[0])
			{
				_p = d9.data.list[0];
				if (d9.list.length == 0 || d9.list[0] == null)
				{
					if (_p.pathType == 1)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.u2PathDisplay(_p.path);
						}
						else
						{
							_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
						}
						if (_d)
						{
							_t = (_d as Object).timer;
						}
					}
					else if (_p.pathType == 2)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
							
						}
						else
						{
							_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
						}
					}
					else
					{
						_d = U2Bitmap.instance();
						if (g.grid9.gridUseDefGFile)
						{
							g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
						}
						else
						{
							g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
						}
					}
					d9.list[0] = _d;//_d == null, 会自动push进去
				}
				else
				{
					_d = d9.list[0];
				}
				if (_d)
				{
					switch (_p.r)
					{
						case 0:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 1:
							if (_d.rotation != 90)_d.rotation = 90;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 2:
							if (_d.rotation != 180)_d.rotation = 180;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 3:
							if (_d.rotation != 270)_d.rotation = 270;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 4:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != -1)_d.scaleX = -1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 5:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != -1)_d.scaleY = -1;
							break;
					}
					if (d9.data.list.length > 1)
					{
						//这个开始的X坐标, 这个的宽度, + 偏移量
						//100 - 20 = 80开始 + 偏移量 + 整体偏移量
						_d.x = _p.r_x + w - _p.r_width + _ox;
					}
					else
					{
						_d.x = _p.r_x + w + _ox;
					}
					_d.y = _p.r_y + _oy;
					d9.addChild(_d);
				}
			}
			else
			{
				_d = d9.list[0];
				if (_d)
				{
					if ("dispose" in _d)
					{
						(_d as Object).dispose();
					}
					if (_d.parent)
					{
						_d.parent.removeChild(_d);
					}
				}
				d9.list[0] = null;
			}
			//---------------------------------------------------------------------------第一张图(结束)
			//---------------------------------------------------------------------------第二张图(开始)
			if (d9.data.list.length > 1 && d9.data.list[1])
			{
				_p = d9.data.list[1];
				//有图片数据
				if (d9.data.list[0])
				{
					_w = w - d9.data.list[0].r_width;
					_nx = d9.data.list[0].r_width;
				}
				else
				{
					_w = w;
					_nx = 0;
				}
				_h = h;
				_ny = 0;
				if (_p.layout == 1)
				{
					//-------------------------------------------------------------------第二张图拉伸(开始)
					if (d9.no1 == 0)
					{
						d9.no1 = 1;
						if (_p.pathType == 1)
						{
							if (_t)
							{
								if (g.grid9.gridUseDefGFile)
								{
									_d = g.dfile.u2PathDisplay(_p.path, true, _t.time);
								}
								else
								{
									_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path, true, _t.time);
								}
							}
							else
							{
								if (g.grid9.gridUseDefGFile)
								{
									_d = g.dfile.u2PathDisplay(_p.path);
								}
								else
								{
									_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
								}
							}
						}
						else if (_p.pathType == 2)
						{
							if (g.grid9.gridUseDefGFile)
							{
								_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
							}
							else
							{
								_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
							}
						}
						else
						{
							_d = U2Bitmap.instance();
							if (g.grid9.gridUseDefGFile)
							{
								g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
							}
							else
							{
								g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
							}
						}
						d9.list[1] = _d;
					}
					else
					{
						_d = d9.list[1];
					}
					if (_d)
					{
						switch (_p.r)
						{
							case 0:
								if (_d.rotation != 0)_d.rotation = 0;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 1:
								if (_d.rotation != 90)_d.rotation = 90;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 2:
								if (_d.rotation != 180)_d.rotation = 180;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 3:
								if (_d.rotation != 270)_d.rotation = 270;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 4:
								if (_d.rotation != 0)_d.rotation = 0;
								if (_d.scaleX != -1)_d.scaleX = -1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 5:
								if (_d.rotation != 0)_d.rotation = 0;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != -1)_d.scaleY = -1;
								break;
						}
						__sx = _w / _p.r_width;
						__sy = _h / _p.r_height;
						_d.x = _p.r_x * __sx + _ox + _nx;
						_d.y = _p.r_y * __sy + _oy + _ny;
						_d.scaleX = _d.scaleX * __sx;
						_d.scaleY = _d.scaleY * __sy;
						d9.addChild(_d);
					}
					//-------------------------------------------------------------------第二张图拉伸(结束)
				}
				else if(_p.layout == 2)
				{
					//-------------------------------------------------------------------第二张图平铺(开始)
					_i1 = Math.ceil(_w / _p.r_width);//平铺数量
					_i2 = Math.ceil(_h / _p.r_height);//纵向数量
					if (_p.mask)
					{
						if (_w % _p.r_width == 0)
						{
							if (_wm)_wm = false;
						}
						else
						{
							if (_wm == false)_wm = true;
						}
						
						if (_h % _p.r_height == 0)
						{
							if (_hm)_hm = false;
						}
						else
						{
							if (_hm == false)_hm = true;
						}
					}
					else
					{
						if (_wm)_wm = false;
						if (_hm)_hm = false;
					}
					//开始递归排列
					_i5 = 0;
					for (_i4 = 0; _i4 < _i2; _i4++)
					{
						for (_i3 = 0; _i3 < _i1; _i3++)
						{
							if (d9.no1 > _i5)
							{
								_d = d9.list[_i5];
								if (_d.mask)
								{
									_s = _d.mask as FShape;
									_d.mask = null;
									_s.dispose();
									_s = null;
								}
							}
							else
							{
								if (_p.pathType == 1)
								{
									if (_t)
									{
										if (g.grid9.gridUseDefGFile)
										{
											_d = g.dfile.u2PathDisplay(_p.path, true, _t.time);
										}
										else
										{
											_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path, true, _t.time);
										}
									}
									else
									{
										if (g.grid9.gridUseDefGFile)
										{
											_d = g.dfile.u2PathDisplay(_p.path);
										}
										else
										{
											_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
										}
										if (_d)
										{
											_t = (_d as Object).timer;
										}
									}
								}
								else if (_p.pathType == 2)
								{
									if (g.grid9.gridUseDefGFile)
									{
										_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
									}
									else
									{
										_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
									}
								}
								else
								{
									_d = U2Bitmap.instance();
									if (g.grid9.gridUseDefGFile)
									{
										g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
									}
									else
									{
										g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
									}
								}
								d9.list.push(_d);
								d9.no1++;
							}
							_i5++;
							switch (_p.r) 
							{
								case 0:
									if (_d.rotation != 0)_d.rotation = 0;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 1:
									if (_d.rotation != 90)_d.rotation = 90;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 2:
									if (_d.rotation != 180)_d.rotation = 180;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 3:
									if (_d.rotation != 270)_d.rotation = 270;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 4:
									if (_d.rotation != 0)_d.rotation = 0;
									if (_d.scaleX != -1)_d.scaleX = -1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 5:
									if (_d.rotation != 0)_d.rotation = 0;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != -1)_d.scaleY = -1;
									break;
							}
							_d.x = _i3 * _p.r_width + _ox + _p.r_x + _nx;
							_d.y = _i4 * _p.r_height + _oy + _p.r_y + _ny;
							if (_wm && (_i3 + 1) == _i1)
							{
								if (_wmd == false)_wmd = true;
							}
							else if (_wmd)
							{
								_wmd = false;
							}
							if (_hm && (_i4 + 1) == _i2)
							{
								if (_hmd == false)_hmd = true;
							}
							else if (_hmd)
							{
								_hmd = false;
							}
							if (_wmd || _hmd)
							{
								_s = FShape.instance();
								if (_wmd && _hmd)
								{
									// 起点, 本小块宽度, 本小块高度
									_s.graphics.drawRect(_d.x - _p.r_x, _d.y - _p.r_y, ( -(_i3 - 1) * _p.r_width + _w), ( -(_i4 - 1) * _p.r_height) + _h);
								}
								else if (_wmd)
								{
									_s.graphics.drawRect(_d.x - _p.r_x, _d.y - _p.r_y, ( -(_i3 - 1) * _p.r_width + _w), _p.r_height);
								}
								else
								{
									_s.graphics.drawRect(_d.x - _p.r_x, _d.y - _p.r_y, _p.r_width, ( -(_i4 - 1) * _p.r_height) + _h);
								}
								_s.graphics.endFill();
								_s.x = _d.x;
								_s.y = _d.y;
								_d.mask = _s;
								d9.addChild(_s);
								d9.addChild(_d);
							}
							else
							{
								d9.addChild(_d);
							}
						}
					}
					//递归结束
					//-------------------------------------------------------------------第二张图平铺(结束)
				}
			}
			else
			{
				//没有第二张数据
				if (d9.no1 != 0)
				{
					var delList:Vector.<DisplayObject> = d9.list.splice(1, d9.no1);
					for each (_d in delList) 
					{
						if ("dispose" in _d)
						{
							(_d as Object).dispose();
						}
						if (_d.parent)
						{
							_d.parent.removeChild(_d);
						}
					}
					g.speedFact.d_vector(DisplayObject, delList);
					delList = null;
					d9.no1 = 0;
				}
			}
			//---------------------------------------------------------------------------第二张图(结束)
		}
		
		/**
		 * 当是3面的时候
		 * 0 1 2 (1为水平拉伸)
		 *  no1  中间的变化图片
		 */
		internal static function face_3(d9:Grid9Sprite, w:uint, h:uint, _ox:int, _oy:int):void
		{
			//临时变量
			var _i1:int, _i2:int, _i3:int, _i4:int, _i5:int;
			//边角的图片
			var _d:DisplayObject;
			//遮罩
			var _s:FShape;
			//临时的时间
			var _t:U2Timer;
			//临时变量
			var _w:int, _h:int;
			//临时变量,定位下一张图用的位置坐标
			var _nx:int, _ny:int;
			//临时变量,宽度, 高度最后个需要遮罩么
			var _wm:Boolean, _hm:Boolean;
			//临时变量,宽度, 高度最后个需要遮罩么
			var _wmd:Boolean, _hmd:Boolean;
			var _p:Grid9InfoPiece;
			//---------------------------------------------------------------------------第一张图(开始)
			if (d9.data.list.length > 0 && d9.data.list[0])
			{
				_p = d9.data.list[0];
				if (d9.list.length == 0 || d9.list[0] == null)
				{
					if (_p.pathType == 1)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.u2PathDisplay(_p.path);
						}
						else
						{
							_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
						}
						if (_d)
						{
							_t = (_d as Object).timer;
						}
					}
					else if (_p.pathType == 2)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
						}
						else
						{
							_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
						}
					}
					else
					{
						_d = U2Bitmap.instance();
						if (g.grid9.gridUseDefGFile)
						{
							g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
						}
						else
						{
							g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
						}
					}
					d9.list[0] = _d;//_d == null, 会自动push进去
				}
				else
				{
					_d = d9.list[0];
				}
				if (_d)
				{
					switch (_p.r)
					{
						case 0:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 1:
							if (_d.rotation != 90)_d.rotation = 90;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 2:
							if (_d.rotation != 180)_d.rotation = 180;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 3:
							if (_d.rotation != 270)_d.rotation = 270;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 4:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != -1)_d.scaleX = -1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 5:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != -1)_d.scaleY = -1;
							break;
					}
					_d.x = _p.r_x + _ox;
					_d.y = _p.r_y + _oy;
					d9.addChild(_d);
				}
			}
			else
			{
				_d = d9.list[0];
				if (_d)
				{
					if ("dispose" in _d)
					{
						(_d as Object).dispose();
					}
					if (_d.parent)
					{
						_d.parent.removeChild(_d);
					}
				}
				d9.list[0] = null;
			}
			//---------------------------------------------------------------------------第一张图(结束)
			//---------------------------------------------------------------------------第二张图(开始)
			if (d9.data.list.length > 1 && d9.data.list[1])
			{
				_p = d9.data.list[1];
				//有图片数据
				if (d9.data.list.length > 2 && d9.data.list[0] && d9.data.list[1])
				{
					_w = w - d9.data.list[0].r_width - d9.data.list[2].r_width;
					_nx = d9.data.list[0].r_width;
				}
				else if (d9.data.list[0])
				{
					_w = w - d9.data.list[0].r_width;
					_nx = d9.data.list[0].r_width;
				}
				else if (d9.data.list.length > 1 && d9.data.list[2])
				{
					_w = w - d9.data.list[2].r_width;
					_nx = 0;
				}
				else
				{
					_w = w;
					_nx = 0;
				}
				_h = h;
				_ny = 0;
				if (_p.layout == 1)
				{
					//-------------------------------------------------------------------第二张图拉伸(开始)
					if (d9.no1 == 0)
					{
						d9.no1 = 1;
						if (_p.pathType == 1)
						{
							if (_t)
							{
								if (g.grid9.gridUseDefGFile)
								{
									_d = g.dfile.u2PathDisplay(_p.path, true, _t.time);
								}
								else
								{
									_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path, true, _t.time);
								}
							}
							else
							{
								if (g.grid9.gridUseDefGFile)
								{
									_d = g.dfile.u2PathDisplay(_p.path);
								}
								else
								{
									_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
								}
							}
						}
						else if (_p.pathType == 2)
						{
							if (g.grid9.gridUseDefGFile)
							{
								_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
							}
							else
							{
								_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
							}
						}
						else
						{
							_d = U2Bitmap.instance();
							if (g.grid9.gridUseDefGFile)
							{
								g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
							}
							else
							{
								g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
							}
						}
						d9.list[1] = _d;
					}
					else
					{
						_d = d9.list[1];
					}
					if (_d)
					{
						switch (_p.r)
						{
							case 0:
								if (_d.rotation != 0)_d.rotation = 0;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 1:
								if (_d.rotation != 90)_d.rotation = 90;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 2:
								if (_d.rotation != 180)_d.rotation = 180;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 3:
								if (_d.rotation != 270)_d.rotation = 270;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 4:
								if (_d.rotation != 0)_d.rotation = 0;
								if (_d.scaleX != -1)_d.scaleX = -1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 5:
								if (_d.rotation != 0)_d.rotation = 0;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != -1)_d.scaleY = -1;
								break;
						}
						__sx = _w / _p.r_width;
						__sy = _h / _p.r_height;
						_d.x = _p.r_x * __sx + _ox + _nx;
						_d.y = _p.r_y * __sy + _oy + _ny;
						_d.scaleX = _d.scaleX * __sx;
						_d.scaleY = _d.scaleY * __sy;
						d9.addChild(_d);
					}
					//-------------------------------------------------------------------第二张图拉伸(结束)
				}
				else if(_p.layout == 2)
				{
					//-------------------------------------------------------------------第二张图平铺(开始)
					_i1 = Math.ceil(_w / _p.r_width);//平铺数量
					_i2 = Math.ceil(_h / _p.r_height);//纵向数量
					if (_p.mask)
					{
						if (_w % _p.r_width == 0)
						{
							if (_wm)_wm = false;
						}
						else
						{
							if (_wm == false)_wm = true;
						}
						
						if (_h % _p.r_height == 0)
						{
							if (_hm)_hm = false;
						}
						else
						{
							if (_hm == false)_hm = true;
						}
					}
					else
					{
						if (_wm)_wm = false;
						if (_hm)_hm = false;
					}
					//开始递归排列
					_i5 = 0;
					for (_i4 = 0; _i4 < _i2; _i4++)
					{
						for (_i3 = 0; _i3 < _i1; _i3++)
						{
							if (d9.no1 > _i5)
							{
								_d = d9.list[_i5];
								if (_d.mask)
								{
									_s = _d.mask as FShape;
									_d.mask = null;
									_s.dispose();
									_s = null;
								}
							}
							else
							{
								if (_p.pathType == 1)
								{
									if (_t)
									{
										if (g.grid9.gridUseDefGFile)
										{
											_d = g.dfile.u2PathDisplay(_p.path, true, _t.time);
										}
										else
										{
											_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path, true, _t.time);
										}
									}
									else
									{
										if (g.grid9.gridUseDefGFile)
										{
											_d = g.dfile.u2PathDisplay(_p.path);
										}
										else
										{
											_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
										}
										if (_d)
										{
											_t = (_d as Object).timer;
										}
									}
								}
								else if (_p.pathType == 2)
								{
									if (g.grid9.gridUseDefGFile)
									{
										_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
									}
									else
									{
										_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
									}
								}
								else
								{
									_d = U2Bitmap.instance();
									if (g.grid9.gridUseDefGFile)
									{
										g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
									}
									else
									{
										g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
									}
								}
								d9.list.push(_d);
								d9.no1++;
							}
							_i5++;
							switch (_p.r) 
							{
								case 0:
									if (_d.rotation != 0)_d.rotation = 0;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 1:
									if (_d.rotation != 90)_d.rotation = 90;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 2:
									if (_d.rotation != 180)_d.rotation = 180;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 3:
									if (_d.rotation != 270)_d.rotation = 270;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 4:
									if (_d.rotation != 0)_d.rotation = 0;
									if (_d.scaleX != -1)_d.scaleX = -1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 5:
									if (_d.rotation != 0)_d.rotation = 0;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != -1)_d.scaleY = -1;
									break;
							}
							_d.x = _i3 * _p.r_width + _ox + _p.r_x + _nx;
							_d.y = _i4 * _p.r_height + _oy + _p.r_y + _ny;
							if (_wm && (_i3 + 1) == _i1)
							{
								if (_wmd == false)_wmd = true;
							}
							else if (_wmd)
							{
								_wmd = false;
							}
							if (_hm && (_i4 + 1) == _i2)
							{
								if (_hmd == false)_hmd = true;
							}
							else if (_hmd)
							{
								_hmd = false;
							}
							if (_wmd || _hmd)
							{
								_s = FShape.instance();
								if (_wmd && _hmd)
								{
									// 起点, 本小块宽度, 本小块高度
									_s.graphics.drawRect(_d.x - _p.r_x, _d.y - _p.r_y, ( -(_i3 - 1) * _p.r_width + _w), ( -(_i4 - 1) * _p.r_height) + _h);
								}
								else if (_wmd)
								{
									_s.graphics.drawRect(_d.x - _p.r_x, _d.y - _p.r_y, ( -(_i3 - 1) * _p.r_width + _w), _p.r_height);
								}
								else
								{
									_s.graphics.drawRect(_d.x - _p.r_x, _d.y - _p.r_y, _p.r_width, ( -(_i4 - 1) * _p.r_height) + _h);
								}
								_s.graphics.endFill();
								_s.x = _d.x;
								_s.y = _d.y;
								_d.mask = _s;
								d9.addChild(_s);
								d9.addChild(_d);
							}
							else
							{
								d9.addChild(_d);
							}
						}
					}
					//递归结束
					//-------------------------------------------------------------------第二张图平铺(结束)
				}
			}
			else
			{
				//没有第二张数据
				if (d9.no1 != 0)
				{
					var delList:Vector.<DisplayObject> = d9.list.splice(1, d9.no1);
					for each (_d in delList) 
					{
						if ("dispose" in _d)
						{
							(_d as Object).dispose();
						}
						if (_d.parent)
						{
							_d.parent.removeChild(_d);
						}
					}
					g.speedFact.d_vector(DisplayObject, delList);
					delList = null;
					d9.no1 = 0;
				}
			}
			//---------------------------------------------------------------------------第二张图(结束)
			//---------------------------------------------------------------------------第三张图(开始)
			if (d9.data.list.length > 2 && d9.data.list[2])
			{
				_p = d9.data.list[2];
				_nx = w - _p.r_width;
				_ny = 0;
				if (d9.list.length < (d9.no1 + 1) || d9.list[d9.no1 + 1] == null)
				{
					if (_p.pathType == 1)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.u2PathDisplay(_p.path);
						}
						else
						{
							_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
						}
						if (_d)
						{
							_t = (_d as Object).timer;
						}
					}
					else if (_p.pathType == 2)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
						}
						else
						{
							_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
						}
					}
					else
					{
						_d = U2Bitmap.instance();
						if (g.grid9.gridUseDefGFile)
						{
							g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
						}
						else
						{
							g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
						}
					}
					d9.list[d9.no1 + 1] = _d;//_d == null, 会自动push进去
				}
				else
				{
					_d = d9.list[d9.no1 + 1];
				}
				if (_d)
				{
					switch (_p.r)
					{
						case 0:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 1:
							if (_d.rotation != 90)_d.rotation = 90;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 2:
							if (_d.rotation != 180)_d.rotation = 180;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 3:
							if (_d.rotation != 270)_d.rotation = 270;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 4:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != -1)_d.scaleX = -1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 5:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != -1)_d.scaleY = -1;
							break;
					}
					_d.x = _p.r_x + _ox + _nx;
					_d.y = _p.r_y + _oy + _ny;
					d9.addChild(_d);
				}
			}
			else
			{
				if (d9.list.length > (d9.no1 + 1))
				{
					_d = d9.list.splice(d9.no1 + 1, 1)[0];
					if (_d)
					{
						if ("dispose" in _d)
						{
							(_d as Object).dispose();
						}
						if (_d.parent)
						{
							_d.parent.removeChild(_d);
						}
					}
				}
			}
			//---------------------------------------------------------------------------第三张图(结束)
		}
		
		/**
		 * 当是6面的时候
		 * 		0 1 2
		 * 		3 4 5 (1, 3, 5 3个方向, 4 四方向拉伸)
		 * 
		 *  no1  四方向, 拉伸
		 *  no3  四方向, 拉伸
		 *  no5  四方向, 拉伸
		 * 
		 *  no4  四方向拉伸
		 */
		internal static function face_6(d9:Grid9Sprite, w:uint, h:uint, _ox:int, _oy:int):void
		{
			//临时变量
			var _i1:int, _i2:int, _i3:int, _i4:int, _i5:int;
			//边角的图片
			var _d:DisplayObject;
			//遮罩
			var _s:FShape;
			//临时的时间
			var _t:U2Timer;
			//临时变量
			var _w:int, _h:int;
			//临时变量,定位下一张图用的位置坐标
			var _nx:int, _ny:int;
			//临时变量,宽度, 高度最后个需要遮罩么
			var _wm:Boolean, _hm:Boolean;
			//临时变量,宽度, 高度最后个需要遮罩么
			var _wmd:Boolean, _hmd:Boolean;
			var _p:Grid9InfoPiece;
			var delList:Vector.<DisplayObject>;
			//---------------------------------------------------------------------------第一张图(开始)OK
			if (d9.data.list.length > 0 && d9.data.list[0])
			{
				_p = d9.data.list[0];
				if (d9.list.length == 0 || d9.list[0] == null)
				{
					if (_p.pathType == 1)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.u2PathDisplay(_p.path);
						}
						else
						{
							_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
						}
						if (_d)
						{
							_t = (_d as Object).timer;
						}
					}
					else if (_p.pathType == 2)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
						}
						else
						{
							_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
						}
					}
					else
					{
						_d = U2Bitmap.instance();
						if (g.grid9.gridUseDefGFile)
						{
							g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
						}
						else
						{
							g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
						}
					}
					d9.list[0] = _d;//_d == null, 会自动push进去
				}
				else
				{
					_d = d9.list[0];
				}
				if (_d)
				{
					switch (_p.r)
					{
						case 0:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 1:
							if (_d.rotation != 90)_d.rotation = 90;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 2:
							if (_d.rotation != 180)_d.rotation = 180;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 3:
							if (_d.rotation != 270)_d.rotation = 270;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 4:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != -1)_d.scaleX = -1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 5:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != -1)_d.scaleY = -1;
							break;
					}
					_d.x = _p.r_x + _ox;
					_d.y = _p.r_y + _oy;
					d9.addChild(_d);
				}
			}
			else
			{
				_d = d9.list[0];
				if (_d)
				{
					if ("dispose" in _d)
					{
						(_d as Object).dispose();
					}
					if (_d.parent)
					{
						_d.parent.removeChild(_d);
					}
				}
				d9.list[0] = null;
			}
			//---------------------------------------------------------------------------第一张图(结束)
			//---------------------------------------------------------------------------第二张图(开始)OK
			if (d9.data.list.length > 1 && d9.data.list[1])
			{
				_p = d9.data.list[1];
				//有图片数据
				if (d9.data.list.length > 2 && d9.data.list[0] && d9.data.list[2])
				{
					_w = w - d9.data.list[0].r_width - d9.data.list[2].r_width;
					_nx = d9.data.list[0].r_width;
				}
				else if (d9.data.list[0])
				{
					_w = w - d9.data.list[0].r_width;
					_nx = d9.data.list[0].r_width;
				}
				else if (d9.data.list.length > 1 && d9.data.list[2])
				{
					_w = w - d9.data.list[2].r_width;
					_nx = 0;
				}
				else
				{
					_w = w;
					_nx = 0;
				}
				_h = 0;
				_ny = 0;
				if (d9.data.list[0])
				{
					_h = d9.data.list[0].r_height;
				}
				if (_h < _p.r_height)
				{
					_h = _p.r_height;
				}
				if (d9.data.list.length > 2 && d9.data.list[2] && _h < d9.data.list[2].r_height)
				{
					_h = d9.data.list[2].r_height;
				}
				if (d9.no1 == 0)
				{
					d9.no1 = 1;
					if (_p.pathType == 1)
					{
						if (_t)
						{
							if (g.grid9.gridUseDefGFile)
							{
								_d = g.dfile.u2PathDisplay(_p.path, true, _t.time);
							}
							else
							{
								_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path, true, _t.time);
							}
						}
						else
						{
							if (g.grid9.gridUseDefGFile)
							{
								_d = g.dfile.u2PathDisplay(_p.path);
							}
							else
							{
								_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
							}
						}
					}
					else if (_p.pathType == 2)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
						}
						else
						{
							_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
						}
					}
					else
					{
						_d = U2Bitmap.instance();
						if (g.grid9.gridUseDefGFile)
						{
							g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
						}
						else
						{
							g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
						}
					}
					d9.list[0] = _d;
				}
				else
				{
					_d = d9.list[0];
				}
				if (_d)
				{
					switch (_p.r)
					{
						case 0:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 1:
							if (_d.rotation != 90)_d.rotation = 90;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 2:
							if (_d.rotation != 180)_d.rotation = 180;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 3:
							if (_d.rotation != 270)_d.rotation = 270;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 4:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != -1)_d.scaleX = -1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 5:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != -1)_d.scaleY = -1;
							break;
					}
					__sx = _w / _p.r_width;
					__sy = _h / _p.r_height;
					_d.x = _p.r_x * __sx + _ox + _nx;
					_d.y = _p.r_y * __sy + _oy + _ny;
					_d.scaleX = _d.scaleX * __sx;
					_d.scaleY = _d.scaleY * __sy;
					d9.addChild(_d);
				}
			}
			else
			{
				//没有第二张数据
				if (d9.no1 != 0)
				{
					delList = d9.list.splice(1, d9.no1);
					for each (_d in delList) 
					{
						if ("dispose" in _d)
						{
							(_d as Object).dispose();
						}
						if (_d.parent)
						{
							_d.parent.removeChild(_d);
						}
					}
					g.speedFact.d_vector(DisplayObject, delList);
					delList = null;
					d9.no1 = 0;
				}
			}
			//---------------------------------------------------------------------------第二张图(结束)
			//---------------------------------------------------------------------------第三张图(开始)OK
			if (d9.data.list.length > 2 && d9.data.list[2])
			{
				_p = d9.data.list[2];
				_nx = w - _p.r_width;
				_ny = 0;
				if (d9.list.length < (d9.no1 + 1) || d9.list[d9.no1 + 1] == null)
				{
					if (_p.pathType == 1)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.u2PathDisplay(_p.path);
						}
						else
						{
							_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
						}
						if (_d)
						{
							_t = (_d as Object).timer;
						}
					}
					else if (_p.pathType == 2)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
						}
						else
						{
							_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
						}
					}
					else
					{
						_d = U2Bitmap.instance();
						if (g.grid9.gridUseDefGFile)
						{
							g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
						}
						else
						{
							g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
						}
					}
					d9.list[d9.no1 + 1] = _d;//_d == null, 会自动push进去
				}
				else
				{
					_d = d9.list[d9.no1 + 1];
				}
				if (_d)
				{
					switch (_p.r)
					{
						case 0:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 1:
							if (_d.rotation != 90)_d.rotation = 90;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 2:
							if (_d.rotation != 180)_d.rotation = 180;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 3:
							if (_d.rotation != 270)_d.rotation = 270;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 4:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != -1)_d.scaleX = -1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 5:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != -1)_d.scaleY = -1;
							break;
					}
					_d.x = _p.r_x + _ox + _nx;
					_d.y = _p.r_y + _oy + _ny;
					d9.addChild(_d);
				}
			}
			else
			{
				_d = d9.list[d9.no1 + 1];
				if (_d)
				{
					if ("dispose" in _d)
					{
						(_d as Object).dispose();
					}
					if (_d.parent)
					{
						_d.parent.removeChild(_d);
					}
				}
				d9.list[d9.no1 + 1] = null;
			}
			//---------------------------------------------------------------------------第三张图(结束)
			//---------------------------------------------------------------------------第四张图(开始)
			if (d9.data.list.length > 3 && d9.data.list[3])
			{
				_p = d9.data.list[3];
				//有图片数据
				_w = 0;
				if (d9.data.list[0])
				{
					_w = d9.data.list[0].r_width;
				}
				if (_w < _p.r_width)
				{
					_w = _p.r_width;
				}
				_nx = 0;
				if (d9.data.list[0])
				{
					_h = h - d9.data.list[0].r_height;
					_ny = d9.data.list[0].r_height;
				}
				else if (d9.data.list[1])
				{
					_h = h - d9.data.list[1].r_height;
					_ny = d9.data.list[1].r_height;
				}
				else if (d9.data.list[2])
				{
					_h = h - d9.data.list[2].r_height;
					_ny = d9.data.list[2].r_height;
				}
				else
				{
					_h = h;
					_ny = 0;
				}
				if (d9.no3 == 0)
				{
					d9.no3 = 1;
					if (_p.pathType == 1)
					{
						if (_t)
						{
							if (g.grid9.gridUseDefGFile)
							{
								_d = g.dfile.u2PathDisplay(_p.path, true, _t.time);
							}
							else
							{
								_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path, true, _t.time);
							}
						}
						else
						{
							if (g.grid9.gridUseDefGFile)
							{
								_d = g.dfile.u2PathDisplay(_p.path);
							}
							else
							{
								_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
							}
						}
					}
					else if (_p.pathType == 2)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
						}
						else
						{
							_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
						}
					}
					else
					{
						_d = U2Bitmap.instance();
						if (g.grid9.gridUseDefGFile)
						{
							g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
						}
						else
						{
							g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
						}
					}
					d9.list[1 + d9.no1 + d9.no3] = _d;
				}
				else
				{
					_d = d9.list[1 + d9.no1 + d9.no3];
				}
				if (_d)
				{
					switch (_p.r)
					{
						case 0:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 1:
							if (_d.rotation != 90)_d.rotation = 90;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 2:
							if (_d.rotation != 180)_d.rotation = 180;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 3:
							if (_d.rotation != 270)_d.rotation = 270;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 4:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != -1)_d.scaleX = -1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 5:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != -1)_d.scaleY = -1;
							break;
					}
					__sx = _w / _p.r_width;
					__sy = _h / _p.r_height;
					_d.x = _p.r_x * __sx + _ox + _nx;
					_d.y = _p.r_y * __sy + _oy + _ny;
					_d.scaleX = _d.scaleX * __sx;
					_d.scaleY = _d.scaleY * __sy;
					d9.addChild(_d);
				}
			}
			else
			{
				//没有第二张数据
				if (d9.no3 != 0)
				{
					delList = d9.list.splice(1 + d9.no1 + d9.no3, d9.no3);
					for each (_d in delList) 
					{
						if ("dispose" in _d)
						{
							(_d as Object).dispose();
						}
						if (_d.parent)
						{
							_d.parent.removeChild(_d);
						}
					}
					g.speedFact.d_vector(DisplayObject, delList);
					delList = null;
					d9.no3 = 0;
				}
			}
			//---------------------------------------------------------------------------第四张图(结束)
			//---------------------------------------------------------------------------第五张图(开始)
			if (d9.data.list.length > 4 && d9.data.list[4])
			{
				_p = d9.data.list[4];
				//有图片数据
				if (d9.data.list.length > 2 && d9.data.list[0] && d9.data.list[2])
				{
					_w = w - d9.data.list[0].r_width - d9.data.list[2].r_width;
					_nx = d9.data.list[0].r_width;
				}
				else if (d9.data.list[0])
				{
					_w = w - d9.data.list[0].r_width;
					_nx = d9.data.list[0].r_width;
				}
				else if (d9.data.list.length > 1 && d9.data.list[2])
				{
					_w = w - d9.data.list[2].r_width;
					_nx = 0;
				}
				else
				{
					_w = w;
					_nx = 0;
				}
				if (d9.data.list[0])
				{
					_h = h - d9.data.list[0].r_height;
					_ny = d9.data.list[0].r_height;
				}
				else if (d9.data.list[1])
				{
					_h = h - d9.data.list[1].r_height;
					_ny = d9.data.list[1].r_height;
				}
				else if (d9.data.list[2])
				{
					_h = h - d9.data.list[2].r_height;
					_ny = d9.data.list[2].r_height;
				}
				else
				{
					_h = h;
					_ny = 0;
				}
				if (_p.layout == 1)
				{
					//-------------------------------------------------------------------第五张图拉伸(开始)
					if (d9.no4 == 0)
					{
						d9.no4 = 1;
						if (_p.pathType == 1)
						{
							if (_t)
							{
								if (g.grid9.gridUseDefGFile)
								{
									_d = g.dfile.u2PathDisplay(_p.path, true, _t.time);
								}
								else
								{
									_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path, true, _t.time);
								}
							}
							else
							{
								if (g.grid9.gridUseDefGFile)
								{
									_d = g.dfile.u2PathDisplay(_p.path);
								}
								else
								{
									_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
								}
							}
						}
						else if (_p.pathType == 2)
						{
							if (g.grid9.gridUseDefGFile)
							{
								_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
							}
							else
							{
								_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
							}
						}
						else
						{
							_d = U2Bitmap.instance();
							if (g.grid9.gridUseDefGFile)
							{
								g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
							}
							else
							{
								g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
							}
						}
						d9.list[1 + d9.no1 + d9.no3 + d9.no4] = _d;
					}
					else
					{
						_d = d9.list[1 + d9.no1 + d9.no3 + d9.no4];
					}
					if (_d)
					{
						switch (_p.r)
						{
							case 0:
								if (_d.rotation != 0)_d.rotation = 0;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 1:
								if (_d.rotation != 90)_d.rotation = 90;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 2:
								if (_d.rotation != 180)_d.rotation = 180;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 3:
								if (_d.rotation != 270)_d.rotation = 270;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 4:
								if (_d.rotation != 0)_d.rotation = 0;
								if (_d.scaleX != -1)_d.scaleX = -1;
								if (_d.scaleY != 1)_d.scaleY = 1;
								break;
							case 5:
								if (_d.rotation != 0)_d.rotation = 0;
								if (_d.scaleX != 1)_d.scaleX = 1;
								if (_d.scaleY != -1)_d.scaleY = -1;
								break;
						}
						__sx = _w / _p.r_width;
						__sy = _h / _p.r_height;
						_d.x = _p.r_x * __sx + _ox + _nx;
						_d.y = _p.r_y * __sy + _oy + _ny;
						_d.scaleX = _d.scaleX * __sx;
						_d.scaleY = _d.scaleY * __sy;
						d9.addChild(_d);
					}
					//-------------------------------------------------------------------第五张图拉伸(结束)
				}
				else if(_p.layout == 2)
				{
					//-------------------------------------------------------------------第五张图平铺(开始)
					_i1 = Math.ceil(_w / _p.r_width);//平铺数量
					_i2 = Math.ceil(_h / _p.r_height);//纵向数量
					if (_p.mask)
					{
						if (_w % _p.r_width == 0)
						{
							if (_wm)_wm = false;
						}
						else
						{
							if (_wm == false)_wm = true;
						}
						
						if (_h % _p.r_height == 0)
						{
							if (_hm)_hm = false;
						}
						else
						{
							if (_hm == false)_hm = true;
						}
					}
					else
					{
						if (_wm)_wm = false;
						if (_hm)_hm = false;
					}
					//开始递归排列
					_i5 = 0;
					for (_i4 = 0; _i4 < _i2; _i4++)
					{
						for (_i3 = 0; _i3 < _i1; _i3++)
						{
							if (d9.no1 > _i5)
							{
								_d = d9.list[_i5];
								if (_d.mask)
								{
									_s = _d.mask as FShape;
									_d.mask = null;
									_s.dispose();
									_s = null;
								}
							}
							else
							{
								if (_p.pathType == 1)
								{
									if (_t)
									{
										if (g.grid9.gridUseDefGFile)
										{
											_d = g.dfile.u2PathDisplay(_p.path, true, _t.time);
										}
										else
										{
											_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path, true, _t.time);
										}
									}
									else
									{
										if (g.grid9.gridUseDefGFile)
										{
											_d = g.dfile.u2PathDisplay(_p.path);
										}
										else
										{
											_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
										}
										if (_d)
										{
											_t = (_d as Object).timer;
										}
									}
								}
								else if (_p.pathType == 2)
								{
									
									if (g.grid9.gridUseDefGFile)
									{
										_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
									}
									else
									{
										_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
									}
								}
								else
								{
									_d = U2Bitmap.instance();
									if (g.grid9.gridUseDefGFile)
									{
										g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
									}
									else
									{
										g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
									}
								}
								d9.list.push(_d);
								d9.no1++;
							}
							_i5++;
							switch (_p.r) 
							{
								case 0:
									if (_d.rotation != 0)_d.rotation = 0;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 1:
									if (_d.rotation != 90)_d.rotation = 90;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 2:
									if (_d.rotation != 180)_d.rotation = 180;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 3:
									if (_d.rotation != 270)_d.rotation = 270;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 4:
									if (_d.rotation != 0)_d.rotation = 0;
									if (_d.scaleX != -1)_d.scaleX = -1;
									if (_d.scaleY != 1)_d.scaleY = 1;
									break;
								case 5:
									if (_d.rotation != 0)_d.rotation = 0;
									if (_d.scaleX != 1)_d.scaleX = 1;
									if (_d.scaleY != -1)_d.scaleY = -1;
									break;
							}
							_d.x = _i3 * _p.r_width + _ox + _p.r_x + _nx;
							_d.y = _i4 * _p.r_height + _oy + _p.r_y + _ny;
							if (_wm && (_i3 + 1) == _i1)
							{
								if (_wmd == false)_wmd = true;
							}
							else if (_wmd)
							{
								_wmd = false;
							}
							if (_hm && (_i4 + 1) == _i2)
							{
								if (_hmd == false)_hmd = true;
							}
							else if (_hmd)
							{
								_hmd = false;
							}
							if (_wmd || _hmd)
							{
								_s = FShape.instance();
								if (_wmd && _hmd)
								{
									// 起点, 本小块宽度, 本小块高度
									_s.graphics.drawRect(_d.x - _p.r_x, _d.y - _p.r_y, ( -(_i3 - 1) * _p.r_width + _w), ( -(_i4 - 1) * _p.r_height) + _h);
								}
								else if (_wmd)
								{
									_s.graphics.drawRect(_d.x - _p.r_x, _d.y - _p.r_y, ( -(_i3 - 1) * _p.r_width + _w), _p.r_height);
								}
								else
								{
									_s.graphics.drawRect(_d.x - _p.r_x, _d.y - _p.r_y, _p.r_width, ( -(_i4 - 1) * _p.r_height) + _h);
								}
								_s.graphics.endFill();
								_s.x = _d.x;
								_s.y = _d.y;
								_d.mask = _s;
								d9.addChild(_s);
								d9.addChild(_d);
							}
							else
							{
								d9.addChild(_d);
							}
						}
					}
					//递归结束
					//-------------------------------------------------------------------第五张图平铺(结束)
				}
			}
			else
			{
				//没有第二张数据
				if (d9.no4 != 0)
				{
					delList = d9.list.splice(1 + d9.no1 + d9.no3 + d9.no4, d9.no4);
					for each (_d in delList) 
					{
						if ("dispose" in _d)
						{
							(_d as Object).dispose();
						}
						if (_d.parent)
						{
							_d.parent.removeChild(_d);
						}
					}
					g.speedFact.d_vector(DisplayObject, delList);
					delList = null;
					d9.no4 = 0;
				}
			}
			//---------------------------------------------------------------------------第五张图(结束)
			//---------------------------------------------------------------------------第六张图(开始)
			if (d9.data.list.length > 5 && d9.data.list[5])
			{
				_p = d9.data.list[5];
				//有图片数据
				_w = 0;
				if (d9.data.list[0])
				{
					_w = d9.data.list[0].r_width;
				}
				if (_w < _p.r_width)
				{
					_w = _p.r_width;
				}
				_nx = 0;
				if (d9.data.list[0])
				{
					_h = h - d9.data.list[0].r_height;
					_ny = d9.data.list[0].r_height;
				}
				else if (d9.data.list[1])
				{
					_h = h - d9.data.list[1].r_height;
					_ny = d9.data.list[1].r_height;
				}
				else if (d9.data.list[2])
				{
					_h = h - d9.data.list[2].r_height;
					_ny = d9.data.list[2].r_height;
				}
				else
				{
					_h = h;
					_ny = 0;
				}
				if (d9.no5 == 0)
				{
					d9.no5 = 1;
					if (_p.pathType == 1)
					{
						if (_t)
						{
							if (g.grid9.gridUseDefGFile)
							{
								_d = g.dfile.u2PathDisplay(_p.path, true, _t.time);
							}
							else
							{
								_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path, true, _t.time);
							}
						}
						else
						{
							if (g.grid9.gridUseDefGFile)
							{
								_d = g.dfile.u2PathDisplay(_p.path);
							}
							else
							{
								_d = g.gfile.u2PathDisplay(d9.data.gfile, _p.path);
							}
						}
					}
					else if (_p.pathType == 2)
					{
						if (g.grid9.gridUseDefGFile)
						{
							_d = g.dfile.grid9PathDisplay(_p.path, _p.width, _p.height);
						}
						else
						{
							_d = g.gfile.grid9PathDisplay(d9.data.gfile, _p.path, _p.width, _p.height);
						}
					}
					else
					{
						_d = U2Bitmap.instance();
						if (g.grid9.gridUseDefGFile)
						{
							g.dfile.bitmapX(_p.path, true, _d as U2Bitmap);
						}
						else
						{
							g.gfile.bitmapX(d9.data.gfile, _p.path, true, _d as U2Bitmap);
						}
					}
					d9.list[1 + d9.no1 + d9.no3] = _d;
				}
				else
				{
					_d = d9.list[1 + d9.no1 + d9.no3];
				}
				if (_d)
				{
					switch (_p.r)
					{
						case 0:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 1:
							if (_d.rotation != 90)_d.rotation = 90;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 2:
							if (_d.rotation != 180)_d.rotation = 180;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 3:
							if (_d.rotation != 270)_d.rotation = 270;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 4:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != -1)_d.scaleX = -1;
							if (_d.scaleY != 1)_d.scaleY = 1;
							break;
						case 5:
							if (_d.rotation != 0)_d.rotation = 0;
							if (_d.scaleX != 1)_d.scaleX = 1;
							if (_d.scaleY != -1)_d.scaleY = -1;
							break;
					}
					__sx = _w / _p.r_width;
					__sy = _h / _p.r_height;
					_d.x = _p.r_x * __sx + _ox + _nx;
					_d.y = _p.r_y * __sy + _oy + _ny;
					_d.scaleX = _d.scaleX * __sx;
					_d.scaleY = _d.scaleY * __sy;
					d9.addChild(_d);
				}
			}
			else
			{
				//没有第二张数据
				if (d9.no5 != 0)
				{
					delList = d9.list.splice(1 + d9.no1 + d9.no3 + d9.no4 + d9.no5, d9.no5);
					for each (_d in delList) 
					{
						if ("dispose" in _d)
						{
							(_d as Object).dispose();
						}
						if (_d.parent)
						{
							_d.parent.removeChild(_d);
						}
					}
					g.speedFact.d_vector(DisplayObject, delList);
					delList = null;
					d9.no5 = 0;
				}
			}
			//---------------------------------------------------------------------------第六张图(结束)
		}
		
		/**
		 * 清理已经在容器里的所有对象
		 * @param	o
		 */
		internal static function clearDisplay(o:Grid9Sprite):void
		{
			var s:Object;
			if (o.list && o.list.length)
			{
				for each (var d:Object in o.list) 
				{
					if (d)
					{
						if (d.mask)
						{
							s = d.mask;
							d.mask = null;
							s.dispose();
						}
						if ("dispose" in d)
						{
							d.dispose();
						}
						if (d.parent)
						{
							d.parent.removeChild(d);
						}
					}
				}
				o.list.length = 0;
				if (o.no1 != 0) o.no1 = 0;
				if (o.no3 != 0) o.no3 = 0;
				if (o.no4 != 0) o.no4 = 0;
				if (o.no5 != 0) o.no5 = 0;
				if (o.no7 != 0) o.no7 = 0;
			}
		}
		
		/** 对容器进行滞空 **/
		public static function clear(display:Grid9Sprite):void
		{
			Grid9Sprite.clear(display);
		}
	}
}