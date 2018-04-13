RSpec.describe SdrFriend::Metadata do

  let(:record_collection) { JSON.parse(File.read("spec/fixtures/metadata/sample-collection.json")) }

  describe '#record_to_row' do
    it "is capable of creating a CSV row hash from a JSON record" do
      expect(SdrFriend::Metadata.record_to_row(record_collection[0])).to be_a(Hash)
    end
    it "creates a hash with 30 entries" do
      expect(SdrFriend::Metadata.record_to_row(record_collection[0]).count).to eq(30)
    end
  end

  describe '#collection_to_csv' do
    it "creates a CSV table" do
      expect(SdrFriend::Metadata.collection_to_csv(record_collection)).to be_a(CSV::Table)
    end
  end

  describe 'CSV / JSON conversion' do
    it 'converts losslessly from JSON -> CSV -> JSON' do
      csv = SdrFriend::Metadata.collection_to_csv(record_collection)
      collection = SdrFriend::Metadata.csv_to_collection(csv)
      expect(collection).to eq(record_collection)
    end
  end


end