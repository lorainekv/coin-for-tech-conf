require "twitter"

unless Rails.env.production?
  require "dotenv-rails"
  require "pry-rails"
end

class TwitterBot

  def twitter_client
    Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['CONSUMER_KEY']
      config.consumer_secret = ENV['CONSUMER_SECRET']
      config.access_token = ENV['ACCESS_TOKEN']
      config.access_token_secret = ENV['ACCESS_SECRET']
    end
  end

  def retweet
    unless filter(search) == nil
      post_stuff
    end
  end

  def post_stuff
    @filtered_results.each do |tweet|
      begin
        twitter_client.retweet(tweet)
      rescue Twitter::Error # Lazy guard clause
        # Try to retweet the next tweet if there's a Twitter gem error
        next
      end
    end
  end

  # def cron_test
  #   rando_string = (0...8).map { (65 + rand(26)).chr }.join
  #   @post = twitter_client.update(rando_string)
  # end

  def search
    # Snag the five most recent relevant tweets
    first_search = twitter_client.search("conference OR conf apply OR win tech OR technology scholarship -filter:retweets -filter:mentions").take(5)
    second_search = twitter_client.search("conference OR conf tech OR technology free OR reduced ticket OR admission -filter:retweets -filter:mentions").take(5)
    third_search = twitter_client.search("from:diversity_conf scholarship").take(5)

    @search_results = first_search + second_search + third_search
  end

  def filter(results)

    duplicates = []
    uniques = []
    percentages = []

    # Comparisons can't happen with less than two results
    until @search_results.length <= 1

      # Compare the first tweet to all results
      for i in 1...@search_results.length
        check = (@search_results.first.text).similar(@search_results[i].text)
        percentages << check
      end

      # Sort the first tweet based on % similarity
      if percentages.max > 80
        duplicates << @search_results.shift
      else
        uniques << @search_results.shift
      end

      # Reset the percentages for the next iteration
      percentages = []
    end

    #Filtering that one leftover tweet
    uniques.each do |unique|
      unless @search_results.length == 0
        check = (@search_results.first.text).similar(unique.text)
        if check > 80
          duplicates << @search_results.shift
        end
      end
    end

    uniques << @search_results.shift

    @filtered_results = uniques
  end
end