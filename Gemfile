path "../"
source 'https://rubygems.org'

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  # stable forked version of active_model_serializers in order to write an integration test
  gem 'active_model_serializers', git: 'git@github.com:indiegogo/active_model_serializers.git', branch: '0-8-stable'
  # currently testing against 5.0.0
  gem 'railties', '5.0.0'
  gem 'actionpack', '5.0.0'
  gem 'activerecord', '5.0.0'
end

gemspec