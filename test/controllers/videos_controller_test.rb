require 'test_helper'

class VideosControllerTest < ActionController::TestCase
  setup do
    Video.any_instance.stubs(thumbnail_root_path: "/test/scratch/")
    ApplicationConfiguration.stubs(count: 1)
    @video = videos(:american_dad_s01_e01)
  end

  test "#show_source when TvShow will update the series.last_watched_video_id" do
    get :show_source, id: @video
    assert_equal @video.id, @video.reload.series.last_watched_video_id
  end

  test "#show_source with shuffle param will set next episode to another member of the same series" do
    get :show_source, id: @video, shuffle: true, series_id: @video.series.id
    assert_response :success
    assert_not_nil assigns(:next_episode)
    assert_equal @video.series, assigns(:next_episode).series
  end

  test "#show_source accepts a source_id param" do
    s1e1 = videos(:american_dad_s01_e01)
    assert s1e1.sources.size > 1

    get :show_source, id: s1e1, source_id: s1e1.sources.last
    assert_response :success
    assert_equal s1e1.sources.last, assigns(:source)

    get :show_source, id: s1e1, source_id: s1e1.sources.first
    assert_response :success
    assert_equal s1e1.sources.first, assigns(:source)
  end

  test "#show_source when series video has a next episode, but no previous episode" do
    s1e1 = videos(:american_dad_s01_e01)
    get :show_source, id: s1e1
    assert_response :success
    assert_not_nil assigns(:next_episode)
    assert_nil assigns(:previous_episode)
  end

  test "#show_source when series video has a next&prev episode" do
    s1e2 = videos(:american_dad_s01_e02)
    get :show_source, id: s1e2
    assert_response :success
    assert_not_nil assigns(:next_episode)
    assert_not_nil assigns(:previous_episode)
  end

  test "#show_source when series video has a prev episode, but no next episode" do
    s1e3 = videos(:american_dad_s01_e03)
    get :show_source, id: s1e3
    assert_response :success
    assert_nil assigns(:next_episode)
    assert_not_nil assigns(:previous_episode)
  end

  test "POST to #left_off_at keeps track of the most recent time in seconds" do
    post :left_off_at, id: @video, left_off_at: 20, format: :json

    assert_equal 20, @video.reload.left_off_at
  end

  test "GET to #thumbnails creates thumbs if they do not exist" do
    Video.any_instance.expects(:create_n_thumbnails).with(10)
    get :thumbnails, id: @video
  end

  test "GET to #thumbnails does not create thumbs if they exist" do
    Video.any_instance.expects(:create_n_thumbnails).never
    Video.any_instance.expects(:has_set_of_thumbnails?).returns(true)
    get :thumbnails, id: @video
  end

  test "POST to #reanalyze_video will reanalyze the video" do
    Video.any_instance.expects(:reanalyze).once
    post :reanalyze_video, id: @video
    assert_response :ok
  end
end
