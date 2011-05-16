//运单打印相关函数的封装
jQuery(function($) {
	$.extend({
		/*
          功能：将货币数字（阿拉伯数字）(小写)转化成中文(大写）
          参数：Num为字符型,小数点之后保留两位,例：Arabia_to_Chinese("1234.06")
          说明：
          1.目前本转换仅支持到 拾亿（元） 位，金额单位为元，不能为万元，最小单位为分
          2.不支持负数
         */
		num2chinese: function(Num) {
			for (i = Num.length - 1; i >= 0; i--) {
				Num = Num.replace(",", "") //替换tomoney()中的“,”
				Num = Num.replace(" ", "") //替换tomoney()中的空格
			}

			Num = Num.replace("￥", "") //替换掉可能出现的￥字符
			if (isNaN(Num)) {
				//验证输入的字符是否为数字
				alert("请检查小写金额是否正确");
				return;
			}
			//---字符处理完毕，开始转换，转换采用前后两部分分别转换---//
			part = String(Num).split(".");
			newchar = "";
			//小数点前进行转化
			for (i = part[0].length - 1; i >= 0; i--) {
				if (part[0].length > 10) {
					alert("位数过大，无法计算");
					return "";
				} //若数量超过拾亿单位，提示
				tmpnewchar = ""
				perchar = part[0].charAt(i);
				switch (perchar) {
				case "0":
					tmpnewchar = "零" + tmpnewchar;
					break;
				case "1":
					tmpnewchar = "壹" + tmpnewchar;
					break;
				case "2":
					tmpnewchar = "贰" + tmpnewchar;
					break;
				case "3":
					tmpnewchar = "叁" + tmpnewchar;
					break;
				case "4":
					tmpnewchar = "肆" + tmpnewchar;
					break;
				case "5":
					tmpnewchar = "伍" + tmpnewchar;
					break;
				case "6":
					tmpnewchar = "陆" + tmpnewchar;
					break;
				case "7":
					tmpnewchar = "柒" + tmpnewchar;
					break;
				case "8":
					tmpnewchar = "捌" + tmpnewchar;
					break;
				case "9":
					tmpnewchar = "玖" + tmpnewchar;
					break;
				}
				switch (part[0].length - i - 1) {
				case 0:
					tmpnewchar = tmpnewchar + "元";
					break;
				case 1:
					if (perchar != 0) tmpnewchar = tmpnewchar + "拾";
					break;
				case 2:
					if (perchar != 0) tmpnewchar = tmpnewchar + "佰";
					break;
				case 3:
					if (perchar != 0) tmpnewchar = tmpnewchar + "仟";
					break;
				case 4:
					tmpnewchar = tmpnewchar + "万";
					break;
				case 5:
					if (perchar != 0) tmpnewchar = tmpnewchar + "拾";
					break;
				case 6:
					if (perchar != 0) tmpnewchar = tmpnewchar + "佰";
					break;
				case 7:
					if (perchar != 0) tmpnewchar = tmpnewchar + "仟";
					break;
				case 8:
					tmpnewchar = tmpnewchar + "亿";
					break;
				case 9:
					tmpnewchar = tmpnewchar + "拾";
					break;
				}
				newchar = tmpnewchar + newchar;
			}
			//小数点之后进行转化
			if (Num.indexOf(".") != - 1) {
				if (part[1].length > 2) {
					alert("小数点之后只能保留两位,系统将自动截段");
					part[1] = part[1].substr(0, 2)
				}
				for (i = 0; i < part[1].length; i++) {
					tmpnewchar = ""
					perchar = part[1].charAt(i)
					switch (perchar) {
					case "0":
						tmpnewchar = "零" + tmpnewchar;
						break;
					case "1":
						tmpnewchar = "壹" + tmpnewchar;
						break;
					case "2":
						tmpnewchar = "贰" + tmpnewchar;
						break;
					case "3":
						tmpnewchar = "叁" + tmpnewchar;
						break;
					case "4":
						tmpnewchar = "肆" + tmpnewchar;
						break;
					case "5":
						tmpnewchar = "伍" + tmpnewchar;
						break;
					case "6":
						tmpnewchar = "陆" + tmpnewchar;
						break;
					case "7":
						tmpnewchar = "柒" + tmpnewchar;
						break;
					case "8":
						tmpnewchar = "捌" + tmpnewchar;
						break;
					case "9":
						tmpnewchar = "玖" + tmpnewchar;
						break;
					}
					if (i == 0) tmpnewchar = tmpnewchar + "角";
					if (i == 1) tmpnewchar = tmpnewchar + "分";
					newchar = newchar + tmpnewchar;
				}
			}
			//替换所有无用汉字
			while (newchar.search("零零") != - 1)
			newchar = newchar.replace("零零", "零");
			newchar = newchar.replace("零亿", "亿");
			newchar = newchar.replace("亿万", "亿");
			newchar = newchar.replace("零万", "万");
			newchar = newchar.replace("零元", "元");
			newchar = newchar.replace("零角", "");
			newchar = newchar.replace("零分", "");

			if (newchar.charAt(newchar.length - 1) == "元" || newchar.charAt(newchar.length - 1) == "角") newchar = newchar + "整"
			return newchar;
		},
		get_print_object: function() {
			//先看看是否存在print对象
			if ($('#printObject').length == 0) {
				var print_object = $('<object classid="clsid:2105C259-1E0C-4534-8141-A753534CB4CA" codebase="/ocx/CAOSOFT_WEB_PRINT_lodop.ocx" width="0" height="0" id="printObject"></object>');
				$('body').append(print_object);
			}
			return printObject;
		},
		//得到运单打印设置
		get_print_config: function(the_bill) {
			var config = {
				page: {
					name: "运单打印",
					width: "185mm",
					height: '140mm',
					left: '-8mm',
					top: '-1mm',
					style: {
						FontSize: 13,
						LineSpacing: 13

					}

				},
				from_org: {
					text: the_bill.from_org.name,
					left: '35mm',
					top: '13mm',
					width: '30mm',
					height: '5.3mm'
				},
				to_org: {
					text: the_bill.to_org.name + (the_bill.transit_org ? (the_bill.transit_org.name + "~") : "") + (the_bill.to_area ? the_bill.to_area: ""),
					left: '80mm',
					top: '13mm',
					width: '30mm',
					height: '5.3mm'
				},
				bill_no: {
					text: the_bill.bill_no,
					left: '130mm',
					top: '13mm',
					width: '36mm',
					height: '5.3mm'
				},
				customer_code: {
					text: the_bill.customer_code ? the_bill.customer_code: "",
					left: '18mm',
					top: '23mm',
					width: '40mm',
					height: '5.3mm',
					style: {
						FontSize: 14
					}

				},
				goods_no: {
					text: the_bill.goods_no,
					left: '87mm',
					top: '23mm',
					width: '40mm',
					height: '5.3mm'
				},
				bill_date: {
					text: the_bill.bill_date,
					left: '134mm',
					top: '23mm',
					width: '33mm',
					height: '5.3mm',
					style: {
						FontSize: 15
					}

				},
				from_customer_name: {
					text: the_bill.from_customer_name,
					left: '36mm',
					top: '31mm',
					width: '23mm',
					height: '5.3mm'
				},
				from_customer_phone: {
					text: the_bill.from_customer_phone,
					left: '65mm',
					top: '31mm',
					width: '35mm',
					height: '5.3mm'
				},
				from_customer_mobile: {
					text: the_bill.from_customer_mobile,
					left: '105mm',
					top: '31mm',
					width: '38mm',
					height: '5.3mm'
				},
				to_customer_name: {
					text: the_bill.to_customer_name,
					left: '36mm',
					top: '37mm',
					width: '23mm',
					height: '5.3mm'
				},
				to_customer_phone: {
					text: the_bill.to_customer_phone,
					left: '65mm',
					top: '37mm',
					width: '35mm',
					height: '5.3mm'
				},
				to_customer_mobile: {
					text: the_bill.to_customer_mobile,
					left: '105mm',
					top: '37mm',
					width: '38mm',
					height: '5.3mm'
				},
				pay_type_des: {
					text: the_bill.pay_type_des,
					left: '143mm',
					top: '37mm',
					width: '30mm',
					height: '5.3mm'
				},

				goods_info: {
					text: the_bill.goods_info,
					left: '20mm',
					top: '52mm',
					width: '23mm',
					height: '5.3mm'
				},
				goods_package: {
					text: the_bill.package,
					left: '44mm',
					top: '52mm',
					width: '16mm',
					height: '5.3mm'
				},
				goods_num: {
					text: the_bill.goods_num,
					left: '60mm',
					top: '52mm',
					width: '14mm',
					height: '5.3mm'
				},
				goods_weight: {
					text: the_bill.goods_weight,
					left: '74mm',
					top: '52mm',
					width: '13mm',
					height: '5.3mm'
				},
				goods_volume: {
					text: the_bill.goods_volume,
					left: '86mm',
					top: '52mm',
					width: '14mm',
					height: '5.3mm'
				},
				carrying_fee: {
					text: the_bill.carrying_fee,
					left: '100mm',
					top: '52mm',
					width: '27mm',
					height: '5.3mm'
				},
				note: {
					text: the_bill.note,
					left: '125mm',
					top: '52mm',
					width: '43mm',
					height: '17mm',
					style: {
						FontSize: 10,
						LineSpacing: 1
					}

				},
				th_amount_chinese: {
					text: $.num2chinese(the_bill.th_amount),
					left: '42mm',
					top: '59mm',
					width: '56mm',
					height: '5.3mm'
				},
				th_amount: {
					text: the_bill.th_amount,
					left: '100mm',
					top: '59mm',
					width: '27mm',
					height: '5.3mm'
				},
				insured_fee_chinese: {
					text: $.num2chinese(the_bill.insured_fee),
					left: '42mm',
					top: '66mm',
					width: '56mm',
					height: '5.3mm'
				},
				insured_fee: {
					text: the_bill.insured_fee,
					left: '100mm',
					top: '66mm',
					width: '26mm',
					height: '5.3mm'
				},
				carrying_fee_total_chinese: {
					text: $.num2chinese(the_bill.carrying_fee_total),
					left: '42mm',
					top: '73mm',
					width: '56mm',
					height: '5.3mm'
				},
				carrying_fee_total: {
					text: the_bill.carrying_fee_total,
					left: '100mm',
					top: '73mm',
					width: '27mm',
					height: '5.3mm'
				},
				goods_fee_chinese: {
					text: $.num2chinese(the_bill.goods_fee),
					left: '42mm',
					top: '79mm',
					width: '56mm',
					height: '5.3mm'
				},
				goods_fee: {
					text: the_bill.goods_fee,
					left: '100mm',
					top: '79mm',
					width: '35mm',
					height: '5.3mm'
				},

				from_short_carrying_fee: {
					text: the_bill.from_short_carrying_fee,
					left: '145mm',
					top: '73mm',
					width: '25mm',
					height: '5.3mm'
				},

				to_short_carrying_fee: {
					text: the_bill.to_short_carrying_fee,
					left: '145mm',
					top: '79mm',
					width: '25mm',
					height: '5.3mm'
				},
				user: {
					text: the_bill.user.real_name,
					left: '30mm',
					top: '92mm',
					width: '23mm',
					height: '5.3mm'
				},
				from_org_phone: {
					text: the_bill.from_org.name + ":" + the_bill.from_org.phone,
					left: '20mm',
					top: '110mm',
					width: '100mm',
					height: '5.3mm'
				},

				to_org_phone: {
					text: the_bill.to_org ? (the_bill.to_org.name + ":" + the_bill.to_org.phone) : (the_bill.transit_org.name + the_bill.to_area + ":" + the_bill.transit_org.phone),
					left: '20mm',
					top: '120mm',
					width: '100mm',
					height: '5.3mm'
				}

			};
			return config;
		},
		//打印运单
		print_bill: function(bill_obj) {
			var print_object = $.get_print_object();
			var config = $.get_print_config(bill_obj);
			print_object.PRINT_INITA(config.page.top, config.page.left, config.page.width, config.page.height, config.page.name);
			print_object.SET_PRINT_PAGESIZE(1, config.page.width, config.page.height, "");
			for (var c in config) {
				if (typeof(config[c].text) != 'undefined') print_object.ADD_PRINT_TEXT(config[c].top, config[c].left, config[c].width, config[c].height, config[c].text);
				print_object.SET_PRINT_STYLEA(0, "FontSize", 13);
				print_object.SET_PRINT_STYLEA(0, "LineSpacing", 10);
				//判断有无特殊打印格式
				if (typeof(config[c].style) != 'undefined') {
					var the_style = config[c].style;
					for (var s in the_style)
					print_object.SET_PRINT_STYLEA(0,s, the_style[s]);

				}

			}
			print_object.PREVIEW();
			//print_object.PRINT();
		}
	});
	//绑定打印事件
	$('.print_carrying_bill').click(function() {
		var bill = $(this).data('print');
		$.print_bill(bill);
	});

	//提货时,仅仅打印运单
	$('.btn_deliver_only_print').click(function() {
		if ($('.carrying_bill_show').length == 0) $.notifyBar({
			html: "请先查询要提货的运单,然后再进行打印操作.",
			delay: 3000,
			animationSpeed: "normal",
			cls: 'error'
		});
		else {
			var bill = $('.carrying_bill_show').data('print');
			$.print_bill(bill);
		}

	});

	//提货打印,触发自动打印事件
	$('.auto_print_bill').trigger('click');
});

