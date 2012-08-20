//=require ukey
//ie下重写get_print_object
jQuery(function($) {
	$.extend({
		get_print_object: function() {
			//先看看是否存在print对象
			//FIXME 此处修改为assets目录
			if ($('#printObject').length == 0) {
				var print_object = $('<object classid="clsid:2105C259-1E0C-4534-8141-A753534CB4CA" codebase="/assets/CAOSOFT_WEB_PRINT_lodop.ocx" width="0" height="0" id="printObject"></object>');
				$('body').append(print_object);
			}
			return printObject;
		},
		//导出数据到excel, ie only
		export_excel: function(table_content, func_set_style) {
			try {

				window.clipboardData.setData("Text", table_content);
				ExApp = new ActiveXObject("Excel.Application");
				var ExWBk = ExApp.Workbooks.add();
				var ExWSh = ExWBk.ActiveSheet;
				ExApp.DisplayAlerts = false;
				if (func_set_style) func_set_style(ExWSh);
				ExApp.visible = true;
				ExWSh.Paste();
			}
			catch(e) {
				$.notifyBar({
					html: "导出失败,请确认您已安装excel软件,并调整了IE的安全设置.",
					delay: 3000,
					animationSpeed: "normal",
					cls: 'error'
				});
				return false;
			}
		}
	});
});

