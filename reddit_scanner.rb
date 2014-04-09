# reddit_scanner.rb
# Authors: Jeffrey Klein and James Smith

# redditkit is an API wrapper for Reddit written in Ruby
require 'redditkit'
require './youtube_access'

###

# establish username and password
username = "YouToobBot"
username = "YouToobBot_Test" if ARGV[0] == "test"
password = "csci4330"

# sign in to bot's account
RedditKit.sign_in username, password
# build suspense (delay before next request actually)
sleep 2

# establish time between refreshing feed. default 30
minutes_to_wait = 30
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
last_time = Time.new

# initialize variables for loop.
links_list = []
already_viewed = Array.new 50, nil
before_id = nil
counter = 0

# repeat loop, wait for some time, repeat
while true
  puts "#{ counter+=1 } iterations. #{ Time.new - last_time } seconds passed."
  # sleep( 60 * minutes_to_wait )
  sleep 10
  last_time = Time.new

  # retrieve new posts up until first instance of last group of posts retrieved
  links_list = RedditKit.links(videos_subreddit, category: :new, limit: 25).to_a

  # remove link from list if it's already been viewed
  links_list.delete_if { |link| already_viewed.include? link }

  puts "Size of links list: #{links_list.size}"
  puts "\t.. First: #{already_viewed.first.title}" unless already_viewed.first.nil?
  puts "\t.. Last: #{already_viewed.last.title}" unless already_viewed.last.nil?
  puts "\t.. Size: #{already_viewed.size}"

  # iterate through newly retrieved links
  links_list.reverse.each do |link|
    if link.domain == "youtube.com" || link.domain == "youtu.be"
      # some stuff..
    end
    already_viewed.shift
    already_viewed << link
    puts "\t#{link.domain}\t#{link.title}"
  end
end


# retrieve videos:
# videos_list = RedditKit.links(vids, { limit: x, time: 
# sleep 2 between requests
#
# repeat once each hour
#   retrieve list of 300 (or how many ever) top posts of day
#   for each post
#     if is on list of already_commented, break
#     else, do the following:
#     check that url is valid youtube
#     send url to youtube_access.rb
#     get back info on video
#     send info to comment_generator
#     get nicely formatted comment string back, or nil
#     post comment to link page on reddit
#     add link to already_commented, remove last (or oldest?) item from queue
#   end for
#   remove posts from queue that are older than 24 hours (manages size)




