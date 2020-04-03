require 'rails_helper'

describe ChallengeRounds::CreateLeaderboardsService do
  subject { described_class.new(challenge_round: challenge_round, meta_challenge_id: meta_challenge_id) }

  let(:challenge_round) { create(:challenge_round, score_precision: 3, score_secondary_precision: 3) }
  let(:challenge)       { challenge_round.challenge }

  describe '#call' do
    context 'when meta_challenge_id is not provided' do
      let(:meta_challenge_id) { nil }

      context 'when challenge_round doesn\'t have submissions' do
        let!(:base_leaderboard) { create_list(:base_leaderboard, 3, challenge_round: challenge_round, leaderboard_type: :leaderboard) }

        it 'removes all previous challenge_round leaderboards records' do
          expect(challenge_round.leaderboards.count).to eq 3

          result = subject.call

          expect(result).to be_success
          expect(challenge_round.leaderboards.count).to eq 0
        end
      end

      context 'when challenge_round has current_time submissions' do
        let(:participant)               { create(:participant) }
        let(:team_participant)          { create(:participant) }
        let(:team_participant_2)        { create(:participant) }

        let!(:team)                     { create(:team, participants: [team_participant], challenge: challenge) }
        let!(:team_2)                   { create(:team, participants: [team_participant_2], challenge: challenge) }

        let!(:team_submission)          { create(:submission, :graded, score: 2, score_display: 2, participant: team_participant, challenge: challenge, challenge_round: challenge_round) }
        let!(:team_submission_2)        { create(:submission, :graded, score: 3, score_display: 3, participant: team_participant, challenge: challenge, challenge_round: challenge_round) }
        let!(:team_submission_3)        { create(:submission, :graded, score: 1, score_display: 1, participant: team_participant_2, challenge: challenge, challenge_round: challenge_round) }

        let!(:participant_submission)   { create(:submission, :graded, score: 5, score_display: 5, participant: participant, challenge: challenge, challenge_round: challenge_round) }
        let!(:participant_submission_2) { create(:submission, :graded, score: 4, score_display: 4, participant: participant, challenge: challenge, challenge_round: challenge_round) }
        let!(:migration_submission)     { create(:migration_mapping, source: create(:submission, :graded, score_display: 6, participant: nil, challenge: challenge, challenge_round: challenge_round)) }

        let!(:other_team_participant)   { create(:participant) }
        let!(:other_team)               { create(:team, participants: [other_team_participant]) }
        let!(:other_submission)         { create(:submission, :graded, participant: other_team_participant) }

        it 'creates leaderboards records for teams, participants and migration_mappings' do
          result = subject.call

          expect(result).to be_success
        end
      end

      context 'when challenge_round has submissions from previous ranking window' do
        let(:challenge_round) { create(:challenge_round, ranking_window: 6, score_precision: 3,  score_secondary_precision: 3) }
        let(:participant_1)   { create(:participant) }
        let(:participant_2)   { create(:participant) }
        let(:participant_3)   { create(:participant) }

        let!(:participant_1_submission)   { create(:submission, :graded, score: 4, score_display: 4, created_at: Time.current, participant: participant_1, challenge: challenge, challenge_round: challenge_round) }
        let!(:participant_1_submission_2) { create(:submission, :graded, score: 3, score_display: 3, created_at: Time.current - 12.hours, participant: participant_1, challenge: challenge, challenge_round: challenge_round) }

        let!(:participant_2_submission)   { create(:submission, :graded, score: 5, score_display: 5, created_at: Time.current, participant: participant_2, challenge: challenge, challenge_round: challenge_round) }
        let!(:participant_2_submission_2) { create(:submission, :graded, score: 1, score_display: 1, created_at: Time.current - 12.hours, participant: participant_2, challenge: challenge, challenge_round: challenge_round) }

        let!(:participant_3_submission)   { create(:submission, :graded, score: 6, score_display: 6, created_at: Time.current, participant: participant_3, challenge: challenge, challenge_round: challenge_round) }
        let!(:participant_3_submission_2) { create(:submission, :graded, score: 2, score_display: 2, created_at: Time.current - 12.hours, participant: participant_3, challenge: challenge, challenge_round: challenge_round) }

        it 'creates leaderboards records with previous_row_num present' do
          result = subject.call

          expect(result).to be_success

          ranking_changes = BaseLeaderboard.leaderboards.pluck(:row_num, :previous_row_num)

          expect(ranking_changes.size).to eq 3
          expect(ranking_changes).to eq [[1, 3], [2, 1], [3, 2]]
        end
      end

      context 'when challenge_round has baseline submissions' do
        let(:participant_1) { create(:participant) }
        let(:participant_2) { create(:participant) }

        let!(:participant_1_submission)   { create(:submission, :graded, baseline: false, score: 3, score_display: 4, created_at: Time.current, participant: participant_1, challenge: challenge, challenge_round: challenge_round) }
        let!(:participant_1_submission_2) { create(:submission, :graded, baseline: true, score: 4, score_display: 3, created_at: Time.current, participant: participant_1, challenge: challenge, challenge_round: challenge_round) }

        let!(:participant_2_submission)   { create(:submission, :graded, baseline: false, score: 5, score_display: 5, created_at: Time.current, participant: participant_2, challenge: challenge, challenge_round: challenge_round) }
        let!(:participant_2_submission_2) { create(:submission, :graded, baseline: true, score: 1, score_display: 1, created_at: Time.current - 12.hours, participant: participant_2, challenge: challenge, challenge_round: challenge_round) }

        it 'creates baseline leaderbords records along standard leaderboards records' do
          result = subject.call

          expect(result).to be_success

          sequence_and_row_numbers = BaseLeaderboard.leaderboards.pluck(:seq, :row_num)

          expect(sequence_and_row_numbers.size).to eq 4
          expect(sequence_and_row_numbers).to eq [[1, 0], [2, 1], [3, 0], [4, 2]]
        end
      end
    end
  end
end
