class Optyn.Routers.PreLaunchRegistrations extends Backbone.Router
  routes:
    '': 'index'
  
  index: ->
    view = new Optyn.Views.PreLaunchRegistrationsIndex()
    $('#container').html(view.render().el)
    	