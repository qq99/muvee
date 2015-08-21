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
    Hash.stubs(:from_xml).returns({foo: 'bar'})
    ExternalMetadata.any_instance.stubs(result_format: :xml)
  end

  test "the first query_remote to a new endpoint should result in an HTTP get" do
    ExternalMetadata.stubs(endpoint_url: "http://example.com")
    ExternalMetadata.any_instance.stubs(:query_remote).returns(@fakeSuccess)
    meta = ExternalMetadata.get("test")
    assert_equal "http://example.com", meta.endpoint
  end

  test "if should_query_remote? is false, the 2nd query does not attempt an HTTP get" do
    ExternalMetadata.stubs(endpoint_url: "http://example.com")
    ExternalMetadata.any_instance.expects(:query_remote).once.returns(@fakeSuccess)
    meta = ExternalMetadata.get("test")
    ExternalMetadata.any_instance.expects(:should_query_remote?).returns(false)
    meta2 = ExternalMetadata.get("test")
  end

  test "if should_query_remote? is true, the 2nd query does not attempt an HTTP get" do
    ExternalMetadata.stubs(endpoint_url: "http://example.com")
    ExternalMetadata.any_instance.expects(:query_remote).twice.returns(@fakeSuccess)
    meta = ExternalMetadata.get("test")
    ExternalMetadata.any_instance.expects(:should_query_remote?).returns(true)
    meta2 = ExternalMetadata.get("test")
  end

  test "a day from now, trying to do the same GET will actually perform it instead of using the cached value" do
    ExternalMetadata.stubs(endpoint_url: "http://example.com")
    ExternalMetadata.any_instance.expects(:query_remote).twice.returns(@fakeSuccess)
    ExternalMetadata.get("test")
    Timecop.freeze(Time.now + 1.day) do
      meta = ExternalMetadata.get("test")
    end
  end
end
