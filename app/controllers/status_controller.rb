class StatusController < ApplicationController
  include Tubesock::Hijack

  def status
    hijack do |tubesock|

      tubesock.onopen do
        tubesock.send_data "Hello"
      end

      tubesock.onmessage do |data|
        tubesock.send_data "You said: #{data}"
      end

      EventBus.subscribe(:sidekiq) do |payload|
        data = payload[:data]
        tubesock.send_data data.to_json
      end
    end
  end
end
