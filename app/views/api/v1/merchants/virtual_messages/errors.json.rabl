object @virtual_message => :data

node :errors do |virtual_message|
    @errors rescue nil
end