require 'test_helper'

class VideoCreationServiceTest < ActiveSupport::TestCase

  def setup
    @bigBuck = Dir.getwd() + "/test/fixtures/BigBuckBunny_320x180.mp4"
    Video.any_instance.stubs(thumbnail_root_path: "/test/scratch/")

    ApplicationConfiguration.destroy_all
    ApplicationConfiguration.create(
      transcode_media: false,
      torrent_start_path: Dir.getwd() + "/tmp/torrents"
    )

    @fakeSuccess = stub({
      response: Net::HTTPSuccess,
      value: stub({
        response: stub(kind_of?: true),
        body: "test"
      })
    })
    ExternalMetadata.stubs(endpoint_url: "http://example.com")
    Net::HTTP.stubs(:get_response).returns(@fakeSuccess)
  end

  def teardown
    %x{rm #{Dir.getwd() + '/test/scratch/'}*.jpg}

    ApplicationConfiguration.destroy_all
  end

  test "the service will create sources for TvShows" do
    service = VideoCreationService.new({
      tv: [Dir.getwd() + '/test/fixtures/']
    })

    assert_difference 'Source.count', +1 do
      assert_difference 'TvShow.count', +1 do
        @results = service.generate()
      end
    end
  end

  test "service will append trailing slashes to any folder supplied to it without trailing slash" do
    service = VideoCreationService.new({
      tv: [Dir.getwd() + '/test/fixtures']
    })

    TvShow.any_instance.expects(:associate_with_series)

    assert_difference 'TvShow.all.length', 1 do
      @results = service.generate()
    end
  end
end
