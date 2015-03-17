class StatusController < ApplicationController
  include Tubesock::Hijack

  def index
    @torrents = Torrent.all
  end

  def info
    hijack do |tubesock|

      tubesock.onopen do
        #tubesock.send_data "Hello"
      end

      tubesock.onmessage do |data|
        begin
          data = JSON.parse(data).with_indifferent_access
          if data[:name] == 'torrent_info'
            silence_action do
              payload = Torrent.all.map(&:summary)
              tubesock.send_data({type: 'TorrentInformation', results: payload}.to_json)
            end
          else
            tubesock.send_data 'Unrecognized'
          end
        rescue JSON::ParserError => e
          puts 'Was not sent JSON'
        end
      end

      EventBus.subscribe(:sidekiq) do |payload|
        data = payload[:data]
        tubesock.send_data data.to_json
      end
    end
  end
end
