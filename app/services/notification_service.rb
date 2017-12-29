class NotificationService
  include Rails.application.routes.url_helpers

  def initialize(participant_id, notifiable, notification_type)
    @participant = Participant.find(participant_id)
    @notifiable = notifiable
    @notification_type = notification_type
  end

  def call
    eval(@notification_type)
  end

  def comment
    message = "#{@notifiable.participant.name} commented on a discussion thread you are participating in."
    thumbnail_url = ApplicationController.helpers.image_url(@notifiable.participant)
    notification_url = new_topic_discussion_path(@notifiable.topic)
    Notification
      .create!(
        participant: @participant,
        notifiable: @notifiable,
        notification_type: @notification_type,
        message: message,
        thumbnail_url: thumbnail_url,
        notification_url: notification_url,
        is_new: true)
    return true
  end

  def mention
    message = "#{@notifiable.participant.name} mentioned you in a post."
    thumb = image_url(@notifiable.participant)
    link = new_topic_discussion_path(@notifiable.topic)
  end

  def graded
    message = "Your Learning how to walk submission has been graded with a score of 1233"
    thumb = image_url(@notifiable.challenge)
    link = challenge_url(@notifiable.challenge)
  end

  def grading_failed
    messsage = "Your Learning how to walk submission has failed grading"
    thumb = image_url(@notifiable.challenge)
    link = challenge_url(@notifiable.challenge)
  end

  def leaderboard
    message = "You moved from 3rd to 5th place on the Learning how to walk leaderboard"
    thumb = image_url(@notifiable.challenge)
    link = challenge_url(@notifiable.challenge)
  end

end
