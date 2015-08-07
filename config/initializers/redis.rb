if is_server_or_sidekiq_context?
  $redis = Redis.new

  Thread.new {
    puts '=> initializers/redis: Subscribing to events emitted by sidekiq'
    $redis.subscribe "sidekiq" do |on|

      on.message do |channel, message|

        message = begin
          JSON.parse(message)
        rescue
          message
        end

        #Rails.logger.debug "Redis says: #{message}"
        EventBus.announce(:sidekiq, data: message)
      end

    end
  }
end
