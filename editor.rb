require 'erb'
require 'kramdown'
require 'action_view'

require_relative './em_file.rb'
Dir["./extensions/*.rb"].each {|file| require file }

system "mkdir to_convert"
system "mkdir converted"

system "clear"
puts "Welcome to eM Editor v 0.0.7 (extended Markdown)"
puts ""

puts "Main Menu"
puts "========="
puts ""
puts "What do you want to do?"
puts ""
puts "n - create new eM file"
puts "a - reconvert all eM files"
puts "q - quit editor"
choice = gets.chomp.downcase

if choice == "n"
    puts "Name your new file (no extension, no spaces or other funny business)"
    new_file_name = gets.chomp.downcase.gsub(" ", "_")

    new_post = File.new("./to_convert/#{new_file_name}.em", 'w')
    new_post.close

    system "vim ./to_convert/#{new_file_name}.em"

    puts "Ready to convert?"
    puts ""
    puts "y - [y]es, convert just this file" 
    puts "n - [n]o, just leave it as an eM file"
    confirm = gets.chomp

    if confirm.downcase == "y"
        puts "OK, converting ./to_convert/#{new_file_name}.em to ./converted/#{new_file_name}.html"

        this_em_file = EmFile.new("./to_convert/#{new_file_name}.em")
        this_em_file.convert_and_print_to("./converted/#{new_file_name}.html")

        puts ""
        puts ""
        puts "open your html file? (y/n)"
        open_file = gets.chomp
        system "open ./converted/#{new_file_name}.html" if open_file.downcase == 'y'
    end


elsif choice == "a"
  puts "OK, I'll freshly convert all files in ./to_convert/"
  em_files = Dir["./to_convert/*.em"]

  em_files.each do |em_file|
      basename = File.basename(em_file, ".*")

      this_em_file = EmFile.new(em_file)
      this_em_file.convert_and_print_to("./converted/#{basename}.html")
  end
end
