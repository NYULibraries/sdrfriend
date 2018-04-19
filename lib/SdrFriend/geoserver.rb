require 'json'
require 'figs'

module SdrFriend
  class Geoserver

    def initialize
      Figs.load()
    end

    def whatever
      cmd = `curl -u "#{ENV['GEOSERVER_USER']}:#{ENV['GEOSERVER_PASS']}" -H "Accept: application/json" -H "Content-Type: application/json" #{ENV['GEOSERVER_PUBLIC_REST_ENDPOINT']}/workspaces/sdr -s`
      return JSON.parse(cmd)
    end


  end
end