RSpec.describe Hshtg::StreamController, '#stream_controller', focus: true do
  context 'initialize' do
    it 'can be initialized' do
      controller = Hshtg::StreamController.instance
      expect(controller).to_not be_nil
    end

    it 'can get tags' do
      text       = '#one #one #two # three #One'
      controller = Hshtg::StreamController.instance
      parser     = Hshtg::StreamParser.new(Hshtg::Storage::InMemoryStore.new)
      tags       = Hshtg::HashtagExtractor.hash_tags_from_tweet(text)
      parser.send(:add_tags, tags)
      controller.stream_parser = parser
      top_tags                 = controller.top_n(2)
      expect(top_tags.count).to eq(2)
      expect(top_tags[0].tag.downcase).to eq('one')
    end
  end
end
