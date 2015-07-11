require 'koala'
require 'erb'
require 'date'
require 'chronic'
require 'pry'

require_relative './top_fb_posts_lib/post.rb'
require_relative './top_fb_posts_lib/page_report.rb'

class TopFbPosts
  def self.identify(em_line)
    em_line.chomp == "top fb posts"
  end

  def initialize(em_line)
    puts "Enter oauth token (get a new one at https://developers.facebook.com/tools/explorer)"
    @my_oauth_token = gets.chomp

    @report_group = "buzzfeednews"
    @page_name = "buzzfeednews"

    @start_time = "24 hours ago"
    @end_time = "now"

    puts "Fetching the posts for " + @page_name
    this_report = PageReport.new(@report_group, @page_name, @my_oauth_token, @start_time, @end_time)
    this_report.make_api_calls
    @posts = this_report.build_post_objects_array
  end

  def clean_headlines
    @posts.each do |post|
      if !post.headline || post.headline = ''
        post.headline = post.copy
      end
    end
  end

  def format_number(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  def present 
    self.clean_headlines

    html = "<strong>#{@page_name} Facebook</strong>"
    html = html + "<ol>"
    3.times do |i|
      if @posts[i]
        html = html + "<li><a href=#{@posts[i].url}>#{@posts[i].headline}</a>"
        html = html + "#{@posts[i].reach} reach"
      end
    end

    return html.html_safe
  end

end