class Leaderboard < SqlView
  self.primary_key = :id
  after_initialize :readonly!

  include PolymorphicSubmitter
  belongs_to :challenge
  belongs_to :challenge_round
  belongs_to :submission

  default_scope { order(seq: :asc) }
  scope :top_three_winners, -> { order(score: :desc).first(3) }
end
