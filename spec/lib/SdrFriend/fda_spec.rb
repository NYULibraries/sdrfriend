RSpec.describe SdrFriend::Fda do


  describe "#load_table" do
    it "can load a CSV lookup table from link specified in secrets.yml" do
      client = SdrFriend::Fda.new(false)
      expect{client.load_table}.not_to raise_error
    end
  end

  describe "#filepath_to_handle" do
    it "can detect handle in filepath of form '/sample/path/nyu_2451_21231.zip' " do
      expect(SdrFriend::Fda.filepath_to_handle("/sample/path/nyu_2451_21231.zip")).to eq("nyu_2451_21231")
    end

    it "can detect handle in filepath of form '/sample/path/nyu_2451_21231_original.zip' " do
      expect(SdrFriend::Fda.filepath_to_handle("/sample/path/nyu_2451_21231_original.zip")).to eq("nyu_2451_21231")
    end

    it "doesn't try to grab a handle from a filepath if one does not exist" do
      expect {SdrFriend::Fda.filepath_to_handle("/sample/path/documentation.zip")}.to raise_error(RuntimeError)
    end
  end

  describe "#folder_fits_upload_format" do
    it "detects folders fitting the pattern of `nyu_1234_56789`" do
      expect(SdrFriend::Fda.folder_fits_upload_format("nyu_2451_56789")).to eq(true)
    end
    it "detects folders fitting the pattern of `nyu_1234_56789_doc`" do
      expect(SdrFriend::Fda.folder_fits_upload_format("nyu_2451_56789_doc")).to eq(true)
    end
    it "detects folders fitting the pattern of `nyu_1234_56789_anything`" do
      expect(SdrFriend::Fda.folder_fits_upload_format("nyu_1234_56789_anything")).to eq(true)
    end
    it "rejects folders fitting the pattern of `nyu_1234_56789_`" do
      expect(SdrFriend::Fda.folder_fits_upload_format("nyu_2451_56789_")).to eq(false)
    end
    it "rejects folders fitting the pattern of `nyu-1234-56789`" do
      expect(SdrFriend::Fda.folder_fits_upload_format("nyu-1234-56789")).to eq(false)
    end
    it "rejects files fitting the pattern of `nyu_1234_56789.zip`" do
      expect(SdrFriend::Fda.folder_fits_upload_format("nyu_2451_56789.zip")).to eq(false)
    end
  end

  describe "#standardize_handle_url" do
    it "converts 1234/56789 format handle into a valid handle URL" do
      client = SdrFriend::Fda.new(false)
      expect(client.standardize_handle_url("1234/56789")).to eq("http://hdl.handle.net/1234/56789")
    end

    it "converts nyu-1234-56789 format handle into a valid handle URL" do
      client = SdrFriend::Fda.new(false)
      expect(client.standardize_handle_url("nyu-1234-56789")).to eq("http://hdl.handle.net/1234/56789")
    end

    it "converts nyu_1234_56789 format handle into a valid handle URL" do
      client = SdrFriend::Fda.new(false)
      expect(client.standardize_handle_url("nyu_1234_56789")).to eq("http://hdl.handle.net/1234/56789")
    end

    it "doesn't alter an input that is already a handle url" do
      client = SdrFriend::Fda.new(false)
      expect(client.standardize_handle_url("http://hdl.handle.net/1234/56789")).to eq("http://hdl.handle.net/1234/56789")
    end

    it "rejects handles of other formats" do
      client = SdrFriend::Fda.new(false)
      expect {client.standardize_handle_url("clearly-wrong-input!")}.to raise_error(RuntimeError)
    end

  end

  describe "#is_upload_candidate?" do
    it "approves filepaths of format '/whatever/nyu_2451_12345.zip'" do
      expect(SdrFriend::Fda.is_upload_candidate?("/my/nyu_2451_12345.zip")).to eq(true)
    end
    it "approves filepaths of format '/whatever/nyu_2451_12345_doc.zip'" do
      expect(SdrFriend::Fda.is_upload_candidate?("/whatever/nyu_2451_12345_doc.zip")).to eq(true)
    end
    it "approves filepaths of format '/whatever/nyu_2451_12345_anything.zip'" do
      expect(SdrFriend::Fda.is_upload_candidate?("/whatever/nyu_2451_12345_anything.zip")).to eq(true)
    end
    it "rejects filepaths of format '/whatever/nyu_2451_12345_doc'" do
      expect(SdrFriend::Fda.is_upload_candidate?("/whatever/nyu_2451_12345_doc")).to eq(false)
    end
    it "rejects filepaths of format '/whatever/nyu_2451_12345_doc.'" do
      expect(SdrFriend::Fda.is_upload_candidate?("/whatever/nyu_2451_12345_doc.")).to eq(false)
    end
    it "rejects filepaths of format '/whatever/clearly_wrong.zip'" do
      expect(SdrFriend::Fda.is_upload_candidate?("/whatever/clearly_wrong.zip")).to eq(false)
    end
    it "rejects filepaths of format '/whatever/nyu_1234_567890.zip'" do
      expect(SdrFriend::Fda.is_upload_candidate?("/whatever/nyu_1234_567890.zip")).to eq(false)
    end
  end

  describe "#is_handle?" do
    it "detects handles of format nyu-1234-56789" do
      client = SdrFriend::Fda.new(false)
      expect(client.is_handle?("nyu-1234-56789")).to eq(true)
    end

    it "detects handles of format nyu_1234_56789" do
      client = SdrFriend::Fda.new(false)
      expect(client.is_handle?("nyu_1234_56789")).to eq(true)
    end

    it "detects handles of format http://hdl.handle.net/1234/56789" do
      client = SdrFriend::Fda.new(false)
      expect(client.is_handle?("http://hdl.handle.net/1234/56789")).to eq(true)
    end

    it "rejects handles of other formats" do
      client = SdrFriend::Fda.new(false)
      expect(client.is_handle?("fake-handle")).to eq(false)
    end
  end


end
