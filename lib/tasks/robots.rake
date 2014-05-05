namespace :robots do
  desc "Task to geenrate the robots.txt file"
  task :generate => :environment do
    bot_list = ["Googlebot", "baiduspider", "msnbot", "naverbot", "seznambot", "Slurp", "teoma", "Yandex", "CCBot", "Telefonica", "SandDollar", "dotbot", "rogerbot", "IntuitGSACrawler", "red-app-gsa-p-one"]

    file_title = "#Welcome to Optyn! Please contact us at support@optyn.com for any details.\n\n"

    robots = []
    #append the file title
    robots << file_title

    bot_list.each do |bot|
      #loop through the botlist and add for each
      robots << "User-agent: #{bot}"
      
      RobotConfig.allow.each do |line_item|
        robots << %{Allow: #{line_item}}
      end

      RobotConfig.disallow.each do |line_item|
        robots <<  %{Disallow: #{line_item}}        
      end

      robots << "\n\n"
    end


    filepath = "#{Rails.root}/public/robots-optyn.txt"
    File.open(filepath, 'w') do |file|
      file.puts(robots.join("\n"))
    end
  end #end of the generate task

  
end #end of the robots namespace