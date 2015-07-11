class PageReport
  def initialize(report_group, page_name, oauth_token, start_time, end_time)
    @report_group = report_group
    @page_name = page_name
    @graph = Koala::Facebook::API.new(oauth_token)
    @start_time = start_time
    @end_time = end_time
  end

  def make_api_calls
    go_back_until_unix = Chronic.parse(@start_time).to_i
    go_up_to_unix = Chronic.parse(@end_time).to_i

    this_call = @graph.get_object(@page_name + '/posts?since=' + go_back_until_unix.to_s + '&until=' + go_up_to_unix.to_s + '&limit=99&fields=comments.summary(1).limit(1).redirect(false),likes.summary(1).limit(1).redirect(false),shares,insights,is_published,message,name')
    @posts_from_fb = this_call

    while this_call.size > 2 # || this_call.size == 25 || this_call.size == 200 || this_call.size == 110
      sleep 5
      puts "Making another API call because previous call just wasn't enough."
      oldest_post_created_time = Chronic.parse(@posts_from_fb[-1]["created_time"]).to_i
      this_call = @graph.get_object(@page_name + '/posts?since=' + go_back_until_unix.to_s + '&until=' + oldest_post_created_time.to_s + '&limit=99&fields=comments.summary(1).limit(1).redirect(false),likes.summary(1).limit(1).redirect(false),shares,insights,is_published,message,name')
      @posts_from_fb = @posts_from_fb + this_call
    end
  end

  def build_post_objects_array
    @post_objects = []

    @posts_from_fb.each do |fb_post|
      this_post = Post.new(fb_post)
      this_post.dumb_down
      @post_objects << this_post
    end

    if @post_objects.class == Array && @post_objects != []
      puts "@post_objects is #{@post_objects} and its class is #{@post_objects.class}" 
      @post_objects.sort_by! do |post|
        post.reach
      end.reverse!
    end 

    puts "I made #{@post_objects.size} Post objects!"

    return @post_objects
  end


  def add_report
    @posts = @post_objects

    template_doc= File.open('./templates/incremental_report.html.erb', "r")

    template = ERB.new(template_doc.read, nil, '-')
    puts "about the print"

    File.open("./reports/#{Date.today.to_s}_#{@report_group}_report.em", "a") do |f|
        f.write(
          template.result(binding) # result is an ERB method. `binding` here means we're passing all local variables to the template. 
        )
      f.close
    end
  end 
end
