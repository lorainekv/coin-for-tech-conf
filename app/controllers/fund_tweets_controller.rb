class FundTweetsController < ApplicationController

  def search
    @search_results = twitter_client.search("tech conference scholarship").take(1)
    render json: {}
  end
end
