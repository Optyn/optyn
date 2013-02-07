class Optyn.Views.Thankyou extends Backbone.View
  template: JST['pre_launch_registrations/thankyou']

  render: ->
    $(@el).html(@template())
    this
