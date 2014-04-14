# reddit_scanner.rb
# Authors: Jeffrey Klein and James Smith

# redditkit is an API wrapper for Reddit written in Ruby
require 'redditkit'
require './youtube_access'
require './comment_generator'

###

# establish username and password
username = "YouToobBot"
username = "YouToobBot_Test" if ARGV[0] == "test"
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

# repeat loop, wait for some time, repeat
while true
  # wait before making next request
  # sleep( 60 * minutes_to_wait )
  sleep 10
  puts "\n#{ counter+=1 } iterations. #{ Time.new - last_time - 10 } seconds passed."
  last_time = Time.new

  # retrieve new posts up until first instance of last group of posts retrieved
  links_list = RedditKit.links(videos_subreddit, category: :new, limit: 25).to_a

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
    # send to youtube_access.rb, use URL to get data and return as hash
    # send hash to comment_generator.rb (or method here) to format the data into comment string
    # finally post comment to link's comments section on reddit
    already_viewed.pop
    already_viewed.unshift link
    puts "\t\t#{link.domain}\t#{link.title}"
  end
end


###
# pseudocode / notes
#
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




