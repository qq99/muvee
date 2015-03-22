require 'test_helper'

class TvShowTest < ActiveSupport::TestCase
  def setup
    Series.any_instance.stubs(download_images: true)
  end

  test 'can create' do
    TvShow.any_instance.stubs(:associate_with_series)
    TvShow.any_instance.stubs(:extract_metadata)
    show = TvShow.create(raw_file_path: "/foo/bar")
    assert_equal "TvShow", show.type
  end

  test 'validates that another episode with the same season&episode does not already exist on create' do
    existing = videos(:american_dad_s01_e01)
    new_show = TvShow.new(season: existing.season, episode: existing.episode, series_id: existing.series.id)

    refute new_show.valid?
    assert new_show.errors[:unique_episode_in_season].present?
  end

  test 'can set a show to the same season&episode as an existing show' do
    existing = videos(:american_dad_s01_e01)
    existing2 = videos(:american_dad_s01_e02)
    existing2.season = existing.season
    existing2.episode = existing.episode

    assert existing2.valid?
    assert existing2.errors[:unique_episode_in_season].blank?
  end

  test 'will create a new series if one does not exist' do
    VCR.use_cassette 'family_guy' do
      assert_difference 'Series.all.length', 1 do
        TvShow.create(raw_file_path: '/foo/bar/Family.Guy.S11E21.HDTV.x264-LOL.mp4', status: 'local')
      end
    end
  end

  test 'will not create duplicate new series' do
    VCR.use_cassette 'family_guy' do
      assert_difference 'Series.all.length', 1 do
        TvShow.create(raw_file_path: '/foo/bar/Family.Guy.S11E21.HDTV.x264-LOL.mp4', status: 'local')
        TvShow.create(raw_file_path: '/foo/bar/Family.Guy.S11E22.HDTV.x264-LOL.mp4', status: 'local')
        TvShow.create(raw_file_path: '/foo/bar/Family.Guy.S11E23.HDTV.x264-LOL.mp4', status: 'local')
      end
    end
  end

  test 'reanalyze can re-guess and reassociate metadata, given bad initial metadata' do
    TvShow.any_instance.stubs(:metadata).returns({
      SeriesName: 'American Dad!'
    })
    TvShow.any_instance.stubs(:episode_specific_metadata).returns({
      EpisodeName: "Foo bar",
      EpisodeNumber: 22,
      SeasonNumber: 11
    })

    show = videos(:poorly_analyzed_american_dad)
    show.reanalyze
    show.reload
    assert_equal "Foo bar", show.episode_name
    assert_equal "American Dad!", show.title
    assert_equal 11, show.season
    assert_equal 22, show.episode
  end

  test 'reanalyze does not save the model or reassociate metadata/series if nothing changed' do
    show = videos(:american_dad_s01_e01)
    show.reanalyze
    show.expects(:save).never
    show.expects(:associate_with_series).never
    show.expects(:extract_metadata).never
  end

  test 'can get to episodic metadata' do
    VCR.use_cassette 'american_dad' do
      show = TvShow.create(title: 'American Dad', season: 5, episode: 10)
      assert_equal "Family Affair", show.episode_specific_metadata[:EpisodeName]
      assert_equal "When the Smiths try to plan a family game night, Roger is full of excuses about prior commitments. However, when he is caught in a lie, the Smiths feel stabbed in the back when they realize Roger has been cheating on them with other families. Stan, Francine, Hayley and Steve go on the offensive to teach Roger a lesson about monogamy until Roger has a breakthrough about why he isn't a one family kind-of-guy.", show.episode_specific_metadata[:Overview]
    end
  end
end
