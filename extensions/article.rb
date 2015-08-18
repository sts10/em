require 'nokogiri'
require 'open-uri'
require 'uri'

class Article
  attr_reader :title, :url

  def self.identify(em_line)
    em_line[0..3] == "http" && ['.com', '.org', '.edu', '.gov'].any? { |ending| em_line.include?(ending) }    
  end 
  
  def initialize(url)
    @url = url
    if !@url.include?("nytimes.com")
      url = URI.encode(url)

      @article_page = Nokogiri::HTML(open(url))
      @title = @article_page.css('title').text.lstrip.rstrip
    else
      encoded_url = URI.encode(url)
      @title = File.basename(URI.parse(encoded_url).path, ".*").gsub('-', ' ').split(/(\W)/).map(&:capitalize).join
    end
  end

  def present
    html = "<a href='#{@url}'>#{@title}</a>"
    return html.html_safe
  end
end