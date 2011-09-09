class ShortFeeInfoLine < ActiveRecord::Base
  belongs_to :short_fee_info
  belongs_to :carrying_bill
end
