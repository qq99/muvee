require 'test_helper'

class ExternalMetadataTest < ActiveSupport::TestCase

  def setup
    @fakeSuccess = stub({
      response: Net::HTTPSuccess,
      value: stub({
        response: stub(kind_of?: true),
        body: "test"
      })
    })
  end

  test "the first fetch to a new endpoint should result in an HTTP get" do
    ExternalMetadata.stubs(endpoint_url: "http://example.com")
    Net::HTTP.expects(:get_response).returns(@fakeSuccess)
    meta = ExternalMetadata.get("test")
    assert_equal "test", meta.raw_value
    assert_equal "http://example.com", meta.endpoint
  end

  test "the second fetch to the endpoint returns the cached result" do
    ExternalMetadata.stubs(endpoint_url: "http://example.com")
    Net::HTTP.expects(:get_response).once.returns(@fakeSuccess)
    meta = ExternalMetadata.get("test")
    meta2 = ExternalMetadata.get("test")
  end

  test "a day from now, trying to do the same GET will actually perform it instead of using the cached value" do
    ExternalMetadata.stubs(endpoint_url: "http://example.com")
    Net::HTTP.expects(:get_response).twice.returns(@fakeSuccess)
    ExternalMetadata.get("test")
    Timecop.freeze(Time.now + 1.day) do
      meta = ExternalMetadata.get("test")
    end
  end
end
