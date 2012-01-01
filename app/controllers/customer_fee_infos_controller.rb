class CustomerFeeInfosController < BaseController
  #GET /customer_fee_infos/search
  def search
    render :partial => "search"
  end
end
