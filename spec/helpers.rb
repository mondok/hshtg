module Helpers
  def hashtag_list
    [
        Hshtg::Models::Hashtag.new('one'),
        Hshtg::Models::Hashtag.new('one'),
        Hshtg::Models::Hashtag.new('two'),
        Hshtg::Models::Hashtag.new('three')
    ]
  end

  def build_hashtag(tag_text)
    Hshtg::Models::Hashtag.new(tag_text)
  end
end
