source "https://rubygems.org"

gem "ruby-dbus"
gem "sinatra", "~>4.1.0"

group :test do
  gem "manageiq-style"
  gem "rack-test"
  gem "rake"
  gem "rspec", "~>3.6"

  # Coverage
  gem "simplecov"
end

# Load other additional Gemfiles
#   Developers can create a file ending in .rb under bundler.d/ to specify additional development dependencies
Dir.glob(File.join(__dir__, 'bundler.d/*.rb')).each { |f| eval_gemfile(File.expand_path(f, __dir__)) }
