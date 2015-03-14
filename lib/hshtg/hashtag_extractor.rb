# Extracts hashtags from a blob of text.  It's two primary functions
# are to extract a tag list ordered by
# most mentions to least, and the other function is to simply use a regular
# expression to extract hashtags.
module Hshtg
  class HashtagExtractor
    class << self

      # Extract the top [size] tags from tag_list
      # tag_list should be an array of Hashtag
      def extract_tags!(tag_list, size, match_case)
        return [] unless tag_list
        tag_list
            .group_by { |t| t.grouping_tag(match_case) }
            .collect { |key, values| Hshtg::Models::HashtagResult.new(key, values.count) }
            .sort_by(&:count)
            .reverse.first(size)
      end

      # Extract the hashtags from a blob of text
      # Credit for the regex from http://stackoverflow.com/questions/12102746/regex-to-match-hashtags-in-a-sentence-using-ruby
      def hash_tags_from_tweet(tweet)
        return [] unless tweet
        tweet
            .scan(/(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i)
            .flatten
            .collect { |t| Hshtg::Models::Hashtag.new(t) }
      end

    end
  end
end
