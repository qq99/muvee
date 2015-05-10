require 'test_helper'

class VideoCreationServiceTest < ActiveSupport::TestCase

  def setup
    @bigBuck = Dir.getwd() + "/test/fixtures/BigBuckBunny_320x180.mp4"
    Video.any_instance.stubs(thumbnail_root_path: Dir.getwd() + "/test/scratch/")

    ApplicationConfiguration.destroy_all
    ApplicationConfiguration.create(
      transcode_media: false,
      torrent_start_path: Dir.getwd() + "/tmp/torrents"
    )

    @sample_service = VideoCreationService.new(tv: [], movies: [])

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
    %x{rm #{Dir.getwd() + '/test/scratch/'}*.jpg &> /dev/null}

    ApplicationConfiguration.destroy_all
  end

  test "#generate calls create_sources on Tv and Movie folders" do
    tv_folders = ['/tv/foo', '/tv/bar']
    movie_folders = ['/movies/foo', '/movies/bar']

    @service = VideoCreationService.new(
      tv: tv_folders,
      movies: movie_folders
    )

    @service.expects(:create_videos).with(TvShow, tv_folders)
    @service.expects(:create_videos).with(Movie, movie_folders)

    @service.generate
  end

  test "#create_videos ignores non-video containers, ignores .sample.videos, creates sources for eligible files, and queues transcode for ineligble files" do
    @sample_service.expects(:get_files_in_folders).returns([
      '/foo/bar.avi',
      '/foo/bar.sample.avi',
      '/foo/bar.sample.jpg',
      '/foo/bar.mp4',
      '/foo/bar.SAMPLE.mp4',
      '/foo/baz.webm'
    ])

    Video.expects(:needs_transcoding?).with("/foo/bar.avi").once.returns(true)
    Video.expects(:needs_transcoding?).with("/foo/bar.sample.jpg").never
    Video.expects(:needs_transcoding?).with("/foo/bar.sample.avi").never
    Video.expects(:needs_transcoding?).with("/foo/bar.SAMPLE.mp4").never
    Video.expects(:needs_transcoding?).with("/foo/bar.mp4").once.returns(false)
    Video.expects(:needs_transcoding?).with("/foo/baz.webm").once.returns(false)

    @sample_service.expects(:create_eligible_sources).with(Movie, ['/foo/bar.mp4', '/foo/baz.webm'])
    @sample_service.expects(:transcode_ineligible_sources).with(Movie, ['/foo/bar.avi'])

    @sample_service.create_videos(Movie, nil)
  end

  test "#create_videos when there are no eligible sources" do
    @sample_service.expects(:get_files_in_folders).returns([
      '/foo/bar.sample.jpg',
    ])

    @sample_service.expects(:create_eligible_sources).with(Movie, [])
    @sample_service.expects(:transcode_ineligible_sources).with(Movie, [])

    @sample_service.create_videos(Movie, nil)
  end

end
