Resque::Server.use(Rack::Auth::Basic) do |user, password|
  password == SiteConfig.resque_auth_password
end