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
    @reddit_post = reddit_post.score

    @url = reddit_post.url
    begin
      source_str = open(@url).read
    rescue
      source_str = ""
    end
    @title = safe_match(/<title>(.*?)<\/title>/, source_str)
    @pic = safe_match(/<link itemprop="thumbnailUrl" href="(.*?)">/, source_str)
    @views = safe_match(/<span class="watch-view-count " >\n *(.*?)\n/, source_str).gsub(/[^\d]/,"")
    # tags, category, vid title; all stemmed.
    @stems = safe_match(/"keywords": "(.*?)",/, source_str)
    @stems = format_stems(@stems)
    category = safe_match(/<p id="eow-category"><a.*>(.*?)<\/a>/, source_str)
    if (add_category = format_stems(category)) != nil
      @stems += add_category
    end
    if (add_title = format_stems(@title)) != nil
      @stems += add_title
    end
    @stems.each { |word| Stemmer::stem_word(word) }
    @keywords = @stems.sort.join(" ")
    # Next to do with database access object:
    #   2.  add new stems in table
    #   3.  add instance in other table using data from instance of this class
    #
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
