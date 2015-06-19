require 'nokogiri'
require 'open-uri'
require 'uri'

class Article
  attr_reader :title, :url

  def self.identify(em_line)
    em_line[0..3] == "http"
  end 

  
  def initialize(url)
    @url = url
    if !@url.include?("nytimes.com")
      @article_page = Nokogiri::HTML(open(url))
      @title = @article_page.css('title').text.lstrip.rstrip
    else
      # basename = File.basename(em_file, ".*")
      @title = File.basename(URI.parse(url).path, ".*").gsub('-', ' ').split(/(\W)/).map(&:capitalize).join
    end
  end

  def present
    html = "<a href='#{@url}'>#{@title}</a>"
    return html.html_safe
  end
end