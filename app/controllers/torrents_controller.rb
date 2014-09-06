class TorrentsController < ApplicationController
  before_action :set_torrent, only: [:status]

  def status
    render json: {
      percentage: @torrent.percentage.round(2)
    }
  end

  def set_torrent
    @torrent = Torrent.find(params[:id])
  end
end
