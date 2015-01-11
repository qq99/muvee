require 'test_helper'
require 'sidekiq/testing'

class TranscoderWorkerTest < ActiveSupport::TestCase
  def setup
    Sidekiq::Worker.clear_all
    @bigBuck = Rails.root.join("test/fixtures/BigBuckBunny_320x180.mp4")
    @bigBuckWebm = Rails.root.join("tmp/BigBuckBunny_320x180.webm")
  end

  test "queues jobs" do
    assert_equal 0, TranscoderWorker.jobs.size
    TranscoderWorker.perform_async(Video, @bigBuck, @bigBuckWebm)
    assert_equal 1, TranscoderWorker.jobs.size
  end

  test "perform work will transcode then attempt to create a Video record" do
    worker = TranscoderWorker.new
    assert_difference "Video.all.length", 1 do
      worker.perform(Video, @bigBuck, @bigBuckWebm)
    end
  end
end
