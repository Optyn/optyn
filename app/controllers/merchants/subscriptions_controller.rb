class Merchants::SubscriptionsController < Merchants::BaseController
  require 'pdfkit'
  before_filter :require_manager
  skip_before_filter :active_subscription?, :only => [:upgrade, :subscribe]

  def upgrade
    # binding.pry
    ##FIXME:add a check for valid subscrition
    @plan = current_shop.plan
    @subscription = current_shop.subscription || @plan.subscriptions.build
    @list_charges = Charge.for_customer(@subscription.stripe_customer_token)
    @amount = (current_charge.amount.to_f / 100 ) rescue nil #because its in cents
    # binding.pry
    @stripe_last_payment = @list_charges.first rescue nil
    @card_last4 = @stripe_last_payment.card_last4 rescue nil
      
    ##this part calculates upcoming payment with following assumption
    ##same date next month if date is already passed(date of creation of account)
    ##or same date this month if date hasnt passed
    if (@subscription.created_at.day > Time.now.day)
      @stripe_upcoming_payment = "#{@subscription.created_at.day}/#{Time.now.month}/#{Time.now.year}"
    else
      next_month = Time.now.to_date >> 1 #shift one moth
      @stripe_upcoming_payment = "#{next_month.month}/#{@subscription.created_at.day}/#{next_month.year}"
    end
    flash[:notice] = 'You will be charged based on the number of connections. For details, refer our pricing plans'
  end

  def invoice
    # binding.pry
    @charge = Charge.find(params[:id]) rescue nil
    @invoice = Invoice.where(:stripe_invoice_id=>@charge.stripe_invoice_token).first rescue nil
    @plan = Plan.where(:plan_id => @invoice.stripe_plan_token).first rescue nil
    @coupon = Coupon.where(:stripe_id => @invoice.stripe_coupon_token).first rescue nil

    @amount = @invoice.amount.to_f / 100 rescue nil
    @subtotal = @invoice.subtotal.to_f / 100 rescue nil
    @total = @invoice.total.to_f / 100 rescue nil
    @discount_amount = @total - @subtotal rescue nil
    @card_last4= @charge.card_last4 rescue nil

    #wherer(id).group_by plans and then find count of each
    # @plan = current_shop.subscription.plan
    # @subscription=current_merchants_manager.shop.subscription || @plan.subscriptions.build
  end

  def print
    #if invoice id present fetch it
    if params[:id].present?
      # binding.pry
      @charge = Charge.find(params[:id]) rescue nil
      @invoice = Invoice.where(:stripe_invoice_id=>@charge.stripe_invoice_token).first rescue nil
      @plan = Plan.where(:plan_id => @invoice.stripe_plan_token).first rescue nil
      @coupon = Coupon.where(:stripe_id => @invoice.stripe_coupon_token).first rescue nil

      @amount = @invoice.amount.to_f / 100 rescue nil
      @subtotal = @invoice.subtotal.to_f / 100 rescue nil
      @total = @invoice.total.to_f / 100 rescue nil
      @discount_amount = @total - @subtotal rescue nil
      @card_last4= @charge.card_last4 rescue nil

      filename = "/tmp/#{Time.now}-#{@invoice_id}.pdf"
 
      html = render_to_string :partial => "/merchants/subscriptions/core_invoice",
                              :local=> {:params=>params},
                              :layout => false
      kit = PDFKit.new(html, :page_size => 'Letter')
      kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/invoice_pdf.css"
      # binding.pry
      file = kit.to_file(filename) rescue nil
      if !file.nil?
        send_file(file,:type => "application/pdf")
      else
        flash[:notice]= "Couldnt Create Invoice"
        render :nothing => true  and return
      end
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
    # binding.pry
    begin
      @plan = current_shop.subscription.plan
      params[:stripe_plan_id] = @plan.plan_id
      @subscription = current_shop.subscription || Subscription.new()
      @subscription.attributes = params[:subscription]
      # binding.pry
      Subscription.transaction do
        # binding.pry
        @customer = Subscription.create_stripe_customer_card(@subscription, params)
        # binding.pry
        @subscription.stripe_customer_token = @customer['id']
        if @subscription.save
          @subscription.update_attribute(:active, true)
          amount = @customer.subscription.plan.amount
          conn_count = current_shop.active_connection_count
          # binding.pry
          ##TODO: fix last4
          last4 = @customer.active_card.last4 rescue nil
          Resque.enqueue(PaymentNotificationSender, 'MerchantMailer', 'payment_notification', {shop_id: current_shop, amount: amount, conn_count: conn_count, last4: last4})
          flash[:notice]="Payment done successfully"
          redirect_to (session[:return_to] || root_path)
        else
          render 'upgrade'
        end
      end

    rescue Exception => e
      # binding.pry
      if e.respond_to?(:code)
        @subscription.stripe_error = e.code.humanize
      else
        @subscription.stripe_error = e.to_s
      end
      render 'upgrade'
    end



  end
end
