class ReanalyzerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :analyze, throttle: { threshold: 40, period: 12.seconds }

  def perform(klass_name, id)
    klass = klass_name.constantize
    object = klass.find(id)
    object.send(:reanalyze)
  # rescue ActiveRecord::RecordInvalid => invalid
  #   Rails.logger.info "ReanalyzerWorker:invalid_record: #{invalid} #{klass_name}##{id}"
  # rescue ActiveRecord::RecordNotFound => not_found
  #   Rails.logger.info "ReanalyzerWorker:not_found: #{not_found} #{klass_name}##{id}"
  end
end
