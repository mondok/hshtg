```
									   _  _    __    __       _______. __    __  .___________.  _______ 
									 _| || |_ |  |  |  |     /       ||  |  |  | |           | /  _____|
									|_  __  _||  |__|  |    |   (----`|  |__|  | `---|  |----`|  |  __  
									 _| || |_ |   __   |     \   \    |   __   |     |  |     |  | |_ | 
									|_  __  _||  |  |  | .----)   |   |  |  |  |     |  |     |  |__| | 
									  |_||_|  |__|  |__| |_______/    |__|  |__|     |__|      \______|

														Hshtg - A Twitter Top Hashtag API
```
# Introduction 
Hshtg is a small API that serves one purpose:  return the top n hashtags on a Twitter in the last 60 seconds.  It relies on the Twitter [sample stream firehose](https://dev.twitter.com/streaming/reference/get/statuses/sample) to retrieve data.

# Running

## Setup 
In order to run Hshtg, you need four environment variables to be set.  Hshtg will also check for the presence of a `.env` file and use that if it exists.  You can copy the `sample.env` file to `.env` if you want.  The variables inside are:

```
TWITTER_CONSUMER_KEY=[Twitter Consumer Key]
TWITTER_CONSUMER_SECRET=[Twitter Consumer Secret]
TWITTER_ACCESS_TOKEN=[Twitter Access Token]
TWITTER_ACCESS_TOKEN_SECRET=[Twitter Access Token Secret]
```

You can get these credentials by creating a new [Twitter application](https://apps.twitter.com/) then going under the "Keys and Access Tokens" area to generate the required keys.

## Running the Server
First checkout this repository to your local machine.  Next, run `bundle install` to install any dependencies. To run the API, simply execute `ruby hshtg.rb`.  The default port is 3000.  Case sensitive matching is off by default.

To summarize:

```
bundle install
ruby hshtg.rb
```

All startup options are:

```
Usage: hshtg.rb [options]
	-f, --file [settings.yml]	use a yaml file to load settings - if other command line values are set, they will override the file values
	-c, --case [0]   			case sensitivity (0 or 1), 1 for sensitive which means tags will be grouped separately if they are cased differently
	-s, --store [in-memory]  	type of backend storage for storing hashtags (in-memory or redis)
	-t, --ttl [60]   			tags time to live before they are not counted
	-p, --port [3000]			server port to listen on
	-h, --help   				displays help
```

Alternatively, you can also set these settings in the `settings.yml` file at the root or pass in your own yaml file.

The feed itself will be available at `http://localhost:3000/top10` and it returns a JSON payload.  If you'd like to return more than the top ten, simply alter the endpoint to a greater (or lesser) number.  For example, `http://localhost:3000/top100` will return the top 100 hashtags.

### Quick Note on Case
When referring to case, if case sensitivity is on then #tag and #Tag will be treated as two different hashtags.  If it is off, #tag and #Tag will be treated as a single hashtag.

## Endpoints 
The following endpoints are available:

```
/       GET     Landing page.
/       HEAD    Used for automated health check.  Send HEAD request to the root.  Status of system is return in Status HTTP response header.  Possibilities are 'up' or 'down'.
/topX   GET     X is a positive integer.  Returns JSON of most popular hashtags on Twitter in JSON format.  Example is /top10.
/health GET     Healthcheck page that returns basic health of system.
/live   GET     HTML sample page that consumes the API and shows the top tags.
```

## Signaling
Certain unix signals can be sent to the service.  These signals include (9999 is PID):

* HUP - Restarts the hashtag stream, i.e. `kill -1 9999`
* INT/TERM - Immediately kills the server, i.e. `kill -2 9999`
* QUIT - Gracefully closes the hashtag stream and exits, i.e. `kill -3 9999`

## Storage
By default, the API uses an in-memory store for hashtags.  The API also ships with an optional Redis store driver that can be used as well.  If you wish to use Redis, uncomment redis in the Gemfile, bundle install, and pass `-s redis` in the startup args.


## Running the Tests
First, make sure RSpec is installed with:
```
bundle install --binstubs
```

To run the unit tests, run:
```
./bin/rspec
```

To run the integration tests, run:
```
./bin/rspec spec/integration_spec.rb
```