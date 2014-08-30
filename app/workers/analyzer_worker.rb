class AnalyzerWorker
  include Sidekiq::Worker

  def perform
    TvShow.all.each do |tv_show|
      if File.exist? tv_show.raw_file_path
        tv_show.reanalyze
      else
        tv_show.destroy
      end
    end
  end
end
