window.Optyn =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: -> 
    new Optyn.Routers.PreLaunchRegistrations
    Backbone.history.start()

$(document).ready ->
  Optyn.initialize()
