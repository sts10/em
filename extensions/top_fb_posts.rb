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
    if !ENV["top_fb_posts"]
      puts "\nEnter oauth token (get a new one at: \nhttps://developers.facebook.com/tools/explorer)"
      @my_oauth_token = gets.chomp
      self.get_posts 
    end
  end

  def get_posts
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
    if !ENV["top_fb_posts"]
      self.clean_headlines

      html = "<strong>#{@page_name} Facebook</strong>"
      # html = ""

      html = html + "<ul>"
      html = html + "<li><a href=#{@posts[0].url}>#{@posts[0].headline}</a> #{@posts[0].reach} reach</li>"
      html = html + "<li><a href=#{@posts[1].url}>#{@posts[1].headline}</a> #{@posts[1].reach} reach</li>"
      html = html + "<li><a href=#{@posts[2].url}>#{@posts[2].headline}</a> #{@posts[2].reach} reach</li>"
      # 3.times do |i|
      #   if @posts[i]
      #     html = html + "<li><a href=#{@posts[i].url}>#{@posts[i].headline}</a>"
      #     html = html + "#{@posts[i].reach} reach</li>"
      #   end
      # end
      html = html + "</ul>"

      markdown = "**#{@page_name} Facebook**\n"
      markdown = markdown + "1. [#{@posts[0].headline}](#{@posts[0].url}) - #{@posts[0].reach} reach\n"
      markdown = markdown + "2. [#{@posts[1].headline}](#{@posts[1].url}) - #{@posts[1].reach} reach\n"
      markdown = markdown + "3. [#{@posts[2].headline}](#{@posts[2].url}) - #{@posts[2].reach} reach\n"

      ENV["top_fb_posts"] = markdown
    else
      markdown = ENV["top_fb_posts"]
    end

    return markdown # html.html_safe
  end

end