require 'json'
require 'figs'

module SdrFriend
  class Geoserver

    def initialize
      Figs.load()
    end

    # def whatever
    #   cmd = `curl -u "#{ENV['GEOSERVER_USER']}:#{ENV['GEOSERVER_PASS']}" -H "Accept: application/json" -H "Content-Type: application/json" #{ENV['GEOSERVER_PUBLIC_ENDPOINT']}/rest/workspaces/sdr -s`
    #   return JSON.parse(cmd)
    # end

    def enable_vector_layer(layer_slug, title, endpoint)
      geoserver = nil
      if endpoint.downcase == "restricted"
        geoserver = ENV['GEOSERVER_RESTRICTED_ENDPOINT']
      elsif endpoint.downcase == "public"
        geoserver = ENV['GEOSERVER_PUBLIC_ENDPOINT']
      else
        raise("Could not find an endpoint!")
      end
      request = {
          featureType: {
              name: layer_slug,
              title: title
          }
      }
      cmd = `curl -u "#{ENV['GEOSERVER_USER']}:#{ENV['GEOSERVER_PASS']}" -XPOST -H "Accept: application/json" -H "Content-Type: application/json" -d '#{JSON.generate(request)}' #{geoserver}/rest/workspaces/sdr/datastores/vector_postgis/featuretypes -s`
      return cmd
    end

    ## GeoWebCache functions
    # GWC API documentation at http://docs.geoserver.org/stable/en/user/geowebcache/rest/

    def seed_layer_cache(layer_id_s, endpoint, gridset_id, zoom_start=0, zoom_stop=5, threads=1)
      # gs.seed_layer_cache("sdr:nyu_2451_34537", ENV['GEOSERVER_RESTRICTED_ENDPOINT'], "EPSG:900913", 0, 15, 1)
      # Typical gridsets are:
      # EPSG:900913EPSG:900913_512x512_retina
      #
      request = {
        seedRequest: {
            name: layer_id_s,
            gridSetId: gridset_id,
            zoomStart: zoom_start,
            zoomStop: zoom_stop,
            format: "image/png",
            type: "seed",
            threadCount: threads
        }
      }
      cmd = `curl -u "#{ENV['GEOSERVER_USER']}:#{ENV['GEOSERVER_PASS']}" -XPOST -H "Accept: application/json" -H "Content-Type: application/json" -d '#{JSON.generate(request)}' #{endpoint}/gwc/rest/seed/#{layer_id_s}.json -s`
      return cmd
    end

    def get_current_gwc_tasks(endpoint)
      cmd = `curl -u "#{ENV['GEOSERVER_USER']}:#{ENV['GEOSERVER_PASS']}" -H "Accept: application/json" -H "Content-Type: application/json" #{endpoint}/gwc/rest/seed.json -s`
      return JSON.parse(cmd)
    end

    def kill_all_gwc_tasks(endpoint)
      ## Unfortunately, this API task only seems to respond with HTML
      cmd = `curl -u "#{ENV['GEOSERVER_USER']}:#{ENV['GEOSERVER_PASS']}" -d "kill_all=all" #{endpoint}/gwc/rest/seed -s`
      return cmd
    end



  end
end