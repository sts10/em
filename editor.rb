require 'erb'
require 'kramdown'
require 'action_view'
# require "sinatra"
require 'pry'
require 'chronic'

# enable :sessions

require_relative './em_file.rb'
Dir["./extensions/*.rb"].each {|file| require file }

# system "mkdir to_convert"
# system "mkdir converted"

# system "clear"
# puts "Welcome to eM Editor v 0.0.7 (extended Markdown)"
# puts ""

# get "/" do
#   "Hey here's the Sinatra index page?"
# end

 
puts "Name your new file (no extension, no spaces or other funny business)"
new_file_name = gets.chomp.downcase.gsub(" ", "_")

new_post = File.new("./to_convert/#{new_file_name}.em", 'w')
new_post << "holder text"
new_post.close

puts "now I'm creating and opening a new html file"
system "touch ./converted/#{new_file_name}.html"  
system "open ./converted/#{new_file_name}.html"

puts "opening your new eM file in your text editor of choice..."
system "subl ./to_convert/#{new_file_name}.em"


keep_running = true

while keep_running
  puts "Converting ./to_convert/#{new_file_name}.em to ./converted/#{new_file_name}.html"

  this_em_file = EmFile.new("./to_convert/#{new_file_name}.em")
  this_em_file.convert_and_print_to("./converted/#{new_file_name}.html")

  puts "Re-convert your eM file to HTML?"
  keep_running = gets.chomp
  if keep_running.downcase == 'n'
    keep_running = false
  end
end


 
