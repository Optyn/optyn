class Optyn.Views.PreLaunchRegistrationsIndex extends Backbone.View
  template: JST['pre_launch_registrations/index']

  events:
    'submit #new_pre_launch_registration': 'createRegistration'	

  initialize: ->
    @collection = new Optyn.Collections.PreLaunchRegistrations()
    @collection.on('add', @welcomeRegistration, this)

  render: ->
	  $(@el).html(@template(collection: @collection))
	  this  
  
  createRegistration: (event) ->
  	event.preventDefault()
  	@collection.create(email: $('#pre_launch_registration_email').val(), 
      wait: true
      error: @handleError)

  welcomeRegistration: ->
    view = new Optyn.Views.Thankyou()
    $('#container').html(view.render().el)

  handleError: (entry, response) ->
    if response.status == 422
      errors  = $.parseJSON(response.responseText).errors
      for attribute, messages of errors
        alert "#{attribute} #{message}" for message in messages    
