module GoodsCatsHelper
  #货物大类选择
  def parent_goods_cats_for_select
    GoodsCat.search(:parent_id_is_null => true).all.map {|cat| [cat.name,cat.id]}

  end
end
