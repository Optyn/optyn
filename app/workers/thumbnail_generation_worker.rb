class ThumbnailGenerationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :general_queue, :backtrace => true

  def perform(template_id)
    Template.generate_thumbnail(template_id)
  end
end
