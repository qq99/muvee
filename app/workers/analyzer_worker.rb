class AnalyzerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :analyze, retry: false

  def perform(opts)
    klasses = [TvShow, Movie]
    opts = Hash.try_convert(opts)
    opts = opts.with_indifferent_access

    klasses.each do |klass|
      klass.local.all.each do |model_instance|
        begin
          model_instance.send(opts[:method].to_sym)
        rescue ActiveRecord::RecordInvalid => invalid
          Rails.logger.info "AnalyzerWorker:#{opts[:method]}:invalid_record: #{invalid}"
        rescue ActiveRecord::RecordNotFound => not_found
          Rails.logger.info "AnalyzerWorker:#{opts[:method]}:not_found: #{not_found}"
        end
      end
    end
  end
end
