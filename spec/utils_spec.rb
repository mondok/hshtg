RSpec.describe Hshtg::Utils, '#utils', focus: true do
  context 'Utils' do
    it 'can strip prefixed text and return a positive integer' do
      val = Hshtg::Utils.suffix_number('/top', '/top10')
      expect(val).to be(10)
    end
    it 'can strip prefixed text and return nil if not an integer' do
      val = Hshtg::Utils.suffix_number('/top', '/top100i')
      expect(val).to be_nil
    end
    it 'can strip prefixed text and return nil if integer is 0' do
      val = Hshtg::Utils.suffix_number('/top', '/top0')
      expect(val).to be_nil
    end
    it 'can determine if a string is a positive number' do
      val = Hshtg::Utils.positive_integer('100')
      expect(val).to be_truthy
    end
    it 'can determine if a string is not a positive number' do
      val = Hshtg::Utils.positive_integer('x')
      expect(val).to be_falsey
    end
  end
end
