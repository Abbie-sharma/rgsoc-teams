class Project < ActiveRecord::Base

  include HasSeason

  belongs_to :submitter, class_name: 'User'
  has_many :comments, -> { order('created_at DESC') }, dependent: :destroy

  validates :name, :submitter, :mentor_email, presence: true

  scope :current, -> do
    where(season: Season.transition? ? Season.succ : Season.current)
  end

  include AASM

  aasm whiny_transitions: false do
    state :proposed, initial: true
    state :accepted
    state :rejected

    event :accept do
      transitions from: :proposed, to: :accepted
    end

    event :reject do
      transitions from: :proposed, to: :rejected, after: -> { self.comments_locked = true }
    end
  end

  def taglist
    tags.join(', ')
  end

  def taglist=(taglist)
    self.tags = taglist.split(',').map(&:strip).reject(&:blank?)
  end

  def subscribers
    [submitter, mentor, comments.map(&:user)].flatten.uniq
  end

  # FIXME Remove me after https://github.com/rails-girls-summer-of-code/rgsoc-teams/issues/342
  class NullMentor
    attr_reader :email, :github_handle
    def initialize(project)
      @email = project.mentor_email.to_s.downcase
      @github_handle = project.mentor_github_handle.to_s.downcase
    end
    def eql?(user)
      user.github_handle.to_s.downcase == github_handle
    end
  end

  def mentor
    @mentor ||= begin
                  _mentor = NullMentor.new(self)
                  if _mentor.eql? submitter
                    submitter
                  else
                    _mentor
                  end
                end
  end
end
