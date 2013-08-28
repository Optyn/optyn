class CacheController < ApplicationController
  http_basic_authenticate_with name: SiteConfig.cache_auth_username, password: SiteConfig.cache_auth_password

  def flush
    # Rails.cache.clear
    render nothing: true
  end
end
