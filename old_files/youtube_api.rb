# youtube_access.rb
# Authors: Jeffrey Klein and James Smith

require 'google/api_client'
#require 'oauth/oauth_util'

class YouTubeAccess 
  attr_reader :access

  # initialize client
  def initialize
    #auth_util = CommandLineOAuthHelper.new("https://www.googleapis.com/auth/youtube.readonly")
    #client.authorization = auth_util.authorize()

    @client = Google::APIClient.new(
      key: "AIzaSyCO3kxkYcvX9IIT8kcDjJqMDunN9tZqwxQ",
      authorization: nil,
      application_name: "YouToobBot",
      application_version: "0.0.0"
    )
    # access api
    @access = @client.discovered_api("youtube", "v3")
    # verify connection
    unless @access.nil?
      puts "Established connection to YouTube API" 
    else
      puts "Unable to establish connection to YouTube API" 
      exit
    end
  end

  # get info about video using YouTube API
  def get_video_info(video_url)
    video_id = isolate_id video_url
    return nil if video_id.nil?
    response = @client.execute!(
      api_method: @access.videos.list,
      parameters: {
        part: "snippet,contentDetails,statistics",
        id: video_id
      }
    )
    response
  end

  private

  # helper method to isolate unique video id from URL
  def isolate_id(video_url)
    video_id = video_url[/[\?&]v=.{11}/]
    video_id = video_id[3..-1] unless video_id.nil?
    video_id
  end

end
