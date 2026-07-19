source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Rails 7.1 - Latest stable with security patches
gem 'rails', '~> 7.1.0'
gem 'sqlite3', '~> 1.7'
gem 'puma', '~> 6.4'

# Asset pipeline - updated versions
gem 'sass-rails', '~> 6.0'
gem 'uglifier', '~> 4.2'
gem 'sprockets', '~> 4.2'

# UI/Frontend
gem 'bootstrap-sass', '~> 3.4'
gem 'jquery-rails', '~> 4.6'
gem 'coffee-rails', '~> 5.0'
gem 'turbolinks', '~> 5.2'
gem 'jbuilder', '~> 2.11'
gem 'haml-rails', '~> 2.1'
gem 'd3_rails', '~> 4.13'

# Development tools
gem 'pry-rails', '~> 0.3'
gem 'yard', '~> 0.9'
gem 'spring', '~> 4.1', group: :development

group :development do
  gem 'html2haml', '~> 2.3'
  gem 'better_errors', '~> 2.10'
  gem 'binding_of_caller', '~> 1.0'
  gem 'web-console', '~> 4.2'
end

group :test do
  # factory_bot replaces factory_girl (actively maintained)
  gem 'factory_bot_rails', '~> 6.4'
  gem 'minitest-rails', '~> 7.1'
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.15'
end

group :development, :test do
  gem 'byebug', '~> 11.1', platforms: [:mri, :mingw, :x64_mingw]
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
