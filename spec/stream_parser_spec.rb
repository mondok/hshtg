require 'net/http'
require 'uri'

RSpec.describe Hshtg::Stream::StreamParser, '#stream_parser', focus: true do
  context 'request builder' do
    it 'can create a signed request' do
      builder       = Hshtg::Http::RequestBuilder.new
      http, request = builder.build_request
      auth_header   = request.get_fields('Authorization').first
      expect(auth_header).to include('OAuth')
      http.finish
    end

    it 'can skip a signed request' do
      builder       = Hshtg::Http::RequestBuilder.new({ sign_request: false })
      http, request = builder.build_request
      expect(request.get_fields('Authorization')).to be_nil
      http.finish
    end
  end

  context 'hashtags' do
    it 'can determine if older than 60 seconds' do
      tag           = build_hashtag('test')
      tag.timestamp = Time.now - 120
      expect(tag.fresh?).to be_falsey
    end

    it 'can determine if newer than 60 seconds' do
      tag           = build_hashtag('test')
      tag.timestamp = Time.now - 55
      expect(tag.fresh?).to be_truthy
    end

    it 'can contain hash tags' do
      handler        = Hshtg::Stream::StreamParser.new(Hshtg::Storage::InMemoryStore.new)
      tag1           = build_hashtag('test')
      tag1.timestamp = Time.now - 120
      handler.hash_store.add_tags(tag1, build_hashtag('test2'))
      expect(handler.hash_store.count).to eq(2)
    end

    it 'can evict old hash tags' do
      handler        = Hshtg::Stream::StreamParser.new(Hshtg::Storage::InMemoryStore.new)
      tag1           = build_hashtag('test')
      tag1.timestamp = Time.now - 120
      handler.hash_store.add_tags(tag1, build_hashtag('test2'))
      handler.send(:evict_old_tags)
      expect(handler.hash_store.count).to eq(1)
      expect(handler.hash_store.fresh_tags[0].tag).to eq('test2')
    end
  end
end
