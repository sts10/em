require 'twitter-text'
require 'twitter'

require_relative '../secrets.rb'

class Tweet
  include Twitter::Autolink

  attr_reader :tweet_id, :text, :user_name, :user_handle, :tweet_url, :created_at

  TWITTER_REST = Twitter::REST::Client.new do |config|
    config.consumer_key = $twitter_consumer_key
    config.consumer_secret = $twitter_consumer_secret
    config.access_token = $twitter_access_token
    config.access_token_secret = $twitter_access_token_secret
  end

  def self.identify(em_line)
    if (em_line[0..1] == "eb" || em_line[0..1] == "se") && em_line.include?("twitter.com")
      return true
    else
      return false
    end
  end 

  def initialize(em_line)
    # should really parse em_line > tweet status
    tweet_obj = TWITTER_REST.status(em_line)

    @tweet_id = tweet_obj.id
    @text = tweet_obj.text
    @user_name = tweet_obj.user.name
    @user_handle = tweet_obj.user.handle
    @tweet_url = tweet_obj.url
    @created_at = tweet_obj.created_at
    @expanded_urls = tweet_obj.urls.map { |url| url.attrs[:expanded_url] }    

    if em_line[0..1] == "eb" && em_line.include?("twitter.com")
      @embed = "normal"
    elsif em_line[0..1] == "se" && em_line.include?("twitter.com")
      @embed = "simple"
    end
  end

  def expanded_urls 
    @expanded_urls
  end

  def linkify_tweet
    html = auto_link(self.text)
  end 

  def self.head_code
    <<-EOF 

    <!-- JS below is from https://dev.twitter.com/web/javascript/loading -->
    <script>window.twttr = (function(d, s, id) {
      var js, fjs = d.getElementsByTagName(s)[0],
        t = window.twttr || {};
      if (d.getElementById(id)) return t;
      js = d.createElement(s);
      js.id = id;
      js.src = "https://platform.twitter.com/widgets.js";
      fjs.parentNode.insertBefore(js, fjs);
     
      t._e = [];
      t.ready = function(f) {
        t._e.push(f);
      };
     
      return t;
    }(document, "script", "twitter-wjs"));</script>

    EOF
  end


  def present
    if @embed == "normal"
      html = "<blockquote class=\"twitter-tweet\" align=\"left\" lang=\"en\"><p>"
    else
      html = "<blockquote align=\"left\" lang=\"en\"><p>"
    end
    html = html + self.linkify_tweet
    html = html + "</p>&mdash; #{self.user_name} (@#{self.user_handle}) <a href=\"#{self.tweet_url}\">#{self.created_at.strftime("%m/%d/%y")}</a></blockquote>"
    html = html + "<div class='clearfix'></div>"
    return html.html_safe
  end 
  
end

