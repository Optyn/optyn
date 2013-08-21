class MainController < ApplicationController
  before_filter :require_not_logged_in, only: [:index]

  # def index
  #   render layout: 'flat'
  # end

  # def terms
  #   render layout: 'flat'
  # end

  # def about
  #   render layout: 'flat'
  # end

  # def faq
  #   render layout: 'flat'
  # end

  # def consumerfeatures
  #   render layout: 'flat'
  # end
end
