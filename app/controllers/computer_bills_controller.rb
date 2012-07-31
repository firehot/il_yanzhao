# -*- encoding : utf-8 -*-
require 'new_relic/agent/method_tracer'
class ComputerBillsController < CarryingBillsController
  include NewRelic::Agent::MethodTracer
  defaults :resource_class => ComputerBill
  include BillOperate::BillPrint

  add_method_tracer :new, 'Custom/computer_bills_new'
end
