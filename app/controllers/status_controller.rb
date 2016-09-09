class StatusController < ApplicationController

  def index
    @torrents = Torrent.all
    render 'index'
  end

  def destroy_torrent
    torrent = Torrent.find(params[:id])
    torrent.destroy # TODO: this needs to actually destroy the files from transmission
    torrent.video.reset_status
    flash.now[:notice] = "Torrent destroyed"
    index
  end

  def scan_for_new_media
    if existing_jobs.include? "MediaScannerWorker"
      already_working
    else
      MediaScannerWorker.perform_async
      job_enqueued
    end
  end

  def reanalyze_media
    if existing_jobs.include? "AnalyzerWorker"
      already_working
    else
      AnalyzerWorker.perform_async({method: :reanalyze})
      job_enqueued
    end
  end

  private

  def job_enqueued
    flash.now[:notice] = "Job enqueued and processing in background"
    index
  end

  def already_working
    flash.now[:error] = "Please wait; this task is already running."
    index
  end

  def queues
    [
      Sidekiq::ScheduledSet.new.to_a,
      Sidekiq::RetrySet.new.to_a,
      Sidekiq::Queue.new("default").to_a,
      Sidekiq::Queue.new("analyze").to_a,
      Sidekiq::Queue.new("transcode").to_a,
      Sidekiq::Queue.new("scan").to_a
    ]
  end

  def existing_jobs
    jobs = queues
    jobs = jobs.inject([]) {|set, el| set.concat el}
    existing_jobs = jobs.map do |job|
      job.display_class
    end
  end
end
