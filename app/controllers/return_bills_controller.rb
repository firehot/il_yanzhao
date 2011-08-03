#coding: utf-8
class ReturnBillsController <  CarryingBillsController
  def before_new
  end
  def new
    if params[:search].blank? or params[:search][:bill_no_eq].blank?
      flash[:error] = "请录入原运单号码."
      render :action => :before_new
    else
      the_bills = CarryingBill.search(params[:search]).all
      if the_bills.blank?
        flash[:error] = "未找到原始运单信息,只有运单到货后才可退货."
        render :action => :before_new
      else
        original_bill = the_bills.first
        @return_bill = original_bill.generate_return_bill
        render :new
      end
    end
  end
  def create
    @return_bill = ReturnBill.new(params[:return_bill])
    @return_bill.original_bill.return
    create!
  end
end
