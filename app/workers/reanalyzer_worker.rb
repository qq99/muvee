class ReanalyzerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :analyze

  def perform(klass_name, id)
    klass = klass_name.constantize
    object = klass.find(id)
    object.send(:reanalyze)
  rescue Exceptions::TmdbError => e
    Sidekiq::Queue['analyze'].pause_for_ms(2000)
    raise e
  end
end
