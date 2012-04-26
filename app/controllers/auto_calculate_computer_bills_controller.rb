#自动计算运单
class AutoCalculateComputerBillsController < CarryingBillsController
  defaults :resource_class => AutoCalculateComputerBill
  include BillOperate::BillPrint
end
