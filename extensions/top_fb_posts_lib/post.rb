class Post 
  attr_accessor :id, :url, :headline, :copy, :likes, :comments, :shares, :reach, :impressions
  def initialize(fb_post_object)
    @id = fb_post_object['id']
    @url = 'http://facebook.com/' + id
    @headline = fb_post_object['name']
    @copy = fb_post_object['message']
    
    if fb_post_object && fb_post_object['insights']
      insights = fb_post_object['insights']['data'] 
    else
      insights = false
    end


    if insights && insights[3].values[3][0]['value'] != []
      puts 'insights[3].values[3][0]' + insights[3].values[3][0].to_s

      @likes = insights[3].values[3][0]['value']['like'] 
      @comments = insights[3].values[3][0]['value']['comment']
      @shares = insights[3].values[3][0]['value']['share']
    
      @reach = insights[4].values[3][0]['value']
      @impressions = insights[5].values[3][0]['value']
    else 
      @likes = 0
      @comments = 0
      @shares = 0
      @reach = 0 
      @impressions = 0
    end

  end

  def dumb_down
    # replace smart quotes and other puncution with they HTML codes or dumb alternatives
    @headline = @headline.to_s.gsub("“", "&ldquo;").gsub("”", "&rdquo;").gsub("‘", "&lsquo;").gsub("’", "&rsquo;").gsub("–", "&mdash;").gsub('…', '...')
    @headline = @headline.to_s.gsub("&acirc;&#128;&#156;", '&ldquo;').gsub("&acirc;&#128;&#157;", '&rdquo;').gsub("&acirc;&#128;&#152;", "&lsquo;").gsub("&acirc;&#128;&#153;", "&rsquo;")
    
    @copy = @copy.to_s.gsub("“", "&ldquo;").gsub("”", "&rdquo;").gsub("‘", "&lsquo;").gsub("’", "&rsquo;").gsub("–", "&mdash;").gsub('…', '...')
    @copy = @copy.to_s.gsub("&acirc;&#128;&#156;", '&ldquo;').gsub("&acirc;&#128;&#157;", '&rdquo;').gsub("&acirc;&#128;&#152;", "&lsquo;").gsub("&acirc;&#128;&#153;", "&rsquo;")
  end

end