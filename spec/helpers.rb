module Helpers
  def hashtag_list
    [
      Hshtg::Models::Hashtag.new('one'),
      Hshtg::Models::Hashtag.new('one'),
      Hshtg::Models::Hashtag.new('two'),
      Hshtg::Models::Hashtag.new('three')
    ]
  end
end
