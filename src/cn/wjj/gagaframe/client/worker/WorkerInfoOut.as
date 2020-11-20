package cn.wjj.gagaframe.client.worker 
{
	/**
	 * 执行子对象的返回内容
	 * @author GaGa
	 */
	public class WorkerInfoOut 
	{
		
		/** 清理 **/
		public static function clear(o:WorkerInfoOut):void
		{
			if (o._isError) o._isError = false;
			if (o._hasInfo) o._hasInfo = false;
			if (o._info != null) o._info = null;
		}
		
		/** 执行中是否出现错误 **/
		internal var _isError:Boolean = false;
		/** 是否有返回结果 **/
		private var _hasInfo:Boolean = false;
		/** 执行结果记录对象,对象只限Object和Array **/
		private var _info:Object;
		
		public function WorkerInfoOut() { }
		
		/** 将其他队列传送过来的值 **/
		internal function readByte(byte:WorkerByteArray):void
		{
			_isError = byte.readBoolean();
			_hasInfo = byte.readBoolean();
			if (_hasInfo)
			{
				_info = byte._r_Object();
			}
			else
			{
				_info = null;
			}
		}
		
		internal function writeByte(byte:WorkerByteArray):void
		{
			byte.writeBoolean(_isError);
			byte.writeBoolean(_hasInfo);
			if (_hasInfo)
			{
				byte._w_Object(_info);
			}
		}
		/** 执行中是否出现错误 **/
		public function get isError():Boolean 
		{
			return _isError;
		}
		/** 是否有返回结果 **/
		public function get hasInfo():Boolean 
		{
			return _hasInfo;
		}
		/** 执行结果记录对象 **/
		public function get info():Object 
		{
			return _info;
		}
		/** 执行结果记录对象 **/
		public function set info(value:Object):void 
		{
			_info = value;
			if (value == null)
			{
				_hasInfo = false;
			}
			else
			{
				_hasInfo = true;
			}
		}
	}

}