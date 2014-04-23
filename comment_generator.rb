# comment_generator.rb
# Authors: Jeffrey Klein and James Smith

module CommentGenerator
  # extract data from response and format into comment string
  def self.generate_comment(response_object, video_url = nil)
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
        description: video.snippet.description[0...1000],
        thumbnail_url: video.snippet.thumbnails.high.url,
        duration: video.content_details.duration,
        view_count: video.statistics.view_count,
        like_count: video.statistics.like_count,
        dislike_count: video.statistics.dislike_count,
        favorite_count: video.statistics.favorite_count,
      }
    rescue NoMethodError => err
      puts "Error accessing attribute \"#{err.name}\""
      return nil
    end
    return format_comment data
  end

  private

  # helper method to format data into neat comment according to Reddit's markdown guidelines
  def self.format_comment(data)
    return nil if data.nil?
    comment = "#*^^some ^^brief ^^info ^^about ^^this ^^video:*\n\n"
    # title and thumbnail preview
    comment += "###[#{data[:title]}](#{data[:url]})"
    comment += "[*^^^\\[thumbnail ^^^preview\\]*](#{data[:thumbnail_url]})\n\n"
    # upload time and channel info
    comment += "#*^Uploaded ^on ^#{data[:publish_date]} ^at ^#{data[:publish_time]} "
    comment += "^to ^channel:* [**^#{data[:channel_title].split.join(" ^")}**](#{data[:channel_url]})\n\n"
    # duration, views, like %, favorites
    comment += "*Duration:* **#{format_duration data[:duration]}**\n\n"
    comment += "# *Views:* **#{data[:view_count].to_s.reverse.scan(/\d{1,3}/).join(",").reverse}**\n\n"
    if (data[:like_count] + data[:dislike_count]) > 0
      comment += "# **#{((data[:like_count].to_f/(data[:like_count]+data[:dislike_count]))*100).to_i}%** "
      comment += "*of YouTube voters liked this video, with* **#{data[:favorite_count]}** *favorites*\n\n"
    else
      comment += "# *No one has liked or disliked this video on YouTube yet*\n\n"
    end
    # video description
    comment += "*Video Description:*\n"
    comment += ">#{data[:description].split("\n").join("\n>\n>")}"
    return comment
  end

  # helper method to format YouTube's duration string format into mm:ss form
  def self.format_duration(string)
    string.gsub!(/[PTMS]/, "PT" => "", "M" => ":", "S" => "")
    string = "0:" + string unless string.include?(":")
    string.insert(-2,"0") if string[-2] == ":"
    return string
  end

end

