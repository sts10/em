require 'erb'
require 'kramdown'
require 'action_view'
require 'pry'
require 'chronic'

require_relative './em_file.rb'
Dir["./extensions/*.rb"].each {|file| require file }
require_relative './extensions/article.rb'

em_line = ARGV[0]

if Article.identify(em_line)
  this_article = Article.new(em_line)
  html = this_article.present
else
  html = em_line
end

puts html
print html

html
