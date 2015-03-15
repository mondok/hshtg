# Public: Extracts hashtags from a blob of text.  It's two primary functions
# are to extract a tag list ordered by
# most mentions to least, and the other function is to simply use a regular
# expression to extract hashtags.
module Hshtg
  module Stream
    class HashtagExtractor
      class << self

        # Public: Extract the top [size] tags from tag_list
        #
        # tag_list - array of Hashtag
        # size - integer of results to return
        # match_case - boolean for grouping with or without sensitivity to case
        #
        # Examples
        #
        #  HashtagExtractor.extract_tags!(tags, 10, true)
        #
        # returns array of HashtagResult
        def extract_tags!(tag_list, size, match_case)
          return [] unless tag_list
          tag_list
              .group_by { |t| t.grouping_tag(match_case) }
              .collect { |key, values| Models::HashtagResult.new(key, values.count) }
              .sort_by(&:count)
              .reverse.first(size)
        end

        # Public: Extract the hashtags from a blob of text
        # Credit for the regex from http://stackoverflow.com/questions/12102746/regex-to-match-hashtags-in-a-sentence-using-ruby
        #
        # content - string blob of text
        #
        # Example
        #
        #  HashtagExtractor.hash_tags_from_tweet('here is a #tweet')
        #
        # returns array of Hashtag
        def hash_tags_from_tweet(content)
          return [] unless content
          content
              .scan(/(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i)
              .flatten
              .collect { |t| Models::Hashtag.new(t) }
        end

      end
    end
  end
end
