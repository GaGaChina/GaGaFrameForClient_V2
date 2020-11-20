package cn.wjj.data
{
	import cn.wjj.tool.EncodeCode;
	
	public class XMLToObject
	{
		/**
		 * 将一个XML转换为Object输出
		 * @param	dp
		 * @param	ignoreNamespace
		 * @param	changeCode			是否自动转换编码
		 * @param	outXMLvalue			是否把内容体是XML的内容输出
		 * @return
		 */
		public static function to(dp:XML, ignoreNamespace:Boolean = false, changeCode:Boolean = false, outXMLvalue:Boolean = false):Object
		{
			if (dp)
			{
				var _obj:Object = new Object();
				//dp.ignoreWhitespace = true;
				pNode(dp, _obj, ignoreNamespace, changeCode, outXMLvalue);
				return _obj;
			}
			return null;
		}
		
		/**
		 * 将dp的XML内容转换到obj对象中.
		 * @param dp
		 * @param obj
		 * @param ignoreNamespace
		 * @param changeCode
		 * @param outXMLvalue
		 * 
		 */
		static private function toObj(dp:XML, obj:Object, ignoreNamespace:Boolean, changeCode:Boolean, outXMLvalue:Boolean):void
		{
			var nl:int = dp.children().length();
			for (var i:int = 0; i < nl; i++)
			{
				var node:XML = dp.children()[i];
				if (obj is Array)
				{
					pNode(node, obj[obj.length - 1], ignoreNamespace, changeCode, outXMLvalue);
				}
				else
				{
					pNode(node, obj, ignoreNamespace, changeCode, outXMLvalue);
				}
			}
		}

		private static function pNode(node:XML, obj:Object, ignoreNamespace:Boolean, changeCode:Boolean, outXMLvalue:Boolean):void
		{ 
			if (ignoreNamespace)
			{
				node.setNamespace("");
			}
			var nodeName:String, j:String;
			if(changeCode)
			{
				nodeName = String(EncodeCode.EncodeUtf8(node.name().toString()));
			}
			else
			{
				nodeName = String(node.name().toString());
			}
			var o:Object = new Object();
			if (node.attributes().length() > 0)
			{
				for (j in node.attributes())
				{
					if(changeCode)
					{
						o[String(node.attributes()[j].name())] = EncodeCode.EncodeUtf8(String(node.attributes()[j]));
					}
					else
					{
						o[String(node.attributes()[j].name())] = String(node.attributes()[j]);
					}
				}
				//if (node.children().length() <= 1 && o["value"] == undefined)
				//if (node.children().length() <= 1)
				if (node.children().length() <= 1 && !node.hasComplexContent())
				{
					if(node.toString())
					{
						if(changeCode)
						{
							o["value"] = EncodeCode.EncodeUtf8(String(node.toString()));
						}
						else
						{
							o["value"] = String(node.toString());
						}
					}
				}
			}
			else
			{
				if (node.children().length() <= 1 && !node.hasComplexContent())
				{
					if(changeCode)
					{
						o = String(EncodeCode.EncodeUtf8(node.toString()));
					}
					else
					{
						o = String(node.toString());
					}
				}
			}
			if (obj[nodeName] == undefined)
			{
				obj[nodeName] = o;
			}
			else
			{
				if (obj[nodeName] is Array)
				{
					obj[nodeName].push(o);
				}
				else
				{
					obj[nodeName] = [obj[nodeName], o];
				}
			}
			try
			{
				toObj(node, obj[nodeName], ignoreNamespace, changeCode, outXMLvalue);
			} catch (e:Error) {}
		}
	}
}