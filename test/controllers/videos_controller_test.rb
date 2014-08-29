require 'test_helper'

class VideosControllerTest < ActionController::TestCase
  setup do
    Video.any_instance.stubs(thumbnail_root_path: "/test/scratch/")
    @video = videos(:american_dad_s01_e01)
  end

  teardown do
    %x{rm #{Dir.getwd() + '/test/scratch/'}*.jpg}
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:series)
    assert_not_nil assigns(:movies)
    assert_not_nil assigns(:items)
  end

  test "should show video" do
    get :show, id: @video
    assert_response :success
  end

  test "POST to #left_off_at keeps track of the most recent time in seconds" do
    post :left_off_at, id: @video, left_off_at: 20, format: :json

    assert_equal 20, @video.reload.left_off_at
  end

  test "GET to #thumbnails creates thumbs if they do not exist" do
    Video.any_instance.expects(:create_n_thumbnails).with(10)
    get :thumbnails, id: @video
  end

  test "GET to #thumbnails will return the 10 thumbnails if they already exist" do
    video = videos(:big_buck_bunny)
    video.raw_file_path = Dir.getwd() + "/test/fixtures/BigBuckBunny_320x180.mp4"
    video.save
    get :thumbnails, id: video

    assert_equal 10, video.reload.thumbnails.length
    assert_equal 10, JSON.parse(@response.body)["thumbnails"].length

    Video.any_instance.expects(:create_n_thumbnails).never
    get :thumbnails, id: video

    assert_equal 10, video.reload.thumbnails.length
    assert_equal 10, JSON.parse(@response.body)["thumbnails"].length
  end
end
