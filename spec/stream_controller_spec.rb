RSpec.describe Hshtg::Stream::StreamController, '#stream_controller', focus: true do
  context 'initialize' do
    it 'can be initialized' do
      controller = Hshtg::Stream::StreamController.instance
      expect(controller).to_not be_nil
    end

    it 'can get tags' do
      text       = '#one #one #two # three #One'
      controller = Hshtg::Stream::StreamController.instance
      parser     = Hshtg::Stream::StreamParser.new(Hshtg::Storage::InMemoryStore.new)
      tags       = Hshtg::Stream::HashtagExtractor.hash_tags_from_tweet(text)
      parser.send(:add_tags, tags)
      controller.stream_parser = parser
      top_tags                 = controller.top_n(2)
      expect(top_tags.count).to eq(2)
      expect(top_tags[0].tag.downcase).to eq('one')
    end
  end
end
