#require 'rubygems'
require 'fast-stemmer'
require 'open-uri'
 
module YoutoobParser
  def self.extract_data(uri_str)
    begin
      str = open(uri_str).read
    rescue
      return {}
    end
    data_hash = Hash.new

    data_hash[:url] = uri_str
    
    title_matchdata = /<title>(.*)<\/title>/.match(str)
    title = data_hash[:title] = title_matchdata[1] unless title_matchdata.nil?
    print "Title: #{title}\n"

    date_matchdata = /<span id="eow-date" class="watch-video-date" >(.*)<\/span>/.match(str)
    date = data_hash[:publish_date] = date_matchdata[1] unless date_matchdata.nil?
    print "Date: #{date}\n"

    channel_matchdata = /data-name="watch">(.*)<\/a><span/.match(str)
    channel = data_hash[:channel_title] = channel_matchdata[1] unless channel_matchdata.nil?
    print "Channel: #{channel}\n"

    channelurl_matchdata = /<meta itemprop="channelId" content="(.*)">/.match(str)
    channelurl = data_hash[:channel_url] = "http://www.youtube.com/channel/#{channelurl_matchdata[1]}" unless channelurl_matchdata.nil?
    print "Channel URL: #{channelurl}\n"

    desc_matchdata = /<p id="eow-description" >(.*)<\/p>/.match(str)
    desc = data_hash[:description] = desc_matchdata[1][0...500] unless desc_matchdata.nil?
    print "Description: #{desc}\n"

    thumbnailurl_matchdata = /<link itemprop="thumbnailUrl" href="(.*)">/.match(str)
    thumbnailurl = data_hash[:thumbnail_url] = thumbnailurl_matchdata[1] unless desc_matchdata.nil?
    print "Thumbnail URL: #{thumbnailurl}\n"

    time_matchdata = /<meta itemprop="duration" content="(.*)">/.match(str)
    time = data_hash[:duration] = format_duration(time_matchdata[1]) unless time_matchdata.nil?
    print "Time: #{time}\n"

    views_matchdata = /<span class="watch-view-count " >\n *(.*)\n/.match(str)
    views = data_hash[:view_count] = views_matchdata[1] unless views_matchdata.nil?
    print "View Count: #{views}\n"

    likes_matchdata = /"likes-count">(.*)<\/span>/.match(str)
    likes_count = data_hash[:like_count] = likes_matchdata[1] unless likes_matchdata.nil?
    print "Likes: #{likes_count}\n"
    
    dislikes_matchdata = /"dislikes-count">(.*)<\/span>/.match(str)
    dislikes_count = data_hash[:dislike_count] = dislikes_matchdata[1] unless dislikes_matchdata.nil?
    print "Dislikes: #{dislikes_count}\n"

    return data_hash
  end

  private

  # helper method to format YouTube's duration string format into mm:ss form
  def self.format_duration(string)
    string.gsub!(/[PTMS]/, "PT" => "", "M" => ":", "S" => "")
    string = "0:" + string unless string.include?(":")
    string.insert(-2,"0") if string[-2] == ":"
    return string
  end

end

# test parser and stemmer (REMOVE LATER)
yp = YoutoobParser.extract_data "https://www.youtube.com/watch?v=-vE04u94h0Y"
run = 'running'.stem
print run
