require 'test_helper'

class VideoCreationServiceTest < ActiveSupport::TestCase

  def setup
    @bigBuck = Dir.getwd() + "/test/fixtures/BigBuckBunny_320x180.mp4"
    Video.any_instance.stubs(thumbnail_root_path: "/test/scratch/")

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
  end

  test "the service will create models for everything passed into its constructor, and try to associate each with a series" do
    service = VideoCreationService.new({
      tv: [Dir.getwd() + '/test/fixtures/']
    })

    TvShow.any_instance.expects(:associate_with_series)

    results = nil
    assert_difference 'TvShow.all.length', 1 do
      assert_difference 'Thumbnail.all.length', 1 do
        results = service.generate()
      end
    end

    assert_equal 4, results.length
    assert_equal 1, results[0].length
    assert_equal 0, results[1].length
    assert_equal 0, results[2].length
    assert_equal 0, results[3].length
    assert_equal "Big Buck Bunny 320x180", results[0][0].title
  end

  test "service will append trailing slashes to any folder supplied to it without trailing slash" do
    service = VideoCreationService.new({
      tv: [Dir.getwd() + '/test/fixtures']
    })

    TvShow.any_instance.expects(:associate_with_series)

    results = nil
    assert_difference 'TvShow.all.length', 1 do
      results = service.generate()
    end
  end
end
