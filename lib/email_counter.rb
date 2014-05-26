class EmailCounter
  SES_KEY = "SES"
  SENDGRID_KEY = "SENDGRID"
  class << self
    def increment_ses
      REDIS.incr(SES_KEY)
    end

    def increment_sendgrid
      REDIS.incr(SENDGRID_KEY)
    end

    def fetch_email_delivery_type
      if REDIS[SES_KEY].to_i <= REDIS[SENDGRID_KEY].to_i   
        SES_KEY
      elsif REDIS[SES_KEY].to_i > REDIS[SENDGRID_KEY].to_i
        SENDGRID_KEY
      end

      SENDGRID_KEY
    end

  end #end of self block
end