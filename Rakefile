require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "SdrFriend/fda"
require "SdrFriend/metadata"
require "find"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :fda do

  desc 'View all current metadata for an FDA item -- identifier can be handle or dspace id'
  task :get, :identifier do |t, args|
    client = SdrFriend::Fda.new
    puts JSON.generate(client.grab_item_metadata(args[:identifier]))
  end

  desc 'Add a single bitstream; <identifier> argument optional IF handle can be extracted from filename'
  task :addbit, :file_path, :identifier do |t, args|
    client = SdrFriend::Fda.new
    puts JSON.generate(client.upload_bitstream(args[:file_path], args[:identifier]))
  end

  desc 'For an FDA record, delete all bitstreams with a given name'
  task :delbit, :identifier, :filename do |t, args|
    client = SdrFriend::Fda.new
    puts client.delete_bitstream(args[:identifier], args[:filename])
  end

  desc 'Translate a handle into a dspace internal id'
  task :translate, :handle do |t, args|
    client = SdrFriend::Fda.new
    puts client.translate_handle_to_dspace_id(args[:handle])
  end

  desc 'Create a SINGLE container record / "mint" a new handle; collection should be "public" or "restricted"'
  task :mint, :collection do |t, args|
    client = SdrFriend::Fda.new
    collection = nil
    if !args[:collection].nil?
      if args[:collection].downcase == "public"
        collection = 651
      elsif args[:collection].downcase == "restricted"
        collection = 652
      else
        raise "Unable to detect a valid collection name"
      end
      puts JSON.generate(client.create_container(collection))
    else
      raise "Unable to detect a valid collection name"
    end
  end

  desc 'Create MULTIPLE container records / "mint" new handles; collection should be "public" or "restricted"'
  task :mint_many, :collection, :number do |t, args|
    client = SdrFriend::Fda.new
    collection = nil
    if !args[:collection].nil?
      if args[:collection].downcase == "public"
        collection = 651
      elsif args[:collection].downcase == "restricted"
        collection = 652
      else
        raise "Unable to detect a valid collection name"
      end
      created = []
      num = args[:number].to_i
      if num > 0
        num.times do |n|
          created << client.create_container(collection)
        end
      end
      lines = ["dspace-internal,handle"]
      created.each do |container|
        lines << "#{container['id']},#{container['handle']}"
      end
      puts lines.join("\n")
    else
      raise "Unable to detect a valid collection name"
    end
  end



end


namespace :metadata do

  desc "Generate CSV from set of JSON records"
  task :gencsv, :repository_path, :csv_output do |t, args|
    paths = Find.find(args[:repository_path]).select{ |x| x.include?("geoblacklight.json")}
    collection = []
    paths.each do |path|
      collection << JSON.parse(File.read(path))
    end

    if args[:csv_output].nil?
      ## Pipe out to stdout if no :csv_output present
      puts SdrFriend::Metadata.collection_to_csv(collection)
    else
      File.open(args[:csv_output], "w") do |f|
        f.write(SdrFriend::Metadata.collection_to_csv(collection))
      end
    end
  end

  desc "Add FDA bitstream URLs to JSON records"
  task :bithydrate, :repository_path do |t, args|
    paths = Find.find(args[:repository_path]).select{ |x| x.include?("geoblacklight.json")}
    collection = []
    paths.each do |path|
      collection << JSON.parse(File.read(path))
    end
    SdrFriend::Metadata.bitstream_hydrate(collection)
    puts JSON.pretty_generate(collection)
  end

  desc "Alphabetize keys in records"
  task :alphabetize, :repository_path do |t, args|
    paths = Find.find(args[:repository_path]).select{ |x| x.include?("geoblacklight.json")}
    collection = []
    paths.each do |path|
      collection << JSON.parse(File.read(path))
    end
    alpha = SdrFriend::Metadata.alphabetize_keys(collection)
    puts JSON.pretty_generate(alpha)
  end

  desc "Alphabetize keys in records in place (saves back to original)"
  task :alpha_in_place, :repository_path do |t, args|
    paths = Find.find(args[:repository_path]).select{ |x| x.include?("geoblacklight.json")}
    paths.each do |path|
      record = JSON.parse(File.read(path)).sort.to_h
      File.open(path, "w") do |f|
        f.write(JSON.pretty_generate(record))
      end
    end
  end

  desc "Add DSpace IDs in records in place (saves back to original)"
  task :dspace_in_place, :repository_path do |t, args|
  paths = Find.find(args[:repository_path]).select{ |x| x.include?("geoblacklight.json")}
  paths.each_with_index do |path, idx|
    puts idx
    record = JSON.parse(File.read(path))
    if record['nyu_addl_dspace_s'].nil?
      record = SdrFriend::Metadata.bitstream_hydrate([record])[0]
      File.open(path, "w") do |f|
        f.write(JSON.pretty_generate(record))
      end
    end
  end
end

  desc "Convert CSV to single JSON record collection file"
  task :csv_to_json, :csv_input, :json_output do |t, args|
    table = CSV.parse(File.read(args[:csv_input]), headers: true)
    collection = []
    table.each do |row|
      collection << SdrFriend::Metadata.row_to_rec(row)
    end

    if args[:json_output].nil?
      ## Pipe out to stdout if no :json_output present
      puts JSON.pretty_generate(collection)
    else
      File.open(args[:json_output], "w") do |f|
        f.write(JSON.pretty_generate(collection))
      end
    end


  end

  desc "Split-out JSON record collection file into multiple individual geoblacklight.json files"
  task :split, :json_input, :destination_path do |t, args|

  end

  desc "Create a blank template CSV for collection"
  task :template, :csv_output do |t, args|

  end



end