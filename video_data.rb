# video_data.rb
# Authors: Jeffrey Klein and James Smith
#
# Class that represents data about a particular YouTube
# video posted to reddit.com. The class extracts video
# information from the YouTube video page's source code.
# Then it formats extracted tags into a search-friendly
# format, removing stop words and stemming.
#
require 'open-uri'
require 'redditkit'
require 'fast-stemmer'
require './stop_words'

class VideoData
  attr_reader :url, :title, :post_url, :date, :pic, :keywords, :views, :votes

  def initialize(reddit_post)
    @post_url = reddit_post.permalink
    @date = reddit_post.created_at.strftime("%F %H:%M:%S")
    @votes = reddit_post.score
    @votes = 0 if @votes == nil

    @url = reddit_post.url
    begin
      source_str = open(@url).read
    rescue
      source_str = ""
    end
    @title = safe_match(/<title>(.*?)<\/title>/, source_str)
    @pic = safe_match(/<link itemprop="thumbnailUrl" href="(.*?)">/, source_str)
    @views = safe_match(/<span class="watch-view-count " >\n *(.*?)\n/, source_str).gsub(/,/,"")
    @views = 0 if @views == ""
    # tags, category, vid title; all stemmed.
    @keywords = safe_match(/"keywords": "(.*?)",/, source_str)
    @keywords = remove_chars(@keywords)
    category = safe_match(/<p id="eow-category"><a.*?>(.*?)<\/a>/, source_str)
    if (add_category = remove_chars(category)) != nil
      @keywords += add_category
    end
    if (add_title = remove_chars(@title)) != nil
      @keywords += add_title
    end
    @keywords.uniq!
    @keywords.delete_if { |word| StopWords.is_stop_word?(word) }
    @keywords = @keywords.map { |word| Stemmer::stem_word(word) }.sort.join(" ").strip
  end

  private

  # error safe; returns string of match from matchdata or nil if no match found
  def safe_match(regex, search_str)
    matchdata = regex.match(search_str)
    return "" if matchdata.nil?
    return "" if matchdata.size < 2
    return matchdata[1]
  end

  # formats given string into standardized array format. nil if nil value provided
  def remove_chars(str)
    return str.gsub(/,/, " ").gsub(/[^\w\d ]/,"").downcase.split
  end
end
