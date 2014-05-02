# video_data.rb
# Authors: Jeffrey Klein and James Smith
#
require 'open-uri'
require 'redditkit'
require 'fast-stemmer'

class VideoData
  attr_reader :url, :title, :post_url, :date, :pic, :keywords, :views, :votes, :stems

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
    @stems = safe_match(/"keywords": "(.*?)",/, source_str)
    @stems = format_stems(@stems)
    category = safe_match(/<p id="eow-category"><a.*?>(.*?)<\/a>/, source_str)
    if (add_category = format_stems(category)) != nil
      @stems += add_category
    end
    if (add_title = format_stems(@title)) != nil
      @stems += add_title
    end
    @stems.uniq!
    @keywords = @stems.map { |word| Stemmer::stem_word(word) }.sort.join(" ")
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
  def format_stems(str)
    return str.gsub(/,/, " ").gsub(/[^\w\d ]/,"").downcase.split
  end

end
