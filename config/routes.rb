# -*- encoding : utf-8 -*-
IlYanzhao::Application.routes.draw do

  resources :load_list_with_barcodes do
    put :confirm,:on => :member
  end

  resources :auto_calculate_computer_bills do
    get :search,:on => :collection
    get :export_excel,:on => :collection
    put :invalidate,:on => :member
    put :print_counter,:on => :member
    put :cancel,:on => :member
  end

  resources :goods_cat_fee_configs do
    get :single_config_line,:on => :collection
  end
  resources :notices do
    get :search,:on => :collection
    get :new_with_no_delivery,:on => :collection
  end

  resources :goods_cats

  resources :act_load_lists,:except => [:new] do
    get :search,:on => :collection
    get :export_excel,:on => :member
  end

  resources :goods_fee_settlement_lists do
    get :search,:on => :collection
    put :post,:on => :member
  end

  resources :notifies

  resources :areas

  resources :goods_errors do
    #显示核销界面
    get :show_authorize,:on => :member
    get :search,:on => :collection
  end

  resources :imported_customers

  resources :customer_fee_infos do
    get :search,:on => :collection
  end

  resources :customer_level_configs

  resources :journals do
    get :search,:on => :collection
  end

  resources :remittances do
    get :search,:on => :collection
  end

  resources :send_list_backs do
    get :search,:on => :collection
    get :export_excel,:on => :member
  end

  resources :send_list_posts do
    get :search,:on => :collection
    get :export_excel,:on => :member
  end

  resources :send_lists do
    get :search,:on => :collection
    get :export_excel,:on => :member
  end

  resources :senders

  resources :goods_exceptions do
    #显示授权核销界面
    get :show_authorize,:on => :member
    get :show_claim,:on => :member
    get :show_identify,:on => :member
    put :do_post,:on => :member
    get :search,:on => :collection
  end

  resources :short_fee_infos do
    get :search,:on => :collection
    get :export_excel,:on => :member
    #短途运费核销
    put :write_off,:on => :member
  end

  resources :il_configs

  resources :config_cashes

  resources :config_transits

  resources :roles

  #将devise的url与model user产生的url区分开
  #参见https://github.com/plataformatec/devise/wiki/How-To:-Manage-users-through-a-CRUD-interface
  devise_for :users,:controllers => {:sessions => "sessions"}
  as :user do
    #登录成功后显示设置角色与部门界面
    match "new_session_default",:to => "sessions#new_session_default",:via => :get,:as => :user_root
    #保存用户设置
    match  "update_session_default",:to => "sessions#update_session_default",:via => :put,:as => :update_session_default
    match  "sign_in_mobile" => "sessions#sign_in_mobile",:via => :put,:as => :sign_in_mobile
  end

  resources :users do
    get :search,:on => :collection
    get :edit_password,:on => :collection
    get :reset_usb_pin,:on => :member
    put :update_password,:on => :collection
  end

  resources :transit_deliver_infos do
    get :search,:on => :collection
    resources :carrying_bills
  end

  resources :transit_companies

  resources :transit_infos do
    get :search,:on => :collection
    resources :carrying_bills
  end

  resources :post_infos do
    get :search,:on => :collection
    get :export_excel,:on => :member
    resources :carrying_bills
  end

  resources :transfer_pay_infos do
    get :search,:on => :collection
    resources :carrying_bills
  end


  resources :cash_pay_infos do
    get :search,:on => :collection
    resources :carrying_bills
  end

  resources :transfer_payment_lists do
    get :search,:on => :collection
    get :export_excel,:on => :member
    get :process_handle,:on => :member
    resources :carrying_bills
  end


  resources :cash_payment_lists do
    get :search,:on => :collection
    get :export_excel,:on => :member
    get :export_sms_txt,:on => :member
    resources :carrying_bills
  end

  resources :vips do
    get :search,:on => :collection
    put :syn_from_customer_name,:on => :member
  end

  resources :customers

  resources :banks

  resources :refounds do
    get :process_handle,:on => :member
    get :search,:on => :collection
    get :export_excel,:on => :member
    resources :carrying_bills
  end
  #返款清单确认
  resources :receive_refounds do
    get :process_handle,:on => :member
    get :search,:on => :collection
    get :export_excel,:on => :member
    resources :carrying_bills
  end

  resources :settlements do
    get :search,:on => :collection
    get :export_excel,:on => :member
    #中转交款确认
    put :direct_refunded_confirmed,:on => :member
    #交款确认
    get :process_handle,:on => :member
    resources :carrying_bills
  end

  resources :deliver_infos do
    get :search,:on => :collection
    resources :carrying_bills
  end


  resources :distribution_lists do
    get :search,:on => :collection
    get :export_excel,:on => :member
    resources :carrying_bills
  end

  resources :load_lists do
    get :process_handle,:on => :member
    get :search,:on => :collection
    get :export_excel,:on => :member
    get :build_act_load_list,:on => :member
    resources :carrying_bills
  end

  resources :arrive_load_lists do
    get :process_handle,:on => :member
    get :search,:on => :collection
    get :export_excel,:on => :member
    post :export_sms_txt,:on => :member
    get :build_notice,:on => :member
    get :show_export_sms,:on => :member
    resources :carrying_bills
  end

  resources :hand_transit_bills do
    get :search,:on => :collection
    get :export_excel,:on => :collection
    put :invalidate,:on => :member
    put :cancel,:on => :member
  end

  resources :transit_bills do
    get :search,:on => :collection
    get :export_excel,:on => :collection
    put :invalidate,:on => :member
    put :cancel,:on => :member
    put :print_counter,:on => :member
  end

  resources :hand_bills do
    get :search,:on => :collection
    get :export_excel,:on => :collection
    put :invalidate,:on => :member
    put :cancel,:on => :member
  end

  resources :return_bills do
    get :before_new,:on => :collection
    get :search,:on => :collection
    get :export_excel,:on => :collection
    put :invalidate,:on => :member
    put :cancel,:on => :member
    put :print_counter,:on => :member
  end

  resources :orgs

  resources :branches
  resources :departments

  #添加carrying_biils路由
  resources :carrying_bills do
    get :rpt_turnover,:on => :collection
    get :turnover_chart,:on => :collection
    get :search,:on => :collection
    get :simple_search,:on => :collection
    get :simple_search_with_created_at,:on => :collection
    get :export_excel,:on => :collection
    get :export_sms_txt,:on => :collection
    get :sum_goods_fee_inout,:on => :collection
    get :search_service_page,:on => :collection
    get :search_service,:on => :collection
    get :multi_bills_search,:on => :collection
    get :customer_code_search,:on => :collection
    put :reset,:on => :member
    put :invalidate,:on => :member
    put :cancel,:on => :member
    #批量删除
    delete :batch_destroy,:on => :collection
  end

  resources :computer_bills do
    get :search,:on => :collection
    get :export_excel,:on => :collection
    put :invalidate,:on => :member
    put :cancel,:on => :member
    put :print_counter,:on => :member
  end

  root :to => "dashboard#index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

