# frozen_string_literal: true
class Rating::Strictness

  def ratings
    @ratings ||= Rating
                  .joins('JOIN applications ON ratings.rateable_id = applications.id')
                  .where(rateable_type: 'Application')
                  .where('applications.season_id' => Season.current.id)
  end

  def application_ids
    @application_ids ||= ratings.map(&:rateable_id)
  end

  def applications
    @applications ||= Application.includes(:ratings).where(id: application_ids)
  end

  def reviewer_ids
    @reviewer_ids ||= ratings.map(&:user_id).uniq
  end

  def average_points_per_reviewer
    @average_points_per_reviewer ||= ratings.sum(&:points) / reviewer_ids.size.to_f
  end

  def adjusted_points_for_applications
    applications.each_with_object({}) do |application, map|
      map[application.id] = application.ratings.sum(&strictness) / application.ratings.count.to_f
    end
  end

  def strictness_per_reviewer
    @strictness_per_reviewer ||= reviewer_ids.each_with_object({}) do |id, map|
      map[id] = average_points_per_reviewer / individual_points_for_reviewer(id)
    end
  end
  alias to_h strictness_per_reviewer

  private

  def strictness
    ->(rating) { (rating.points * strictness_per_reviewer[rating.user_id]).to_f }
  end

  def individual_points_for_reviewer(id)
    ratings.select{|r| r.user_id == id}.sum(&:points)
  end

end
