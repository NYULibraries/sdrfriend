# SdrFriend

SdrFriend is rool that operates a set of rake tasks based on the [RSpec](http://rspec.info/) template. NYU Libraries uses this tool to interface with  various parts of the Spatial Data Infrastructure. Its main components are specific to NYU's deployment of DSpace and Geoserver, but other components may be useful to others in the geospatial data community.

## Installation

In order to install SdrFriend, clone the repository to your hard drive.

    $ git clone https://github.com/NYULibraries/sdrfriend.git

SdrFriend requires Ruby 2.4.0, so if your system has a later version, you'll need to install [Ruby Version Manager (RVM)](https://rvm.io/rvm/install) and switch to Ruby 2.4.0

    $ rvm install 2.4.0
    
    $ rvm use 2.4.0

You also need to [install Homebrew](https://brew.sh/)

    $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Finally, you'll need to install the [Bundler Gem](https://bundler.io/)

    $ gem install bundler

After all these steps are complete, you should be able to install SdrFriend

    $ gem install SdrFriend

To see if the application is working run

    $ bundle exec rake -T
    
You should get a list of commands in the application.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NYULibraries/SdrFriend. This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
