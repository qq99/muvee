require 'test_helper'

class VideosControllerTest < ActionController::TestCase
  setup do
    @video = videos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:videos)
  end

  test "should show video" do
    get :show, id: @video
    assert_response :success
  end

  test "should destroy video" do
    assert_difference('Video.count', -1) do
      delete :destroy, id: @video
    end

    assert_redirected_to videos_path
  end

  test "POST to #left_off_at keeps track of the most recent time in seconds" do
    post :left_off_at, id: @video, left_off_at: 20, format: :json

    assert_equal 20, @video.reload.left_off_at
  end
end
