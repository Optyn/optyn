class Merchants::FacebookController < ApplicationController

  def index   
    session[:oauth] = Koala::Facebook::OAuth.new(Facebook::APP_ID, Facebook::SECRET, "#{Facebook::REDIRECT_URL}/share_message/#{params[:message_id]}")
    @auth_url =  session[:oauth].url_for_oauth_code(:permissions=>"publish_stream")  
    puts session.to_s + "<<< session"
    redirect_to @auth_url
  end

  def share_message
    if params[:code]
      # acknowledge code and get access token from FB
      session[:access_token] = session[:oauth].get_access_token(params[:code])
    end   

     # auth established, now do a graph call:
      
    @graph = Koala::Facebook::API.new(session[:access_token])
    message = Message.find(params[:message_id])
    msg = "#{message.name} #{message.uuid}"
    link = "#{public_view_messages_path(message.shop.name.parameterize, msg.parameterize)}"
    begin
      options = { 
          :message     => message.name,
          :description => "Description here",
          :link        => "#{link}", 
        }
      @graph.put_connections("me", "links", options)
    rescue Exception=>ex
      puts ex.message
    end
    
    respond_to do |format|
     format.html {  redirect_to "https://facebook.com" }       
    end
  end
end