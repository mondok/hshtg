													    __  __           __   _____ __
													   / / / /___ ______/ /_ / ___// /____ _      __
													  / /_/ / __ `/ ___/ __ \\__ \/ __/ _ \ | /| / /
													 / __  / /_/ (__  ) / / /__/ / /_/  __/ |/ |/ /
													/_/ /_/\__,_/____/_/ /_/____/\__/\___/|__/|__/
														HashStew - A Twitter Top Hashtag API
# Introduction
HashStew is a small API that serves one purpose:  return the top n hashtags on a Twitter in the last 60 seconds.  
It relies on the Twitter [sample stream firehose](https://dev.twitter.com/streaming/reference/get/statuses/sample) to retrieve data.

## Setup ##
In order to run HashStew, you need four environment variables to be set.  HashStew will also check for the presence of a `.env` file and use that if it exists.  You can copy the `sample.env` file to `.env` if you want.  The variables inside are:

	TWITTER_CONSUMER_KEY=[Twitter Consumer Key]
	TWITTER_CONSUMER_SECRET=[Twitter Consumer Secret]
 	TWITTER_ACCESS_TOKEN=[Twitter Access Token]
	TWITTER_ACCESS_TOKEN_SECRET=[Twitter Access Token Secret]
