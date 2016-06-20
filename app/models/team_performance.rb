class TeamPerformance
# Memo: calculates Team's Performance Score for Supervisor's Dashboard

  def initialize(team)
    @team = team
    @score = 0
  end

  def evaluation
    comments_score
    activity_score

    if @score > 3
      @performance = :red
    elsif @score >= 2
      @performance = :orange
    elsif @score == 0
      @performance = :green
    else
      @performance = :orange
    end
  end

  private

  def self.buffer_days?
    # the first few days, plus the days before and after the coding season
    Time.now < Season.current.starts_at+2.days || !Season.current.started? || Time.now > Season.current.ends_at+2.days
  end

  def comments_score
    latest_comment = @team.comments.ordered.first
    if @team.comments.empty?
      @score += 3 unless self.class.buffer_days?
    elsif latest_comment.created_at <= Time.now-5.days
      @score += 2
    elsif latest_comment.created_at <= Time.now-2.days
      @score += 1
    elsif latest_comment.created_at > Time.now-2.days
      @score += 0
    else
      @score += 1
    end
  end

  def activity_score
    if @team.activities.empty?
      @score += 3 unless self.class.buffer_days?
    elsif @team.last_activity.created_at <= Time.now-5.days
      @score += 2
    elsif @team.last_activity.created_at <= Time.now-3.days
      @score += 1
    elsif @team.last_activity.created_at > Time.now-3.days
      @score += 0
    else
      @score += 1
    end
  end

end