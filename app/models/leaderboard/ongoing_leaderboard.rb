class OngoingLeaderboard < SqlView
  self.primary_key = :id
  after_initialize :readonly!

  include PolymorphicSubmitter
  belongs_to :challenge

  default_scope { order(seq: :asc) }
  scope :top_three_winners, -> { order(score: :desc).first(3) }
end
