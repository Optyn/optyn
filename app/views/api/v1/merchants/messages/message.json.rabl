object @message => :data
extends('api/v1/merchants/messages/detail', :locals => { :message_instance => @message })