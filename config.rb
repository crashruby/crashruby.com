require 'dotenv'
Dotenv.load

###
# Blog settings
###

Time.zone = "Eastern Time (US & Canada)"

activate :blog do |blog|
  # blog.prefix = "blog"
  # blog.permalink = ":year/:month/:day/:title.html"
  blog.sources = "/articles/:year-:month-:day-:title.html"
  # blog.taglink = "tags/:tag.html"
  blog.layout = "article_layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = ":year.html"
  # blog.month_link = ":year/:month.html"
  # blog.day_link = ":year/:month/:day.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/:num"
end

# Activate sync extension
activate :sync do |sync|
  sync.fog_provider = 'AWS'
  sync.fog_directory = 'crashruby.com'
  sync.fog_region = 'us-east-1'
  sync.aws_access_key_id = ENV['AWS_ACCESS_KEY']
  sync.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  sync.existing_remote_files = 'delete'
  sync.after_build = true
end

activate :livereload
activate :asset_hash
activate :minify_html
activate :directory_indexes

page "/*", :layout => "application"
page "/feed.xml", :layout => false
page "/articles/*", :layout => "article"

###
# Markdown
###

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

###
# Code highlighting
###

activate :rouge_syntax

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
end
