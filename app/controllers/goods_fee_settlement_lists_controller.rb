class GoodsFeeSettlementListsController < BaseController
  #定义列表显示的列
  table :bill_date,:org,:amount_income_fee,:amount_spending_fee,:rest_fee,:user
end
