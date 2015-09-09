class FundTweetsController < ApplicationController

  def search
    ## Since this will be automated, I'm going to just snag a single result at
    ## a time in an attempt to focus on quality of the retweet vs quantity.
    @search_results = twitter_client.search("tech conference scholarship").take(1)
    render json: @search_results
  end

  def retweet
    # Snag the search results
    search
    # Retweet
    @search_results.each do |tweet|
      begin
        twitter_client.retweet(tweet)
      rescue Twitter::Error # Lazy guard clause
        # Try to retweet the next tweet if there's a Twitter gem error
        next
      end
    end
  end

  def cron_test
    rando_string = (0...8).map { (65 + rand(26)).chr }.join
    @post = twitter_client.update(rando_string)
    render json: {}
  end

end
