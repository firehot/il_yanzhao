//运单打印相关函数的封装
jQuery(function($) {
	$.extend({
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
					text: $.num2chinese(the_bill.th_amount),
					left: '110mm',
					top: '45mm',
					width: '62mm',
					height: '6mm'
				},
				th_amount: {
					text: the_bill.th_amount,
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
                                                  text: the_bill.from_org.name + "(" + the_bill.from_org.location +"):"  the_bill.from_org.phone,
					left: '102mm',
					top: '98mm',
					width: '50mm',
					height: '6mm'
				},

				to_org_phone: {
					text: the_bill.to_org ? (the_bill.to_org.name + "(" + the_bill.to_org.location + ")" + ":" + the_bill.to_org.phone) : (the_bill.transit_org.name + ":" + the_bill.transit_org.phone),
					left: '148mm',
					top: '98mm',
					width: '50mm',
					height: '6mm'
				},
				print_counter: {
					text: (the_bill.print_counter > 0) ? the_bill.print_counter + "次打印": "",
					left: '148mm',
					top: '108mm',
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

			//print_object.PREVIEW();
			print_object.PRINT();
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
			//打印计数
			var print_counter_url = "";
			if (bill.type == 'ComputerBill') print_counter_url = "/computer_bills/" + bill.id + "/print_counter";
			if (bill.type == 'TransitBill') print_counter_url = "/transit_bills/" + bill.id + "/print_counter";
			if (bill.type == 'ReturnBill') print_counter_url = "/return_bills/" + bill.id + "/print_counter";

			$.ajax({
				url: print_counter_url,
				type: 'PUT',
				success: function() {
					$('#bill_print_counter').html((bill.print_counter + 1) + "次打印");
				}
			});
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
		var table_doc = $('#goods_exception_print').clone();
		table_doc.css({
			tableLayout: 'fixed',
			width: '180mm',
			borderCollapse: 'collapse'
		});
		table_doc.find('tr').css({
			height: '8mm'
		});

		table_doc.find('th,td').css({
			border: 'thin solid #000',
			borderCollapse: 'collapse'
		});

		var config = {
			print_name: "货损理赔信息",
			top: "0",
			left: "0",
			width: "200mm",
			height: "103mm",
			content: table_doc.wrap('<div></div>').parent().html()
		};
		$.print_html(config);
		return false;
	});
	//打印客户转账凭条
	$('.btn_print_pay_info_certificate').click(function() {
		var table_doc = $('.pay_info_certificate');
		//table_doc.find('th,td').css({border : 'thin solid #000',borderCollapse : 'collapse'});
		var config = {
			print_name: "客户转账凭条",
			top: "2mm",
			left: "0",
			width: "188mm",
			height: "92mm",
			content: table_doc.clone().wrap('<div></div>').parent().html()
		};
		$.print_html(config);
		return false;
	});
	//分理处货款收支清单打印
	$('.btn_print_goods_fee_settlement_list').click(function() {
		var table_doc = $('#goods_fee_settlement_list_show').clone();
		table_doc.css({
			tableLayout: 'fixed',
			width: '180mm',
			borderCollapse: 'collapse'
		});
		table_doc.find('tr').css({
			height: '6mm'
		});

		table_doc.find('th,td').css({
			border: 'thin solid #000',
			borderCollapse: 'collapse'
		});

		table_doc.find('tfoot td').css({
			border: 'none'
		});
		var config = {
			print_name: "分理处货款收支清单",
			top: "2mm",
			left: "0",
			width: "210mm",
			height: "120mm",
			content: table_doc.wrap('<div></div>').parent().html()
		};
		$.print_html(config);
		return false;
	});
	//提货打印,触发自动打印事件
	$('.auto_print_bill').trigger('click');
});
