class AnalyzerWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :analyze

  def perform(opts)
    klasses = [TvShow, Movie]
    opts = Hash.try_convert(opts)
    opts = opts.with_indifferent_access

    klasses.each do |klass|
      klass.all.each do |model_instance|
        if model_instance.local? && (!model_instance.raw_file_path || !File.exist?(model_instance.raw_file_path))
          model_instance.destroy
        else
          begin
            model_instance.send(opts[:method].to_sym)
          rescue ActiveRecord::RecordInvalid => invalid
            Rails.logger.info "AnalyzerWorker:#{opts[:method]}:invalid_record: #{invalid}"
          end
        end
      end
    end
  end
end
