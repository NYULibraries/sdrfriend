require 'csv'
require 'json'
require 'figs'

  module SdrFriend
    class Fda
      def initialize(autoload=true)
        Figs.load
        @token = nil
        @handle_table = nil
        if autoload
          load_table
          authenticate
        end
      end

      def load_table
        @handle_table = grab_lookup_table(ENV["CSV_DSPACE_LOOKUP_TABLE_URL"])
      end

      def authenticate
        @token = grab_token(ENV["FDA_USER"], ENV["FDA_PASS"])
      end

      ## Authenticates with DSpace API
      def grab_token(username, password)
        cmd = `curl -X POST -H "Content-Type: application/json" -d '{"email":"#{username}","password":"#{password}"}' #{ENV["FDA_REST_ENDPOINT"]}/login --insecure`
        return cmd
      end

      ## Retrieves a handle -> dspace_id lookup table
      def grab_lookup_table(csv_url)
        cmd = `curl #{csv_url}`
        csv = CSV.parse(cmd)
        table = {}
        csv.each{ |row| table[row[0]] = row[1]}
        return table
      end

      ## Converts between a handle and a dspace_id
      def translate_handle_to_dspace_id(handle)
        ## Three possible patterns:
        # http://handle.net/2451/12345
        # nyu_2451_12345
        # nyu-2451-12345
        if /^https?:\/\/hdl.handle.net\/\d{4}\/\d{5}$/.match(handle)
          return handle_to_dspace(handle.gsub(/^https?:\/\/hdl.handle.net\//, ""))
        elsif /^nyu-\d{4}-\d{5}$/.match(handle)
          return handle_to_dspace(handle.gsub("nyu-","").gsub("-","/"))
        elsif /^nyu_\d{4}_\d{5}$/.match(handle)
          return handle_to_dspace(handle.gsub("nyu_","").gsub("_","/"))
        else
          raise 'Handle given does not match known pattern!'
        end
      end

      def grab_item_metadata(identifier)
        dspace_id = identifier
        if is_handle?(identifier)
          dspace_id = translate_handle_to_dspace_id(identifier)
        end
        cmd = `curl -X GET -H "Content-Type: application/json" -H "Accept: application/json" -H "rest-dspace-token: #{@token}" #{ENV["FDA_REST_ENDPOINT"]}/items/#{dspace_id}?expand=all --insecure`
        JSON.parse(cmd)
      end

      def is_handle?(input)
        if /^https?:\/\/hdl.handle.net\/\d{4}\/\d{5}$/.match(input)
          return true
        elsif /^nyu-\d{4}-\d{5}$/.match(input)
          return true
        elsif /^nyu_\d{4}_\d{5}$/.match(input)
          return true
        else
          return false
        end
      end


      def upload_bitstream(path_to_file, dspace_id=nil, force=false)
        ## Given a file, uploads to the appropriate FDA record if it hasn't already been uploaded
        filename = File.basename(path_to_file)
        if dspace_id.nil?
          ## Ascertain handle
          handle = filepath_to_handle(path_to_file)
          target_id = translate_handle_to_dspace_id(handle)
        else
          target_id = dspace_id
        end
        current_metadata = grab_item_metadata(target_id)
        if !bitstream_exists?(current_metadata, filename) || force
          return upload_bitstream_to_dspace(path_to_file, target_id)
        end
        raise "Could not upload bitstream"
      end

      def bitstream_exists?(fda_metadata, bitstream_name)
        fda_metadata['bitstreams'].each do |bitstream|
          if bitstream['name'] == bitstream_name
            return true
          end
        end
        return false
      end

      def grab_items(items, threads)


      end

      private
      def upload_bitstream_to_dspace(absolute_path_to_file, dspace_id)
        filename = File.basename(absolute_path_to_file)
        cmd = `curl --data-binary "@#{absolute_path_to_file}" -H "Accept: application/json" -H "rest-dspace-token: #{@token}" #{ENV["FDA_REST_ENDPOINT"]}/items/#{dspace_id}/bitstreams?name=#{filename} --insecure`
        return cmd
      end

      def handle_to_dspace(handle)
        ## handle in pattern "2451/12345"
        return @handle_table["http://hdl.handle.net/#{handle}"]
      end

      def filepath_to_handle(filepath)
        match = /nyu_\d{4}_\d{5}?/.match(filepath)
        if !match.nil?
          return match[match.size - 1]
        else
          raise 'No handle pattern detected in filename -- upload destination is ambiguous. (Filename must include "nyu_2451_12345" pattern!)'
        end
      end



    end
  end