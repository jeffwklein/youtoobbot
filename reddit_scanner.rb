# reddit_scanner.rb
# Authors: Jeffrey Klein and James Smith

# redditkit is an API wrapper for Reddit written in Ruby
require 'redditkit'
require './youtube_access'
require './comment_generator'
require './comment_parser'

###
# Wait-time Constants
SECONDS_BETWEEN_ITERATIONS = 300
SECONDS_BETWEEN_COMMENTS = 5
SECONDS_BEFORE_RETRY = 20

# establish username and password
username = "vid-info"
username = "vid-info-test" if ARGV[0] == "test"
password = "csci4330"

# sign in to bot's account
RedditKit.sign_in username, password
sleep 2
print "\n\n"

# establish time in minutes between requests
minutes_to_wait = (1/6)  # 10 seconds
minutes_to_wait = ARGV[1].to_i if ARGV[1]

# notify and exit on login failure
unless RedditKit.signed_in?
  puts "Sign in to #{username} unsuccessful."
  exit
else
  puts "Sign in to #{username} successful."
end
# build suspense
sleep 2

# establish access to /r/videos subreddit
videos_subreddit = RedditKit.subreddit "videos"
# verify connection
if videos_subreddit.nil?
  puts "Failed to establish connection to /r/videos"
  exit
else
  puts "Established connection to /r/videos"
end
# build suspense
sleep 2

# save system time for reference point
initial_time = last_time = Time.new

# initialize array of 50 nil values for consistent size (nils will be pushed out eventually)
already_viewed = Array.new 50, nil
counter = 0
new_links_count = 0
youtube = YouTubeAccess.new

# repeat loop, wait for some time, repeat
while true
  # wait before making next request
  # sleep( 60 * minutes_to_wait )
  # sleep 200 if counter > 0 # 2.5 minutes wait time
  print "Next iteration in    "
  countdown = SECONDS_BETWEEN_ITERATIONS # seconds between iterations
  print "\b\b\b#{countdown}#{" "*((-1*countdown.to_s.size)%3)}" or sleep 1 while (countdown -= 1) > 0

  puts "\n\n#{ counter+=1 } iterations. #{ Time.new - last_time } seconds passed."
  last_time = Time.new
  puts "Current time: #{last_time}"

  # retrieve new posts up until first instance of last group of posts retrieved
  begin
    links_list = RedditKit.links(videos_subreddit, category: :new, limit: 20).to_a
  rescue RedditKit::TimedOut => err
    puts "Error: RedditKit::TimedOut ...waiting for 60 seconds then retrying"
    sleep 60
    retry
  rescue RedditKit::RequestError => err
    puts "Error: RedditKit::RequestError ...waiting for 60 seconds then retrying"
    sleep 60
    retry
  end
  sleep 5

  # remove link from list if it's already been viewed
  links_list.delete_if { |link| already_viewed.include? link }
  links_list.keep_if { |link| link.domain == "youtube.com" || link.domain == "youtu.be" }
  new_links_count += links_list.size if counter > 1

  puts "\tSize of links list: #{links_list.size}"
  puts "\t#{new_links_count} new links discovered in #{Time.new - initial_time} seconds"
  puts "\tSize of already viewed links list: #{already_viewed.size}"
  puts "\tFirst on already viewed links list: #{already_viewed.first.title}" unless already_viewed.first.nil?
  puts "\tLast on already viewed links list: #{already_viewed.last.title}" unless already_viewed.last.nil?

  # iterate through newly retrieved links
  puts "\tNew links found: #{links_list.size}"
  links_list.reverse_each do |link|
    already_viewed.pop
    already_viewed.unshift link
    # send to youtube_access.rb, use URL to get data and return as hash
    response = youtube.get_video_info(link.url)
    next if response.nil?
    # send hash to comment_generator.rb to format the data into comment string
    comment = CommentGenerator.generate_comment(response, link.url)
    next if comment.nil?
    # finally post comment to link's comments section on reddit
    try_count = 0
    begin
      comment_obj = RedditKit.submit_comment(link, comment)
      puts "******* SUCCESSFULLY POSTED COMMENT TO \"#{link.title}\"" unless comment_obj.nil?
      #puts "\t\tComment:\n#{comment}"
    rescue RedditKit::RateLimited 
      puts "Retrying for link #{link.title}"
      # give it a minute
      sleep SECONDS_BEFORE_RETRY
      retry if (try_count += 1) < 3
    rescue NoMethodError
      puts "NoMethodError encountered on #{link.title}"
      puts "Continuing..."
    end
    sleep SECONDS_BETWEEN_COMMENTS
  end
  puts "----END OF ITERATION----"
end


