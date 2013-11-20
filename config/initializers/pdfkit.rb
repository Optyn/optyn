PDFKit.configure do |config|
  config.wkhtmltopdf = '/home/deploy/pdf'
  config.default_options = {
    :page_size => 'Legal',
    :print_media_type => true
  }
  # Use only if your external hostname is unavailable on the server.
  # config.root_url = "http://localhost" 
end#end fo PDFKIT