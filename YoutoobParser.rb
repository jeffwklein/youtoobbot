#require 'rubygems'
require 'fast-stemmer'
require 'open-uri'
 
class YoutoobParser
  @uri
  @data_hash
  def initialize ( uri_str )
    count      = 0
    @uri       = URI.parse(uri_str)
    @data_hash = Hash.new
    
    @uri.open {|f|
      str   = @uri.read
      
      likes_array = /"likes-count">(.*)<\/span>/.match(str)
      @data_hash['likes'] = likes_array[1]
      likes_count = likes_array[1]
      print likes_count + "\n"
      
      dislikes_array = /"dislikes-count">(.*)<\/span>/.match(str)
      @data_hash['dislikes'] = dislikes_array[1]
      dislikes_count = dislikes_array[1]
      print dislikes_count + "\n"

      family_array = /<meta itemprop="isFamilyFriendly" content="(.*)">/.match(str)
      @data_hash['family'] = family_array[1]
      family_count = family_array[1]
      print family_count + "\n"

      name_array = /data-name="watch">(.*)<\/a><span/.match(str)
      @data_hash['name'] = name_array[1]
      name_count = name_array[1]
      print name_count + "\n"
      
      title_array = /<title>(.*)<\/title>/.match(str)
      @data_hash['title'] = title_array[1]
      title_count = title_array[1]
      print title_count + "\n"

      date_array = /<span id="eow-date" class="watch-video-date" >(.*)<\/span>/.match(str)
      @data_hash['date'] = date_array[1]
      date = date_array[1]
      print date + "\n"

      desc_array = /<p id="eow-description" >(.*)<\/p>/.match(str)
      @data_hash['desc'] = desc_array[1]
      desc = desc_array[1]
      print desc + "\n"

      time_array = /<span class="video-time">(.*)<\/span><\/span>/.match(str)
      @data_hash['time'] = time_array[1]
      time = time_array[1]
      print time + "\n"

      views_array = /   (.*)\n/.match(str)
      views = views_array[0]
      view_chars = views.split(//)
      
      for ele in view_chars do
        print "-" + ele + "-\n"
      end
      
      print "-" + views + "\n"

      if(true)
        count+=1
        #print "-----" + str 
      end
    
    }
    
    print "\n\n" + count.to_s
        
  end

  def get_data()
    return @data_hash
  end
end

yp = YoutoobParser.new "https://www.youtube.com/watch?v=-vE04u94h0Y"
run = 'running'.stem
print run
