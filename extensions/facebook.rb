class Facebook
  def self.identify(em_line)
    em_line[0..1] == "eb" && em_line.include?("facebook.com")
  end

  def initialize(em_line)
    @em_line = em_line
  end 

  def self.body_top_code
    <<-EOF 
    <!-- https://developers.facebook.com/docs/plugins/embedded-posts -->
    <div id="fb-root"></div>
    <script>(function(d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.2";
    fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));</script>

    EOF
  end

  def present
    html = "<div class='fb-post' data-href='#{@em_line[10..-1]}' data-width='500'></div><div class='clearfix'></div>"
    return html.html_safe
  end

end