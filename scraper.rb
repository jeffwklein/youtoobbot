# scraper.rb
# Authors: Jeffrey Klein and James Smith

require 'redditkit'
require './video_data'

if ARGV.size != 1
  puts "Must provide exactly one filename argument"
  exit
end

csv = File.new("#{ARGV[0]}.csv","w")

# Constants
HundredsOfPosts = 100
BotUsername = "vid-info"
BotPassword = "csci4330"
#

RedditKit.sign_in BotUsername, BotPassword

# initially retrieve links
begin
  links_list = RedditKit.links(
    "videos",
    { :category => :top,
      :time => :all,
      :limit => 100
    }
  )
rescue
  puts "Failed to get posts. Retrying..."
  sleep 2
  retry
end

HundredsOfPosts.times do |i|
  sleep 2
  links_list.to_a.keep_if {|link| link.domain == "youtube.com" || link.domain == "youtu.be"}.each do |link|
    vd = VideoData.new link
    newline = "\"#{vd.url}\",\"#{vd.title}\",\"#{vd.post_url}\",\"#{vd.date}\","
    newline += "\"#{vd.pic}\",\"#{vd.keywords}\",\"#{vd.views}\",\"#{vd.votes}\""
    csv.puts newline
  end
  begin
    puts "Completed posts #{i*100} - #{(i+1)*100-1}. Latest score: #{links_list.to_a.last.score}. Latest post: #{links_list.to_a.last.permalink}"
  rescue
    puts "Completed posts #{i*100} - #{(i+1)*100-1}."
  end
  begin
    links_list = RedditKit.links(
      "videos",
      { :category => :top,
        :time => :all,
        :limit => 100,
        :after => links_list.after
      }
    )
  rescue
    puts "Failed to get posts. Retrying..."
    sleep 2
    retry
  end
end
