require 'validateable'

describe 'Validateable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Cat < SQLObject
      validates :name, presence: true, length: 0

      finalize!
    end
  end

  describe "#validates" do
    it 'declares empty attributes invalid' do
      sennacy = Cat.new

      expect(sennacy.valid?).to be false
    end
  end
end
