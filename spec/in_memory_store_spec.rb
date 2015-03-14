RSpec.describe Hshtg::Storage, '#memory_store', focus: true do
  context 'InMemoryStore' do
    it 'can be initialized' do
      store = Hshtg::Storage::InMemoryStore.new
      expect(store).to_not be_nil
    end



  end


end
