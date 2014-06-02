class EmailCounter
  SES_KEY = "SES"
  SENDGRID_KEY = "SENDGRID"
  SENDGRID_SEND_LIMIT = "SENDGRID_SEND_LIMIT"


  class << self
    def increment_ses
      REDIS.incr(SES_KEY)
    end

    def increment_sendgrid
      REDIS.incr(SENDGRID_KEY)
    end

    def initialize_if
      REDIS[SENDGRID_SEND_LIMIT] = "1000" if REDIS[SENDGRID_SEND_LIMIT].to_i == 0    
    end

    def set_send_limit(val)
      REDIS[SENDGRID_SEND_LIMIT] = val.to_s
    end

    def fetch_email_delivery_type
      if REDIS[SENDGRID_KEY].to_i <= REDIS[SENDGRID_SEND_LIMIT].to_i
        SENDGRID_KEY
      else
        SES_KEY
      end 
    end

  end #end of self block
end