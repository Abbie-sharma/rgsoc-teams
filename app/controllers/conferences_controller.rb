class ConferencesController < ApplicationController

  private

    def conferences
      @conferences ||= Conference.ordered(sort_params).in_current_season
    end
    helper_method :conferences

    def conference
      # @conference ||= params[:id] ? Conference.find(params[:id]) : Conference.new(conference_params)
      @conference ||= params[:id] || Conference.find(params[:id])
    end
    helper_method :conference

    def sort_params
      {
        order: %w(name location starts_on).include?(params[:sort]) ? params[:sort] : nil,
        direction: %w(asc desc).include?(params[:direction]) ? params[:direction] : nil
      }
    end
end
