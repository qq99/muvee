module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def silence_action
      Rails.logger.silence do
        yield
      end
    end
  end
end
