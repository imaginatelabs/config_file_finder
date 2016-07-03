# ConfigFileFinder

Ruby Gem that helps to find config files in the root of a project.

Many project based cli tools require config files in the root of your project. Things go wrong when you start trying to execute commands in the child directories of your project because the cli tool expects you to execute the commands in the root of the project. This gem solves that by traversing the parent folders until it either finds the config file or it hits the project's root directory.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'config_file_finder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install config_file_finder

## Usage

### Find config from any directory in your project
```ruby
# Given the working directory /user/me/code/project/lib
# Given the config file is located /user/me/code/project/.my_config.yml

ConfigFileFinder.new('.my_config.yml').find # => {:result=>:success, :files=>[{:project_root_config=>"/user/me/code/project/.my_config.yml"}]} 
```

### Don't search beyond the root of the project
```ruby
# Given the working directory /user/me/code/project/lib
# Given there is no conifig files
ConfigFileFinder.new('.my_config.yml').find # {:result=>:failed, :files=>[{:project_root=>"/users/me/code/project"}], :message=>"Couldn't find config file .config.yml, stopping search at project root directory"}
```

### Add additional files to detect the project root
The project root is detects by looking for the following files
```bash
.git/ 
.hg/ 
.svn/ 
lib/ 
bin/ 
src/ 
test/ 
README.md 
README.txt 
README.markdown 
README
```

If they aren't enough then you can add additional files 
```ruby
finder = ConfigFileFinder.new '.my_config.yml'

# Singul strings
finder.add_root_patterns 'Gemfile'
finder.add_root_patterns 'Rakefile'

# Array of strings
finder.add_root_patterns ['.gitignore', '.travis.yml']
```

Or override them completely 
```ruby
finder = ConfigFileFinder.new '.my_config.yml'

finder.root_patterns ['Gemfile', 'Rakefile, '.gitignore', '.travis.yml']
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/config_file_finder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

