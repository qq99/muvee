require 'test_helper'
require 'sidekiq/testing'

class TranscoderWorkerTest < ActiveSupport::TestCase
  def setup
    Sidekiq::Worker.clear_all
    @bigBuck = Rails.root.join("test/fixtures/BigBuckBunny_320x180.mp4")
  end

  test "queues jobs" do
    assert_equal 0, TranscoderWorker.jobs.size
    TranscoderWorker.perform_async("Movie", @bigBuck)
    assert_equal 1, TranscoderWorker.jobs.size
  end


end
