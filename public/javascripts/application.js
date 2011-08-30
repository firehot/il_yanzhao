// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery(function($) {
	//扩展jQuery function
	$.extend({
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
		},
		//模拟mouseclick
		fireClick: function(el) {
			if (!el) return;
			if (document.dispatchEvent) { // W3C
				var oEvent = document.createEvent("MouseEvents");
				oEvent.initMouseEvent("click", true, true, window, 1, 1, 1, 1, 1, false, false, false, false, 0, el);
				el.dispatchEvent(oEvent);
			}
			else if (document.fireEvent) { // IE
				el.click();
			}

		}
	});
	//初始化区域选择
	$('.select_org').select_combobox();
	//导出excel按钮绑定
	$('.btn_export_excel').click(function() {
		var url = $(this).attr('href');
		$.get(url, null, null, 'script')
		return false;
	});

	var calculate_carrying_bill = function() {
		//计算保价费合计
		var insured_amount = parseFloat($('#insured_amount').val());
		var insured_rate = parseFloat($('#insured_rate').val());
		var insured_fee = Math.ceil(insured_amount * insured_rate / 1000);
		$('#insured_fee').val(insured_fee);
		//计算运费合计
		var carrying_fee = parseFloat($('#carrying_fee').val());
		var from_short_carrying_fee = parseFloat($('#from_short_carrying_fee').val());
		var to_short_carrying_fee = parseFloat($('#to_short_carrying_fee').val());
		var sum_carrying_fee = carrying_fee;
		$('#sum_carrying_fee').text(sum_carrying_fee);
		//计算总金额合计
		var goods_fee = parseFloat($('#goods_fee').val());
		var sum_fee = sum_carrying_fee + insured_fee;

		$('#sum_fee').text(sum_fee);

	};

	//双击某条记录打开详细信息
	//tr[data-dblclick]
	$('#bills_table,table.table[id$="index_table"]').live('dblclick', function(evt) {
		var target_el = $(evt.target).parent('tr');
		if (target_el.attr('data-dblclick')) {
			$('tr[data-dblclick]').removeClass('cur_select');
			$(target_el).addClass('cur_select');

			var el_anchor = $(target_el).find('a.show_link');
			if ($(el_anchor).hasClass('popup-box')) {
				$(el_anchor).fancybox();
				$.fireClick($(el_anchor)[0]);
			}
			else {
				window.location = $(el_anchor).attr('href');
				$.fancybox.showActivity();
			}
		}

	});
	/*
        .live('click', function(evt) { //单击某条记录选中
		var target_el = $(evt.target).parent('tr');
		if (target_el.attr('data-dblclick')) {

			$('tr[data-dblclick]').removeClass('cur_select');
			$(target_el).addClass('cur_select');
		}

	});
        */

	$('.btn_edit').click(function() {
		var cur_select = $('tr[data-dblclick].cur_select .edit_link');
		if (cur_select.length == 0) {
			$.notifyBar({
				html: "请先选择要编辑的数据!",
				delay: 3000,
				animationSpeed: "normal",
				cls: 'error'
			});
			return false;
		}

		if (cur_select.length > 0) $(this).attr('href', $(cur_select[0]).attr('href'));
		if ($(this).attr('href') == '') return false;

	});
	$('.btn_delete').click(function() {
		var cur_select = $('tr[data-dblclick].cur_select .delete_link');
		if (cur_select.length == 0) {
			$.notifyBar({
				html: "请先选择要删除的数据!",
				delay: 3000,
				animationSpeed: "normal",
				cls: 'error'
			});
			return false;
		}

		if (cur_select.length > 0) $(this).attr('href', $(cur_select[0]).attr('href'));
		if ($(this).attr('href') == '') return false;

	});
	//组织机构修改删除按钮处理
	$('.btn_edit_org').click(function() {
		var cur_active = $('#orgs_list li.ui-state-active');
		if (cur_active.length == 0) {
			$.notifyBar({
				html: "请先选择要编辑的组织机构!",
				delay: 3000,
				animationSpeed: "normal",
				cls: 'error'
			});
			return false;
		}

		if (cur_active.length > 0) $(this).attr('href', $(cur_active).data('editPath'));
		if ($(this).attr('href') == '') return false;

	});

	$('.btn_delete_org').click(function() {
		var cur_active = $('#orgs_list li.ui-state-active');
		if (cur_active.length == 0) {
			$.notifyBar({
				html: "请先选择要删除的组织机构!",
				delay: 3000,
				animationSpeed: "normal",
				cls: 'error'
			});
			return false;
		}
		if ($(cur_active).data('deletePath') == 'undefined') return false;
		if (cur_active.length > 0) $(this).attr('href', $(cur_active).data('deletePath'));
		if ($(this).attr('href') == '') return false;

	});
	/*
	//组织机构列表
	$('#role_system_functions_list').accordion({
		collapsible: true,
		autoHeight: false,
		animated: false,
		active: false
	});
        */
	//根据客户编号查询查询客户信息
	var search_customer_by_code = function() {
		var code = $(this).val();
		if (code == "") return;
		$.get('/vips', {
			"search[code_eq]": code,
			"in_wich": 'carrying_bill_form'
		},
		null, 'script');

	};
	$('form.computer_bill #customer_code,form.transit_bill #customer_code').live('change', search_customer_by_code);
	$('form.carrying_bill').live("change", calculate_carrying_bill).livequery(calculate_carrying_bill);
	//运单修改时,判断权限
	$('form.update_carrying_fee,form.update_goods_fee').livequery(function() {
		$('#carrying_bill_form :input').attr('readonly', true);
		$('#carrying_bill_form select').attr('disabled', true);
		$('#carrying_fee').attr('readonly', false);
		$('#goods_fee').attr('readonly', false);
		$('#from_customer_name').attr('readonly', false);
		$('#from_customer_phone').attr('readonly', false);
		$('#from_customer_mobile').attr('readonly', false);
		$('#to_customer_name').attr('readonly', false);
		$('#to_customer_phone').attr('readonly', false);
		$('#to_customer_mobile').attr('readonly', false);
		$('#note').attr('readonly', false);
		$('#select_org_input_to_org_id').attr('readonly', false);

		$('#from_org_id').attr('disabled', false);
		$('#transit_org_id').attr('disabled', false);
		$('#area_id').attr('disabled', false);
		$('#to_org_id').attr('disabled', false);
		$('#pay_type').attr('disabled', false);

	});

	$('form.update_all').livequery(function() {
		$('#carrying_bill_form :input,#carrying_bill_form select').attr('readonly', false);
	});

	//根据不同的运单录入界面,隐藏部分字段
	$('form.computer_bill').livequery(function() {
		$('#computer_bill_bill_no').attr('readonly', true);
		$('#computer_bill_goods_no').attr('readonly', true);
	});
	$('form.hand_bill').livequery(function() {
		$('#hand_bill_bill_no').attr('readonly', false);
		$('#hand_bill_goods_no').attr('readonly', false);
		$('#bill_date').removeClass('datepicker');
		$('#goods_num').attr('readonly', true);

	});
	$('form.transit_bill').livequery(function() {
		$('#transit_bill_bill_no').attr('readonly', true);
		$('#transit_bill_goods_no').attr('readonly', true);

	});
	$('form.hand_transit_bill').livequery(function() {
		$('#hand_transit_bill_bill_no').attr('readonly', false);
		$('#hand_transit_bill_goods_no').attr('readonly', false);
		$('#bill_date').removeClass('datepicker');
		$('#goods_num').attr('readonly', true);

	});
	$('form.return_bill').livequery(function() {
		$(this).find('input').attr('readonly', true);
		$('#return_bill_note').attr('readonly', false);

	});
	//设定只读字段的背景色
	/*
	$('input[readonly]').css({
		background: '#EDEDED'
	});
        */
	//手工运单,自动解析日期和数量
	//
	$('#hand_bill_goods_no,#hand_transit_bill_goods_no').live('change', function() {
		var the_goods_no = $(this).val();
		var bill_date = '20' + /^\d{6}/.exec(the_goods_no);
		var goods_num = /\d+$/.exec(the_goods_no);
		$('#bill_date').val(bill_date);
		$('#goods_num').val(goods_num);

	});

	//绑定所有日期选择框
	$.datepicker.setDefaults({
		dateFormat: 'yy-mm-dd'
	});
	$.datepicker.setDefaults($.datepicker.regional['zh_CN']);
	$('.datepicker').livequery(function() {
		$(this).attr('readonly', true);
		$(this).datepicker();
	});

	//初始化左侧菜单树
	var cookieName = 'il_cur_menu_group';
	var get_current_menu_group = function() {
		var cookie_menu = $.cookies.get(cookieName);
		return cookie_menu;
	};

	/*
	$('#menu_bar').accordion({
		active: get_current_menu.apply(),
		collapsible: true,
		autoHeight: false,
		animated: false,
		change: function(e, ui) {
			$.cookies.set(cookieName, "cur_il_menu_" + $(this).find('h3').index(ui.newHeader[0]));
		}
	});
        */
	/*当前menu_group设置*/
	var cur_menu_group = get_current_menu_group();
	if (cur_menu_group) $('#' + cur_menu_group).next('.navigation:first').show();
	/*menu_bar的点击事件*/
	$('#menu_bar .group_name').click(function() {
		var cur_el = $(this).next('.navigation:first')[0];
		$('#menu_bar .navigation').each(function(index, el) {
			if (el == cur_el) $(el).toggle();
			else $(el).hide();
		});
		$.cookies.set(cookieName, $(this).attr('id'));
	});

	$('#menu_bar .navigation a').bind('click', function() {
		$.fancybox.showActivity();
	});

	$('.fancybox').livequery(function() {
		$(this).fancybox({
			scrolling: 'no',
			padding: 20
		});
	});

	//初始化tip
	$('.tipsy').livequery(function() {
		$('.tipsy').tipSwift({
			gravity: $.tipSwift.gravity.autoWE,
			plugins: [
			$.tipSwift.plugins.tip({
				offset: 5,
				gravity: 's',
				opacity: 0.6,
				showEffect: $.tipSwift.effects.fadeIn,
				hideEffect: $.tipSwift.effects.fadeOut
			})]
		});

	});
	$.blockUI.defaults.message = null;
	$.blockUI.defaults.overlayCSS.opacity = 0.2;
	//运单列表表头点击事件
	$('#table_wrap tr.table-header th a[href!="#"],#table_wrap .pagination a[href!="#"]').live('click', function() {
		$.getScript(this.href);
		return false;
	});
	$('form.bill_selector').livequery(function() {
		$(this).form_with_select_bills();
	});

	$(document).ajaxStart(function() {
		$.fancybox.showActivity();
		$.blockUI();
	}).ajaxStop(function() {
		$.fancybox.hideActivity();
		$.unblockUI();
	});
	//对需要长时间处理的操作,显示blockUI
	$('.btn_process_handle').bind('click', function() {
		$.fancybox.showActivity();
		$.blockUI();
	});

	//首页运单查询
	//去除所有绑定
	$('#home-search-box').watermark('录入运单号/货号查询').keydown(function(e) {
		if (e.keyCode == 13) {
			$('#home-search-form').trigger('submit');
		}
	});
	//search box
	$('.search_box').livequery(function() {
		$(this).watermark('录入运单编号查询', {
			userNative: false
		}).focus(function() {
			$(this).select();
		}).keypress(function(e) {
			if (e.keyCode == 13) {
				if ($(this).val() == "") return;
				var params = $(this).data('params');
				$.extend(params, {
					"search[bill_no_eq]": $(this).val()
				});
				//添加发货站或到货站id
				if ($('#from_org_id').length > 0) $.extend(params, {
					"search[from_org_id_eq]": $('#from_org_id').val()
				});
				if ($('#to_org_id').length > 0) $.extend(params, {
					"search[to_org_id_eq]": $('#to_org_id').val()
				});
				if ($('#transit_org_id').length > 0) $.extend(params, {
					"search[transit_org_id_eq]": $('#transit_org_id').val()
				});
				if ($('#from_org_id_or_to_org_id').length > 0) $.extend(params, {
					"search[from_org_id_or_to_org_id_eq]": $('#from_org_id_or_to_org_id').val()
				});

				$.get('/carrying_bills', params, null, 'script');
				$(this).select();

			}

		})
	});
	//绑定transfer_pay_info_form post_info_form的ajax:before处理
	$('#transfer_pay_info_form,#post_info_form').livequery(function() {
		$(this).bind('ajax:before', function() {
			var bill_els = $('[data-bill]');
			if (bill_els.length == 0) {
				$.notifyBar({
					html: "未查找到任何运单,请先查询要处理的运单",
					delay: 3000,
					animationSpeed: "normal",
					cls: 'error'
				});
				return false;
			}
		});
	});
	$('#deliver_info_form,#cash_pay_info_form,#transit_info_form,#transit_deliver_info_form,#short_fee_info_form,#goods_exception_form,#send_list_form,#send_list_post_form').livequery(function() {
		$(this).bind('ajax:before', function() {
			var bill_els = $('[data-bill]');
			var bill_ids = [];
			//中转提货相关费用
			//获取中转相关费用array
			var get_transit_edit_fields_val = function(el_name) {
				var ret_val = [];

				$('[name^="' + el_name + '"]').each(function() {
					ret_val.push($(this).val());

				});
				return ret_val;
			};

			if (bill_els.length == 0) {
				$.notifyBar({
					html: "未查找到任何运单,请先查询要处理的运单",
					delay: 3000,
					animationSpeed: "normal",
					cls: 'error'
				});
				return false;
			}
			else {
				bill_els.each(function() {
					var bill_id = $(this).data('bill').id;
					bill_ids.push(bill_id);
				});
				$(this).data('params', {
					"bill_ids[]": bill_ids,
					"transit_carrying_fee_edit[]": get_transit_edit_fields_val('transit_carrying_fee_edit'),
					"transit_hand_fee_edit[]": get_transit_edit_fields_val('transit_hand_fee_edit'),
					"transit_to_phone_edit[]": get_transit_edit_fields_val('transit_to_phone_edit'),
					"transit_bill_no_edit[]": get_transit_edit_fields_val('transit_bill_no_edit')

				});
			}
			return true;
		})
	});
	//对票据进行操作时,计算合计值
	var cal_sum = function() {
		var sum_carrying_fee = 0;
		var sum_goods_fee = 0;
		var sum_carrying_fee_th = 0;
		var sum_k_carrying_fee = 0;
		var sum_transit_carrying_fee = 0;
		var sum_transit_hand_fee = 0;
		var sum_k_hand_fee = 0;
		var sum_act_pay_fee = 0;
		var sum_from_short_carrying_fee = 0;
		var sum_to_short_carrying_fee = 0;
		var sum_insured_fee = 0;
		var sum_th_amount = 0;

		$('#bills_table_body tr[data-bill]').each(function() {
			var the_bill = $(this).data('bill');
			sum_carrying_fee += parseFloat(the_bill.carrying_fee);
			sum_carrying_fee_th += parseFloat(the_bill.carrying_fee_th);
			sum_k_carrying_fee += parseFloat(the_bill.k_carrying_fee);
			sum_transit_carrying_fee += parseFloat(the_bill.transit_carrying_fee);
			sum_transit_hand_fee += parseFloat(the_bill.transit_hand_fee);
			sum_th_amount += parseFloat(the_bill.th_amount);
			sum_k_hand_fee += parseFloat(the_bill.k_hand_fee);
			sum_act_pay_fee += parseFloat(the_bill.act_pay_fee);
			sum_goods_fee += parseFloat(the_bill.goods_fee);
			sum_from_short_carrying_fee += parseFloat(the_bill.from_short_carrying_fee);
			sum_to_short_carrying_fee += parseFloat(the_bill.to_short_carrying_fee);
			sum_insured_fee += parseFloat(the_bill.insured_fee);

		});

		$('#count').html($('[data-bill]').length + '票');
		$('#sum_carrying_fee').html(sum_carrying_fee);
		$('#sum_from_short_carrying_fee').html(sum_from_short_carrying_fee);
		$('#sum_to_short_carrying_fee').html(sum_to_short_carrying_fee);
		$('#sum_k_carrying_fee').html(sum_k_carrying_fee);
		$('#sum_transit_hand_fee').html(sum_transit_hand_fee);
		$('#sum_transit_carrying_fee').html(sum_transit_carrying_fee);
		$('#sum_carrying_fee_th').html(sum_carrying_fee_th);
		$('#sum_k_hand_fee').html(sum_k_hand_fee);
		$('#sum_act_pay_fee').html(sum_act_pay_fee);
		$('#sum_goods_fee').html(sum_goods_fee);
		$('#sum_th_amount').html(sum_th_amount);
		$('#sum_insured_fee').html(sum_insured_fee);
		//计算可修改字段
		var cal_edit_field_sum = function(field_class) {
			var sum = 0;
			$("tr.bill_cal_sum " + "." + field_class + " input").each(function() {
				var val = parseFloat($(this).val());
				sum += val;
			});
			$("#sum_" + field_class).html(sum);
		};
		var edit_fields = ["transit_carrying_fee_edit", "transit_hand_fee_edit"]
		$.each(edit_fields, function(index, value) {
			cal_edit_field_sum(value)
		});

	};
	//绑定明细变化事件
	//货物中转及中转提货时,进行合计
	$('#bills_table_body').bind('tr_changed', cal_sum).bind('change', function(evt) {
		var target_el = $(evt.target).parent('td');

		if (target_el && (target_el.hasClass('transit_carrying_fee_edit') || target_el.hasClass('transit_hand_fee_edit')))
		//触发运单明细改变事件
		$('#bills_table_body').trigger('tr_changed');

	});

	//生成结算清单时,绑定查询条件
	$('#btn_generate_settlement').bind('ajax:before', function() {
		var params = {
			"search[to_org_id_or_transit_org_id_eq]": $('#to_org_id').val(),
			"search[state_eq]": 'deliveried',
			"search[completed_eq]": 0,
			"search[type_in][]": ['ComputerBill', 'HandBill', 'ReturnBill', 'TransitBill', 'HandTransitBill'],
			//以下设定运单列表中的显示及隐藏字段,设定为css选择符
			"hide_fields": ".carrying_fee,.insured_fee",
			"show_fields": ".transit_carrying_fee,.transit_hand_fee,.carrying_fee_th,.th_amount"
		};
		$(this).data('params', params);
	}).bind('ajax:complete', function() {
		if ($('#bills_table').length == 0) return;
		var sum_info = $('#bills_table').data('sum');
		var ids = $('#bills_table').data('ids');
		$('#settlement_sum_carrying_fee').val(sum_info.sum_carrying_fee_th);
		$('#settlement_sum_goods_fee').val(sum_info.sum_goods_fee);
		$('#settlement_sum_transit_carrying_fee').val(sum_info.sum_transit_carrying_fee);
		$('#settlement_sum_transit_hand_fee').val(sum_info.sum_transit_hand_fee);
		$('#settlement_sum_fee').html(parseFloat(sum_info.sum_goods_fee) + parseFloat(sum_info.sum_carrying_fee_th) - parseFloat(sum_info.sum_transit_carrying_fee) - parseFloat(sum_info.sum_transit_hand_fee));
		$('#settlement_form').data('params', {
			'bill_ids[]': ids
		});
	});

	//生成返款清单时,收款单位变化时,列出结算清单
	$('#btn_refound_refresh').click(function() {
		$.get('/settlements', {
			"show_select": 1,
			//是否显示选择列表
			"search[carrying_bills_from_org_id_eq]": $('[name="refound[to_org_id]"]').val(),
			"search[carrying_bills_to_org_id_or_carrying_bills_transit_org_id_eq]": $('[name="refound[from_org_id]"]').val(),
			"search[carrying_bills_type_in][]": ["ComputerBill", "HandBill", "TransitBill", "HandTransitBill", "ReturnBill"],
			"search[carrying_bills_state_eq]": "settlemented",
			"search[carrying_bills_completed_eq]": 0,
			"search[carrying_bills_goods_fee_or_carrying_bills_carrying_fee_gt]": 0
		},
		null, 'script')
	});
	//全选结算清单
	$('#check_all').live('click', function() {
		$('input[name^="selector"]').each(function() {
			$(this).attr('checked', $('#check_all').attr('checked'));
		});

	});
	//绑定生成返款清单按钮
	$('#btn_generate_refound').bind('ajax:before', function() {
		var selected_bill_ids = [];
		$('input[name^="selector"]').each(function() {
			if ($(this).attr('checked')) selected_bill_ids.push($(this).val());
		});
		if (selected_bill_ids.length == 0) {
			$.notifyBar({
				html: "请选择要生成返款清单的结算清单!",
				delay: 3000,
				animationSpeed: "normal",
				cls: 'error'
			});
			return false;

		}

		var params = {
			"search[from_org_id_eq]": $('[name="refound[to_org_id]"]').val(),
			"search[to_org_id_or_transit_org_id_eq]": $('[name="refound[from_org_id]"]').val(),
			"search[type_in][]": ["ComputerBill", "HandBill", "TransitBill", "HandTransitBill", "ReturnBill"],
			"search[state_eq]": "settlemented",
			"search[completed_eq]": 0,
			"search[goods_fee_or_carrying_fee_gt]": 0,
			"search[settlement_id_in][]": selected_bill_ids,
			"hide_fields": ".carrying_fee,.insured_fee,.carrying_fee_total",
			'show_fields': ".th_amount,:carrying_fee_th_total,.insured_fee_total,.carrying_fee_th"
		};
		$(this).data('params', params);
	}).bind('ajax:complete', function() {
		if ($('#bills_table').length == 0) return;
		var sum_info = $('#bills_table').data('sum');
		var ids = $('#bills_table').data('ids');
		$('#refound_sum_goods_fee').val(sum_info.sum_goods_fee);
		$('#refound_sum_carrying_fee').val(sum_info.sum_carrying_fee_th);
		$('#refound_sum_transit_carrying_fee').val(sum_info.sum_transit_carrying_fee);
		$('#refound_sum_transit_hand_fee').val(sum_info.sum_transit_hand_fee);
		$('#refound_sum_fee').html(sum_info.sum_th_amount);

		$('#refound_form').data('params', {
			'bill_ids[]': ids
		});
	});
	//保存结算清单和返款清单时,判断是否查询了相关的运单
	$('#settlement_form,#refound_form').livequery(function() {
		$(this).bind('ajax:before', function() {
			var selected_bill_ids = $(this).data('params');
			if (typeof(selected_bill_ids) == 'undefined' || selected_bill_ids.length == 0) {
				$.notifyBar({
					html: "当前未选择任何运单!",
					delay: 3000,
					animationSpeed: "normal",
					cls: 'error'
				});
				return false;

			}

		});
	});
	//生成代收货款支付清单
	var gen_payment_list = function(evt) {
		var params = {
			"search[state_eq]": "refunded_confirmed",
			"search[type_in][]": ["ComputerBill", "HandBill", "TransitBill", "HandTransitBill"],
			"search[goods_fee_gt]": 0,
			"search[completed_eq]": 0,
			//运单列表显示的字段
			"hide_fields": ".carrying_fee,.insured_fee",
			"show_fields": ".k_carrying_fee,.k_hand_fee,.transit_hand_fee,.act_pay_fee"
		};
		if (evt.data.is_cash) {
			params["search[from_customer_id_is_null"] = "1";
			params["search[from_org_id_eq]"] = $('#from_org_id').val();
		}
		else {
			params["search[from_customer_id_is_not_null"] = "1";
			params["search[from_customer_bank_id_eq]"] = $('#bank_id').val();
		}

		$.get('/carrying_bills', params, null, 'script');

	};
	$('#btn_generate_cash_payment_list').click({
		is_cash: true
	},
	gen_payment_list);
	$('#btn_generate_transfer_payment_list').click({
		is_cash: false
	},
	gen_payment_list);

	//批量提款,银行转账界面,绑定生成批量提款清单按钮功能
	$('#btn_generate_transfer_pay_info').bind('ajax:before', function() {
		var selected_bill_ids = [];
		$('input[name^="selector"]').each(function() {
			if ($(this).attr('checked')) selected_bill_ids.push($(this).val());
		});
		if (selected_bill_ids.length == 0) {
			$.notifyBar({
				html: "请选择要批量提款的代收货款支付清单!",
				delay: 3000,
				animationSpeed: "normal",
				cls: 'error'
			});
			return false;

		}
		var params = {
			"search[type_in][]": ["ComputerBill", "HandBill", "TransitBill", "HandTransitBill"],
			"search[state_eq]": "payment_listed",
			"search[payment_list_id_in][]": selected_bill_ids,
			"hide_fields": ".carrying_fee,.insured_fee",
			"show_fields": ".k_carrying_fee,.k_hand_fee,.transit_hand_fee,.act_pay_fee"
		};
		$(this).data('params', params);
	}).bind('ajax:complete', function() {
		if ($('#bills_table').length == 0) return;
		var ids = $('#bills_table').data('ids');
		$('#transfer_pay_info_form').data('params', {
			'bill_ids[]': ids
		});
	});

	//客户提款结算清单
	//实领金额变化时,更新余额
	var cal_rest_fee = function() {
		var amount_fee = parseFloat($('#post_info_amount_fee').val());
		var sum_pay_fee = parseFloat($('#sum_pay_fee').val());
		var rest_fee = amount_fee - sum_pay_fee;
		$('#sum_rest_fee').val(rest_fee);

	};

	$('#btn_generate_post_info').bind('ajax:before', function() {
		var params = {
			"search[from_org_id_eq]": $('#from_org_id').val(),
			"search[state_eq]": 'paid',
			"search[completed_eq]": 0,
			"search[from_customer_id_is_null]": 1,
			"search[type_in][]": ['ComputerBill', 'HandBill', 'TransitBill', 'HandTransitBill'],
			"hide_fields": ".carrying_fee,.insured_fee",
			"show_fields": ".k_carrying_fee,.transit_hand_fee,.k_hand_fee,.act_pay_fee"

		};
		$(this).data('params', params);
	}).bind('ajax:complete', function() {
		if ($('#bills_table').length == 0) return;
		var sum_info = $('#bills_table').data('sum');
		var ids = $('#bills_table').data('ids');
		$('#sum_goods_fee').val(sum_info.sum_goods_fee);
		$('#sum_k_carrying_fee').val(sum_info.sum_k_carrying_fee);
		$('#sum_k_hand_fee').val(sum_info.sum_k_hand_fee);
		$('#sum_transit_hand_fee').val(sum_info.sum_transit_hand_fee);
		//计算实际提款及余额
		$('#sum_pay_fee').val(sum_info.sum_act_pay_fee);
		$('#post_info_form').data('params', {
			'bill_ids[]': ids
		});
		cal_rest_fee();
	});
	//绑定实领金额变化事件
	$('#post_info_amount_fee').change(cal_rest_fee);

	//中转运单中转操作,处理中转公司下拉列表变化事件
	$('#select_transit_company').change(function() {
		if ($(this).val() == "") {
			$('#new_transit_company').show();
			$('[name*="transit_company_attributes"]').attr('disabled', false);
		}
		else {
			$('#new_transit_company').hide();
			$('[name*="transit_company_attributes"]').attr('disabled', true);
		}
	});

	//送货清单,查询运单后,自动清除已核销或正在送货中的运单记录
	$('#send_list_form_after_wrap tr[data-bill]').livequery(function() {
		var bill = $(this).data('bill');
		//移除已送货或正在送货中的运单
		if (bill.send_state == 'posted' || bill.send_state == 'sended') {
			$.notifyBar({
				html: "该运单已送货或正在送货中!",
				delay: 3000,
				animationSpeed: "normal",
				cls: 'error'
			});
			$(this).remove();

		}

	});

	//送货员未交票统计
	$('#btn_send_list_line_query').bind('ajax:before', function() {
		var params = {
			"search[send_list_line_send_list_sender_id_eq]": $('#sender_id').val(),
			"search[send_list_line_state_eq]": "sended",
			"search[to_org_id_eq]": $('#to_org_id').val(),
			"hide_fields": ".carrying_fee,.insured_fee",
			"show_fields": ".carrying_fee_th,.to_short_carrying_fee"
		};
		$(this).data('params', params);

	});
	//帐目盘点登记表,自动计算合计功能
	$('#journal_form').change(function() {
		var settled_no_rebate_fee = parseFloat($('#journal_settled_no_rebate_fee').val());
		var deliveried_no_settled_fee = parseFloat($('#journal_deliveried_no_settled_fee').val());
		var input_fee_1 = parseFloat($('#journal_input_fee_1').val());
		var input_fee_2 = parseFloat($('#journal_input_fee_2').val());
		var input_fee_3 = parseFloat($('#journal_input_fee_3').val());
		var journal_sum_1 = settled_no_rebate_fee + deliveried_no_settled_fee + input_fee_1 + input_fee_2 + input_fee_3;
		$('#journal_sum_1').html(journal_sum_1);
		var cash = parseFloat($('#journal_cash').val());
		var deposits = parseFloat($('#journal_deposits').val());
		var goods_fee = parseFloat($('#journal_goods_fee').val());
		var short_fee = parseFloat($('#journal_short_fee').val());
		var other_fee = parseFloat($('#journal_other_fee').val());
		var journal_sum_2 = cash + deposits + goods_fee + short_fee + other_fee;
		$('#journal_sum_2').html(journal_sum_2);
		//客户欠款
		var current_debt = parseFloat($('#journal_current_debt').val());
		var current_debt_2_3 = parseFloat($('#journal_current_debt_2_3').val());
		var current_debt_4_5 = parseFloat($('#journal_current_debt_4_5').val());
		var current_debt_ge_6 = parseFloat($('#journal_current_debt_ge_6').val());
		var journal_sum_4 = current_debt + current_debt_2_3 + current_debt_4_5 + current_debt_ge_6;
		$('#journal_sum_4').html(journal_sum_4);

	});

	//vip统计列表
	$('#imported_customer_org_id').change(function() {
		$.get('/imported_customers', {
			"search[org_id_eq]": $(this).val()
		},
		function() {
			$('.tabs a').removeClass('here');
			$('.tabs a').first().addClass('here');
		},
		'script');
	});
	$('#imported_customers_tab a').bind('ajax:before', function() {
		$(this).data('params', {
			"search[org_id_eq]": $('#imported_customer_org_id').val()
		});

	});
	$('.tabs a').click(function() {
		$('.tabs a').removeClass('here');
		$(this).addClass('here');

	});

	//未提货报表,处理各种票据列表底色
	$('.rpt_no_delivery tr.white-bill').livequery(function() {
		$(this).css({
			backgroundColor: 'white',
			color: '#000'
		});
	});
	$('.rpt_no_delivery tr.blue-bill').livequery(function() {
		$(this).css({
			backgroundColor: 'blue',
			color: '#fff'
		});
	});
	$('.rpt_no_delivery tr.green-bill').livequery(function() {
		$(this).css({
			backgroundColor: 'green',
			color: '#fff'
		});
	});
	$('.rpt_no_delivery tr.yellow-bill').livequery(function() {
		$(this).css({
			backgroundColor: 'yellow'

		});
	});
	$('.rpt_no_delivery tr.red-bill').livequery(function() {
		$(this).css({
			backgroundColor: 'red',
			color: '#fff'
		});
	});
	$('.rpt_no_delivery tr.black-bill').livequery(function() {
		$(this).css({
			backgroundColor: 'black',
			color: '#fff'
		});
	});
	$('.turnover_chart').visualize();

	//自动获取明细信息
	$('[data-detailUrl]').livequery(function() {
		var url = $(this).data('detailUrl');
		var params = $(this).data('params');
		$.get(url, params, null, 'script');
	});

	//根据参数显示或隐藏字段
	//render shared/carrying_bills/table时使用
	$('[data-showFields]').livequery(function() {
		$($(this).data('showFields')).show();

	});
	$('[data-hideFields]').livequery(function() {
		$($(this).data('hideFields')).hide();

	});

	//修改org的录单限制时间
	$('form.only_edit_lock_time').livequery(function() {
		$('#org_form :input[type="text"],#org_form :input[type="checkbox"],#org_form select').attr('readonly', true);
		$('#org_form [name*="lock_input_time"]').attr('readonly', false);
	});
	//修改readonly底色
	$('[readonly]').livequery(function() {
		$(this).css({
			backgroundColor: '#E5E5E5'
		});
	});

	//日营业额统计,月营业额统计/代收货款收入-支出统计导出
	$('a[data-table]').click(function() {
		var table_doc = $($(this).data('table')).clone();

		table_doc.find('th,td').css({
			border: 'thin solid #000'
		});
		var set_style = function(work_sheet) {
			work_sheet.Columns.ColumnWidth = 7;
			work_sheet.Columns('A:A').ColumnWidth = 5;

		};
		$.export_excel(table_doc.clone().wrap('<div></div>').parent().html(), set_style);
	});

	//form 自动获取焦点
	$('.inner form').livequery(function() {
		var the_form = $(this);
		if (the_form.hasClass('computer_bill') || the_form.hasClass('transit_bill') || the_form.hasClass('return_bill')) {

			//机打运单,默认焦点定位到到货地
			$('#select_org_input_to_org_id').focus();
			$('#area_id').focus();
		}
		else $('.inner form input:not([readonly])').not('input[type="hidden"]').first().focus();

	});

	//快捷键设置
	$(document).bind('keydown', 'n', function() {
		$.fireClick($('.btn_new')[0]);
	}).bind('keydown', 's', function() {
		$.fireClick($('.btn_save')[0]);
	}).bind('keydown', 'e', function() {
		$.fireClick($('.btn_modify')[0]);
	}).bind('keydown', 'f', function() {
		$.fireClick($('.btn_search')[0]);
	}).bind('keydown', 'd', function() {
		$.fireClick($('.btn_destroy')[0]);
	}).bind('keydown', 'x', function() {
		$.fireClick($('.btn_export_excel')[0]);
	}).bind('keydown', 'l', function() {
		$.fireClick($('.btn_index')[0]);
	}).bind('keydown', 'p', function() {
		$.fireClick($('.btn_print')[0]);
	}).bind('keydown', 'alt+t', function() {
		//任何情况下,点击alt+t打开运单录入
		window.location = "/computer_bills/new";
	}).bind('keydown', 'ctrl+z', function() {
		//任何情况下，可点击ctrl_z打开运单查询界面
		$.fireClick(document.getElementById('btn_advanced_search'));
	});

	//设置notify cookie
	//如果cookie中找到了对应的notify_id，则不显示
	$('[data-notify]').livequery(function() {
		var notify = $(this).data('notify');
		if ($.cookies.get('il_notify_' + notify.id)) $('#notify-bar').hide();
		else $('#notify-bar').show();
	});
	//关闭提醒
	$('span.notify-close').click(function() {
		var notify = $('[data-notify]').data('notify');
		$.cookies.set('il_notify_' + notify.id, notify.notify_text);
		$('#notify-bar').hide();
	});
	//日营业额统计图单击选中
	$('#rpt_turnover').click(function(evt) { //单击某条记录选中
		var target_el = $(evt.target).parent('tr');
		$(this).find('td').css({
			backgroundColor: '#FFF',
			color: '#000',
			fontSize: '1em',
			fontWeight: 'normal'
		});
		$(target_el).find('td').css({
			backgroundColor: '#7A97B7',
			color: '#FFF',
			fontSize: '1.2em',
			fontWeight: 'bold'
		});
	});

});

