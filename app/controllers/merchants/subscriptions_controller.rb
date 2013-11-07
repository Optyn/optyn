class Merchants::SubscriptionsController < Merchants::BaseController
  require 'pdfkit'
  before_filter :require_manager
  skip_before_filter :active_subscription?, :only => [:upgrade, :subscribe]

  def upgrade
    # binding.pry
    ##FIXME:add a check for valid subscrition
    @plan = current_shop.subscription.plan
    @subscription=current_merchants_manager.shop.subscription || @plan.subscriptions.build
    current_charges = Charge.where(:customer=>@subscription.stripe_customer_token)
    @amount = current_charge.amount / 100  rescue nil #because its in cents
    @stripe_last_payment = current_charges.order(:created_at).last.created_at rescue nil
      
    ##this part calculates upcoming payment with following assumption
    ##same date next month if date is already passed(date of creation of account)
    ##or same date this month if date hasnt passed
    if (@subscription.created_at.day < Time.now.day)
      @stripe_upcoming_payment = "#{@subscription.created_at.day}#{Time.now.month}#{Time.now.year}"
    else
      next_month = Time.now.to_date >> 1 #shift one moth
      @stripe_upcoming_payment = "#{next_month.month}/#{@subscription.created_at.day}/#{next_month.year}"
    end
    @list_charges =  current_charges.order(:id)
    flash[:notice] = 'You will be charged based on the number of connections. For details, refer our pricing plans'
  end

  def invoice
    binding.pry
    #if invoice id present fetch it
    @charge = Charge.find(params[:id]) rescue nil 
    #wherer(id).group_by plans and then find count of each
    @plan = current_shop.subscription.plan
    @subscription=current_merchants_manager.shop.subscription || @plan.subscriptions.build
  end

  def print
    #if invoice id present fetch it
    if params[:id].present?
      charge_id = params[:id]
      @charge = Charge.find(charge_id)
      @custmer_name = ""
      @discount = nil
      @discount_amount = 0.00
      @total = @charge.amount
      filename = "/tmp/#{Time.now}-#{@invoice_id}.pdf"
      #wherer(id).group_by plans and then find count of each
      @plan = current_shop.subscription.plan
      @subscription=current_merchants_manager.shop.subscription || @plan.subscriptions.build
      html = render_to_string :partial => "/merchants/subscriptions/core_invoice",
                              :local=> {:params=>params},
                              :layout => false
      kit = PDFKit.new(html, :page_size => 'Letter')
      kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/invoice_pdf.css"
      file = kit.to_file(filename)
      send_file(file,:type => "application/pdf")
    end
  end

  def edit_billing_info
    @plan= current_shop.subscription.plan
    @subscription = current_shop.subscription
  end

  def update_billing_info
    @subscription = current_shop.subscription
    begin
      @stripe_customer= Stripe::Customer.retrieve(@subscription.stripe_customer_token)
      @stripe_customer.card = params['stripeToken']
      @stripe_customer.save
      redirect_to root_path
    rescue => e
      @subscription.stripe_error = e.to_s
      render 'edit_billing_info'
    end
  end

  def subscribe
    begin
      @plan = current_shop.subscription.plan
      params[:stripe_plan_id] = @plan.plan_id
      @subscription = current_shop.subscription || Subscription.new()
      @subscription.attributes = params[:subscription]

      Subscription.transaction do
        @customer = Subscription.create_or_stripe_customer_card(@subscription, params)

        @subscription.stripe_customer_token = @customer['id']
        if @subscription.save
          @subscription.update_attribute(:active, true)
          amount = @customer.subscription.plan.amount
          conn_count = current_shop.active_connection_count
          last4 = @customer.active_card.last4
          Resque.enqueue(PaymentNotificationSender, 'MerchantMailer', 'payment_notification', {shop_id: current_shop, amount: amount, conn_count: conn_count, last4: last4})
          flash[:notice]="Payment done successfully"
          redirect_to (session[:return_to] || root_path)
        else
          render 'upgrade'
        end
      end

    rescue Exception => e
      if e.respond_to?(:code)
        @subscription.stripe_error = e.code.humanize
      else
        @subscription.stripe_error = e.to_s
      end
      render 'upgrade'
    end



  end
end
