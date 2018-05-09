module SdrFriend
  class Files

    def self.make_bitstream_folders(destination_path, folder_name_list)
      folder_name_list.each do |ls|
        path = destination_path + '/' + ls
        `mkdir -p #{path}`
      end
    end

  end
end