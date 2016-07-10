#= require action_cable

Muvee.cable = ActionCable.createConsumer "ws://#{location.host}/cable"
