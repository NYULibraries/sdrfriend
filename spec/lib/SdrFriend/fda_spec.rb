RSpec.describe SdrFriend::Fda do


  it "can detect handle in filepath of form '/sample/path/nyu_2451_21231.zip' " do
    client = SdrFriend::Fda.new(false)
    expect(client.send :filepath_to_handle, "/sample/path/nyu_2451_21231.zip").to eq("nyu_2451_21231")
  end

  it "can detect handle in filepath of form '/sample/path/nyu_2451_21231_original.zip' " do
    client = SdrFriend::Fda.new(false)
    expect(client.send :filepath_to_handle, "/sample/path/nyu_2451_21231_original.zip").to eq("nyu_2451_21231")
  end

  it "doesn't try to grab a handle from a filepath if one does not exist" do
    client = SdrFriend::Fda.new(false)
    expect { client.send :filepath_to_handle, "/sample/path/documentation.zip"}.to raise_error(RuntimeError)
  end

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
