# video_data.rb
# Authors: Jeffrey Klein and James Smith
#
require 'open-uri'
require 'redditkit'

class VideoData
  attr_reader :reddit_url, :reddit_date, :reddit_score, :youtube_url, :video_title, :thumbnail_url, :viewcount, :stems

  def initialize(reddit_post, yt_url)
    @reddit_url = reddit_post.permalink
    @reddit_date = reddit_post.created_at.strftime("%F %H:%M:%S")
    @reddit_post = reddit_post.score

    @youtube_url = yt_url
    begin
      source_str = open(yt_url).read
    rescue
      source_str = ""
    end
    @video_title = safe_match(/<title>(.*)<\/title>/, source_str)
    @thumbnail_url = safe_match(/<link itemprop="thumbnailUrl" href="(.*)">/, source_str)
    @viewcount = safe_match(/<span class="watch-view-count " >\n *(.*)\n/, source_str)
    # tags, category, vid title; all stemmed.
    @stems = safe_match(/"keywords": "(.*)",/, source_str)
    @stems = format_stems(@stems)
    category = safe_match(/<p id="eow-category"><a.*>(.*)<\/a>/, source_str)
    if (add_category = format_stems(category)) != nil
      @stems += add_category
    end
    if (add_title = format_stems(@video_title)) != nil
      @stems += add_title
    end
    #
    # perform stemming algorithm
    #
    @stems_str = @stems.sort.join(" ")
    #
    # Next to do with database access object:
    #   1.  compare with database so duplicate values are not added to stems table
    #   2.  add new stems in table
    #   3.  add instance in other table using data from instance of this class
    #
  end

  private

  # error safe; returns string of match from matchdata or nil if no match found
  def safe_match(regex, search_str)
    matchdata = regex.match(search_str)
    return nil if matchdata.nil?
    return nil if matchdata.size < 2
    return matchdata[1]
  end

  # formats given string into standardized array format. nil if nil value provided
  def format_stems(str)
    return str.gsub(/,/, " ").gsub(/[^\w ]/,"").downcase.split unless str.nil?
    nil
  end

end
