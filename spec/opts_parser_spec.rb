require 'optparse'

RSpec.describe Hshtg::OptsParser, '#opts_parser', focus: true do
  context 'Options' do
    it 'can enable case sensitivity' do
      options = Hshtg::OptsParser.options(['-c', '1'])
      expect(options[:case]).to be_truthy
    end
    it 'can disable case sensitivity' do
      options = Hshtg::OptsParser.options(['--case', '0'])
      expect(options[:case]).to be_falsey
    end
    it 'can change the default ttl' do
      options = Hshtg::OptsParser.options(['-t', '1'])
      expect(options[:ttl]).to eq(1)
    end
    it 'can change the default ttl longform' do
      options = Hshtg::OptsParser.options(['--ttl', '1'])
      expect(options[:ttl]).to eq(1)
    end

    it 'can change the default port' do
      options = Hshtg::OptsParser.options(['-p', '1'])
      expect(options[:port]).to eq(1)
    end
    it 'can change the default port longform' do
      options = Hshtg::OptsParser.options(['--port', '1'])
      expect(options[:port]).to eq(1)
    end

    it 'can change the storage to in-memory' do
      options = Hshtg::OptsParser.options(['--store', 'in-memory'])
      expect(options[:storage]).to eq(Hshtg::Storage::InMemoryStore)
    end

  end

end
