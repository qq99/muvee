class MediaScannerWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  sidekiq_options :queue => :scan

  def clean_missing
    klasses = [TvShow, Movie]
    klasses.each do |klass|
      klass.all.each do |model_instance|
        if (model_instance.raw_file_path.present? && !File.exist?(model_instance.raw_file_path)) ||
          (model_instance.local? && (model_instance.raw_file_path.blank? || !File.exist?(model_instance.raw_file_path)))
          model_instance.destroy
        end
      end
    end
  end

  def perform

    clean_missing

    config = ApplicationConfiguration.first
    return if config.blank?
    service = VideoCreationService.new({
      tv: config.tv_sources,
      movies: config.movie_sources
    })

    service.generate()
  end
end
