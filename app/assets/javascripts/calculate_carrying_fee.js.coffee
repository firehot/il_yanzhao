$ ->
  #建立分类字典
  goods_cats = $('#parent_goods_cat_id').data("goods_cats")
  #构造goods_cat_id select

  get_goods_cat_fee_config = ->
    data_params =
      "search[goods_cat_fee_config_from_org_id_eq]": $('#from_org_id').val()
      "search[goods_cat_fee_config_to_org_id_eq]": $('#to_org_id').val()
      "search[goods_cat_id_eq]": $('#goods_cat_id').val()

    #计算运费金额
    cal_carrying_fee = (fee_config) ->
      if fee_config
        #单位价格
        unit_price = parseFloat fee_config.unit_price
        $('#unit_price').val(unit_price)
        #底价
        bottom_price = parseFloat fee_config.bottom_price
        #体积
        goods_volume = parseFloat $('#goods_volume').val()
        amt = unit_price*goods_volume
        #合计金额小于最低价时,按最低价处理
        amt = bottom_price if amt < bottom_price
        #获取优惠信息
        #FIXME 如果服务器端返回的是父机构的运费计算设置信息,则查找优惠信息时,也按照父机构的优惠信息进行查询
        cat_with_promotions = (cat for cat in goods_cats when cat.id == fee_config.goods_cat_id)
        if cat_with_promotions.length
          $('#goods_info').val(cat_with_promotions[0].name)
          promotions = cat_with_promotions[0].goods_cat_promotions
          match_promotions = (p for p in promotions when amt > parseFloat(p.from_fee) and amt <= parseFloat(p.to_fee))
          amt = amt - parseFloat(match_promotions[0].promotion_rate)*amt if match_promotions.length

        $('#carrying_fee').val(Math.ceil(amt))
        Math.ceil(amt)
      else
        $('#unit_price').val(0)
        $('#carrying_fee').val(0)

    #发起ajax请求
    $.getJSON('/goods_cat_fee_configs/single_config_line.js',data_params,cal_carrying_fee)

  #大类选择发生变化时,自动更新小类列表
  on_parent_goods_cat_change = ->
    children = (cat for cat in goods_cats when cat.parent_id == (Number) $('#parent_goods_cat_id').val())
    $('#goods_cat_id').empty()
    ($('#goods_cat_id').append("<option value=#{cat.id}>#{cat.name}(#{cat.easy_code})</option>") for cat in children)
    $('#goods_cat_id').trigger('change').ufd('changeOptions')

  $('#parent_goods_cat_id').livequery('change',on_parent_goods_cat_change)

  $('.auto_calculate_computer_bill #parent_goods_cat_id').livequery( -> $(this).ufd())
  $('form.auto_calculate_computer_bill #goods_cat_id').livequery(-> $(this).ufd())
  $('form.auto_calculate_computer_bill #goods_cat_id').livequery("change",get_goods_cat_fee_config)
  #以下字段发生变化时,自动计算运费
  $('form.auto_calculate_computer_bill #from_org_id,form.auto_calculate_computer_bill #to_org_id,form.auto_calculate_computer_bill #goods_volume').livequery('change',get_goods_cat_fee_config)
