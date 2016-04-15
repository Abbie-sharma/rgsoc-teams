require 'forwardable'

class Rating::Table
  class Row
    extend Forwardable

    def_delegators :application, :id, :flags, :location, :team_name, :project_name, :student_name,
      :total_picks, :coaching_company, :average_skill_level, :mentor_pick, :volunteering_team?,
      :remote_team, :average_total_points

    attr_reader :names, :application, :options

    # todo: pass users, not just names
    def initialize(names, application, options)
      @names = names
      @application = application
      @options = default_options.merge options
    end

    def default_options
      { hide_flags: [] }
    end

    def ratings
      @ratings ||= names.map do |name|
        ratings = application.ratings
        ratings = ratings.excluding(options[:exclude]) unless options[:exclude].blank?
        rating = ratings.find { |rating| rating.user.name == name }
        rating || Hashr.new(value: '-')
      end
    end

    def display?
      (options[:hide_flags] & flags).empty?
    end
  end

  attr_reader :names, :rows, :order, :options

  def initialize(names, applications, options)
    @names = names # should be users / reviewers
    @options = options
    @order = options[:order].try(:to_sym) || :id #TODO: this will basically never be :id (almost everything responds to to_sym...)
    @rows = applications.map { |application| Row.new(names, application, options) }
    @rows = rows.select { |row| row.display? }
    @rows = sort(rows)
  end

  def sort(rows)
    case order = options[:order].to_sym
    when :picks
      sort_by_picks(rows).reverse
    when :average_points
      rows.sort_by { |row| row.average_total_points }.reverse
    else
      rows.sort_by(&order)
    end
  end

  def sort_by_picks(rows)
    rows.sort do |lft, rgt|
      if lft.total_picks == rgt.total_picks
        result = lft.total_rating(:mean, options) <=> rgt.total_rating(:mean, options)
        result
      else
        lft.total_picks <=> rgt.total_picks
      end
    end
  end
end
