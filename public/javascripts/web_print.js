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
					name: "运单打印-" + the_bill.bill_no,
					width: "210mm",
					height: '140mm',
					left: '0',
					top: '-2mm',
					style: {
						FontSize: 13,
						LineSpacing: 13
					}

				},
				from_org: {
					text: the_bill.from_org.name,
					left: '38mm',
					top: '13mm',
					width: '35mm',
					height: '6mm'
				},
				to_org: {
					text: (the_bill.to_org ? the_bill.to_org.name: "") + (the_bill.area ? the_bill.area.name: ""),
					left: '100mm',
					top: '13mm',
					width: '30mm',
					height: '6mm'
				},
				bill_no: {
					text: the_bill.bill_no,
					left: '160mm',
					top: '13mm',
					width: '30mm',
					height: '6mm'
				},
				customer_code_1: {
					text: the_bill.customer_code ? the_bill.customer_code.substr(0, 1) : "",
					left: '31mm',
					top: '22mm',
					width: '6mm',
					height: '6mm',
					style: {
						FontSize: 14
					}

				},
				customer_code_2: {
					text: the_bill.customer_code ? the_bill.customer_code.substr(1, 1) : "",
					left: '38mm',
					top: '22mm',
					width: '6mm',
					height: '6mm',
					style: {
						FontSize: 14
					}

				},
				customer_code_3: {
					text: the_bill.customer_code ? the_bill.customer_code.substr(2, 1) : "",
					left: '45mm',
					top: '22mm',
					width: '6mm',
					height: '6mm',
					style: {
						FontSize: 14
					}

				},
				customer_code_4: {
					text: the_bill.customer_code ? the_bill.customer_code.substr(3, 1) : "",
					left: '52mm',
					top: '22mm',
					width: '6mm',
					height: '6mm',
					style: {
						FontSize: 14
					}

				},
				customer_code_5: {
					text: the_bill.customer_code ? the_bill.customer_code.substr(4, 1) : "",
					left: '60mm',
					top: '22mm',
					width: '6mm',
					height: '6mm',
					style: {
						FontSize: 14
					}

				},
				customer_code_6: {
					text: the_bill.customer_code ? the_bill.customer_code.substr(5, 1) : "",
					left: '67mm',
					top: '22mm',
					width: '6mm',
					height: '6mm',
					style: {
						FontSize: 14
					}

				},
				customer_code_7: {
					text: the_bill.customer_code ? the_bill.customer_code.substr(6, 1) : "",
					left: '74mm',
					top: '22mm',
					width: '6mm',
					height: '6mm',
					style: {
						FontSize: 14
					}

				},

				goods_no: {
					text: the_bill.goods_no,
					left: '110mm',
					top: '22mm',
					width: '40mm',
					height: '6mm'
				},
				bill_date_year: {
					text: the_bill.bill_date.substr(0, 4),
					left: '157mm',
					top: '22mm',
					width: '13mm',
					height: '6mm',
					style: {
						FontSize: 15
					}

				},
				bill_date_mth: {
					text: the_bill.bill_date.substr(5, 2),
					left: '175mm',
					top: '22mm',
					width: '10mm',
					height: '6mm',
					style: {
						FontSize: 15
					}

				},
				bill_date_day: {
					text: the_bill.bill_date.substr(8, 2),
					left: '185mm',
					top: '22mm',
					width: '10mm',
					height: '6mm',
					style: {
						FontSize: 15
					}

				},

				from_customer_name: {
					text: the_bill.from_customer_name,
					left: '39mm',
					top: '30mm',
					width: '26mm',
					height: '6mm'
				},
				from_customer_phone: {
					text: the_bill.from_customer_phone,
					left: '74mm',
					top: '30mm',
					width: '35mm',
					height: '6mm'
				},
				from_customer_mobile: {
					text: the_bill.from_customer_mobile,
					left: '118mm',
					top: '30mm',
					width: '40mm',
					height: '6mm'
				},
				to_customer_name: {
					text: the_bill.to_customer_name,
					left: '39mm',
					top: '37mm',
					width: '26mm',
					height: '6mm'
				},
				to_customer_phone: {
					text: the_bill.to_customer_phone,
					left: '74mm',
					top: '37mm',
					width: '35mm',
					height: '6mm'
				},
				to_customer_mobile: {
					text: the_bill.to_customer_mobile,
					left: '118mm',
					top: '37mm',
					width: '40mm',
					height: '6mm'
				},
				pay_type_des: {
					text: the_bill.pay_type_des,
					left: '160mm',
					top: '37mm',
					width: '35mm',
					height: '6mm'
				},

				goods_info: {
					text: the_bill.goods_info,
					left: '19mm',
					top: '52mm',
					width: '20mm',
					height: '7mm'
				},
				goods_package: {
					text: the_bill.package,
					left: '39mm',
					top: '52mm',
					width: '13mm',
					height: '7mm'
				},
				goods_num: {
					text: the_bill.goods_num,
					left: '52mm',
					top: '52mm',
					width: '13mm',
					height: '7mm'
				},
				carrying_fee: {
					text: the_bill.carrying_fee,
					left: '65mm',
					top: '52mm',
					width: '18mm',
					height: '7mm'
				},
				th_amount_chinese: {
					text: $.num2chinese((parseFloat(the_bill.carrying_fee_total) + parseFloat(the_bill.goods_fee)).toString()),
					left: '110mm',
					top: '45mm',
					width: '62mm',
					height: '6mm'
				},
				th_amount: {
					text: parseFloat(the_bill.carrying_fee_total) + parseFloat(the_bill.goods_fee),
					left: '177mm',
					top: '45mm',
					width: '20mm',
					height: '6mm'
				},
				insured_amount: {
					text: the_bill.insured_amount,
					left: '130mm',
					top: '51mm',
					width: '20mm',
					height: '7mm'
				},

				insured_fee: {
					text: the_bill.insured_fee,
					left: '177mm',
					top: '51mm',
					width: '20mm',
					height: '6mm'
				},
				from_short_carrying_fee: {
					text: the_bill.from_short_carrying_fee,
					left: '39mm',
					top: '58mm',
					width: '15mm',
					height: '6mm'
				},
				to_short_carrying_fee: {
					text: the_bill.to_short_carrying_fee,
					left: '70mm',
					top: '58mm',
					width: '15mm',
					height: '6mm'
				},

				carrying_fee_total_chinese: {
					text: $.num2chinese(the_bill.carrying_fee_total),
					left: '110mm',
					top: '58mm',
					width: '62mm',
					height: '6mm'
				},
				carrying_fee_total: {
					text: the_bill.carrying_fee_total,
					left: '177mm',
					top: '58mm',
					width: '20mm',
					height: '6mm'
				},
				note: {
					text: the_bill.note,
					left: '35mm',
					top: '66mm',
					width: '50mm',
					height: '6mm',
					style: {
						FontSize: 10,
						LineSpacing: 1
					}

				},

				goods_fee_chinese: {
					text: $.num2chinese(the_bill.goods_fee),
					left: '110mm',
					top: '66mm',
					width: '62mm',
					height: '6mm'
				},
				goods_fee: {
					text: the_bill.goods_fee,
					left: '177mm',
					top: '66mm',
					width: '20mm',
					height: '6mm'
				},

				user: {
					text: the_bill.user.real_name,
					left: '35mm',
					top: '82mm',
					width: '25mm',
					height: '6mm'
				},

				from_org_phone: {
                                                  text: the_bill.from_org.name + ":"+the_bill.from_org.phone,
					left: '90mm',
					top: '98mm',
					width: '50mm',
					height: '6mm'
				},

				to_org_phone: {
                                                text: the_bill.to_org ? (the_bill.to_org.name + ":" + the_bill.to_org.phone) : (the_bill.transit_org.name + ":" + the_bill.transit_org.phone),
					left: '148mm',
					top: '98mm',
					width: '50mm',
					height: '6mm'
				}

			};
			return config;
		},
		//打印运单
		print_bill: function(config) {
			var print_object = $.get_print_object();
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
					print_object.SET_PRINT_STYLEA(0, s, the_style[s]);

				}

			}
			//print_object.PREVIEW();
			print_object.PRINT();
		},
		//打印html内容
		print_html: function(config) {
			var print_object = $.get_print_object();
			print_object.PRINT_INITA(config.top, config.left, config.width, config.height, config.print_name);
			print_object.SET_PRINT_PAGESIZE(1, config.width, config.height, "");
			//添加content
			print_object.ADD_PRINT_HTM(config.top, config.left, config.width, config.height, config.content);

			print_object.PREVIEW();
			//print_object.PRINT();
		}
	});
	//绑定打印事件
	$('.print_carrying_bill').click(function() {
		if ($(this).data('printed')) $.notifyBar({
			html: "请点击[刷新]按钮后再重新打印运单!",
			delay: 3000,
			animationSpeed: "normal",
			cls: 'error'
		});

		else {
			var bill = $(this).data('print');
			var config = $.get_print_config(bill);
			$.print_bill(config);
			$(this).data('printed', true);
		}
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
			var config = $.get_print_config(bill);
			$.print_bill(config);
		}

	});
	//货损理赔信息打印
	$('.btn_print_goods_exception').click(function() {
		var table_doc = $('#goods_exception_show').clone();
		table_doc.find('th,td').css({
			border: 'thin solid #000',
			borderCollapse: 'collapse'
		});

		var config = {
			print_name: "货损理赔信息",
			top: "10mm",
			left: "10mm",
			width: "200mm",
			height: "140mm",
			content: table_doc.wrap('<div></div>').parent().html()
		};
		$.print_html(config);
	});
	//打印客户转账凭条
	$('.btn_print_pay_info_certificate').click(function() {
		var table_doc = $('.pay_info_certificate');
		//table_doc.find('th,td').css({border : 'thin solid #000',borderCollapse : 'collapse'});
		var config = {
			print_name: "客户转账凭条",
			top: "0",
			left: "0",
			width: "210mm",
			height: "110mm",
			content: table_doc.clone().wrap('<div></div>').parent().html()
		};
		$.print_html(config);
	});

	//提货打印,触发自动打印事件
	$('.auto_print_bill').trigger('click');
});

