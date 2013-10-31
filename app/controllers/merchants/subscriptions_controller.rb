class Merchants::SubscriptionsController < Merchants::BaseController

  before_filter :require_manager
  skip_before_filter :active_subscription?, :only => [:upgrade, :subscribe]

  def upgrade
    @plan = current_shop.subscription.plan
    @subscription=current_merchants_manager.shop.subscription || @plan.subscriptions.build
    current_invoice = Invoice.where(:stripe_customer_token=>@subscription.stripe_customer_token)
    @stripe_last_payment = current_invoice.order(:created_at).last.created_at rescue nil
    ##this part calculates upcoming payment with following assumption
    ##same date next month if date is already passed(date of creation of account)
    ##or same date this month if date hasnt passed
    if (@subscription.created_at.day < Time.now.day)
      @stripe_upcoming_payment = "#{@subscription.created_at.day}#{Time.now.month}#{Time.now.year}"
    else
      next_month = Time.now.to_date >> 1 #shift one moth
      @stripe_upcoming_payment = "#{next_month.month}/#{@subscription.created_at.day}/#{next_month.year}"
    end
    @list_invoice =  current_invoice.order(:id)
    flash[:notice] = 'You will be charged based on the number of connections. For details, refer our pricing plans'
  end

  def invoice
    #if invoice id present fetch it
    @invoice_id = params[:id] rescue nil 
    #wherer(id).group_by plans and then find count of each
    @plan = current_shop.subscription.plan
    @subscription=current_merchants_manager.shop.subscription || @plan.subscriptions.build
  end

  def print
    #if invoice id present fetch it
    @invoice_id = params[:id] rescue nil 
    #wherer(id).group_by plans and then find count of each
    @plan = current_shop.subscription.plan
    @subscription=current_merchants_manager.shop.subscription || @plan.subscriptions.build
    kit = PDFKit.new(html, :page_size => 'Letter')
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
