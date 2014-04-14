# comment_generator.rb
# Authors: Jeffrey Klein and James Smith

# "prettyprint" lib for nicely formatted output in testing
require 'pp'

module CommentGenerator
  def self.generate_comment(response_object, video_url=nil)
    video = response_object.data.items[0]
    return nil if video.nil?
    begin
      data = {
        title: video.snippet.title,
        url: video_url,
        publish_date: video.snippet.published_at.strftime("%m/%d/%Y"),
        publish_time: video.snippet.published_at.strftime("%I:%M%p"),
        channel_title: video.snippet.channel_title,
        channel_url: "https://www.youtube.com/channel/#{video.snippet.channel_id}",
        description: video.snippet.description[0...400],
        thumbnail_url: video.snippet.thumbnails.high.url,
        duration: video.contentDetails.durationdur.gsub(/[PTMS]/, "PT" => "", "M" => ":", "S" => ""),
        view_count: video.statistics.view_count,
        like_count: video.statistics.like_count,
        dislike_count: video.statistics.dislike_count,
        favorite_count: video.statistics.favorite_count,
        comment_count: video.statistics.comment_count
      }
    rescue NoMethodError => err
      puts "Error accessing attribute \"#{err.name}\""
      return nil
    end
    pp data
    format_comment data
  end

  private

  def self.format_comment(data)
    return nil if data.nil?
    comment = "#*^some ^brief ^info ^about ^this ^video:*\n\n"
    # title
    comment += "###[#{data[:title]}](#{data[:url]})" if data[:title] && data[:url]
    # thumbnail preview
    comment += "[^^^\\[thumbnail ^^^preview\\]](#{data[:thumbnail_url]})\n\n" if data[:thumbnail_url]
    comment += "\n\n" unless data[:thumbnail_url]
    # upload and channel info
  end

end

#     #*^some ^brief ^info ^about ^this ^video:*
#
#     ### [Drug Wars: Cannabis Vs  Nicotine](https://www.youtube.com/watch?v=yXaCZasVtZk)[^^^\[thumbnail ^^^preview\]](http://www.google.com)
#
#     #*^Uploaded ^on ^03/21/2014 ^at ^04:52AM ^to ^channel:* [**^Christopher ^Pool**](https://www.youtube.com/channel/UCsBPXkfF3J3uCRzl012r8dA)
#
#     # *Duration:* **2:13**
#
#     # *Views:* **67,745**
#
#     # **82%** *of YouTube voters liked this video, with*  **0** *favorites.*
#
#     *Video Description:*
#     >ChrisPoool.com
#     >
#     >https://twitter.com/ChrisPoool
#     >
#     >Music - Dark Fog by Kevin MacLeod
#


