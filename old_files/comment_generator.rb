# comment_generator.rb
# Authors: Jeffrey Klein and James Smith

module CommentGenerator
  # method to format data hash into neat comment according to Reddit's markdown guidelines
  def self.generate_comment(data)
    return nil if data.nil?
    comment = "#*^^some ^^brief ^^info ^^about ^^this ^^video:*\n\n"
    # title and thumbnail preview
    comment += "###[#{data[:title]}](#{data[:url]})"
    comment += "[*^^^\\[thumbnail ^^^preview\\]*](#{data[:thumbnail_url]})\n\n"
    # upload time and channel info
    comment += "#*^Uploaded ^on ^#{data[:publish_date].split.join(" ^")} "
    comment += "^to ^channel:* [**^#{data[:channel_title].split.join(" ^")}**](#{data[:channel_url]})\n\n"
    # duration, views, like %, favorites
    comment += "*Duration:* **#{data[:duration]}**\n\n"
    comment += "# *Views:* **#{data[:view_count]}**\n\n"
    if (data[:like_count].to_i + data[:dislike_count].to_i) > 0
      comment += "# **#{((data[:like_count].to_i.to_f/(data[:like_count].to_i+data[:dislike_count].to_i))*100).to_i}%** "
      comment += "*of YouTube voters liked this video*\n\n"
    else
      comment += "# *No one has liked or disliked this video on YouTube yet*\n\n"
    end
    # video description
    comment += "*Video Description:*\n"
    comment += ">#{data[:description].split("\n").join("\n>\n>")}"
    return comment
  end

end

