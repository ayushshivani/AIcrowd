class PracticesController < ApplicationController
  before_action :set_filters, only: [:index]

  respond_to :html, :js

  def index
    @all_challenges      = policy_scope(Challenge)
    @practice_challenges = @all_challenges.practice.page
    @practice_challenges = Challenges::FilterService.new(params, @practice_challenges).call
    @challenges          = @all_challenges.not_practice.page(params[:page]).per(18)
  end

  private

  def set_filters
    @categories = Category.all
    @status     = challenge_status
    @prize_hash = { prize_cash:     'Cash prizes',
                    prize_travel:   'Travel grants',
                    prize_academic: 'Academic papers',
                    prize_misc:     'Misc prizes' }
  end

  def challenge_status
    params[:controller] == "landing_page" ? Challenge.statuses.keys - ['draft'] : Challenge.statuses.keys
  end
end