require 'test_helper'

class GenreTest < ActiveSupport::TestCase
  test "strips name on creation" do
    g = Genre.create(name: "  foo ")
    assert_equal "Foo", g.name
  end

  test "titleizes name on creation" do
    g = Genre.create(name: "foxy boxing")
    assert_equal "Foxy Boxing", g.name
  end

  test "remove hyphens" do
    g = Genre.create(name: "robo-heaven")
    assert_equal "Robo Heaven", g.name
  end

  test "converts variants of 'sci fi' to 'Science Fiction'" do
    g = Genre.create(name: "Sci Fi")
    assert_equal "Science Fiction", g.name
    g.destroy

    g = Genre.create(name: "sci-fi")
    assert_equal "Science Fiction", g.name
    g.destroy

    g = Genre.create(name: "scifi")
    assert_equal "Science Fiction", g.name
    g.destroy
  end
end
