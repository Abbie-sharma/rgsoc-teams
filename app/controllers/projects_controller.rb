class ProjectsController < ApplicationController

  before_action :login_required, only: [:new]
  before_action :check_date!, only: [:new, :create]

  def new
    @project = Project.new(
      mentor_name: current_user.name,
      mentor_github_handle: current_user.github_handle,
      mentor_email: current_user.email
    )
  end

  def show
    @project = Project.find params[:id]
  end

  def edit
    project
    render :new
  end

  def index
    @projects = Project.current
  end

  def destroy
    project.destroy
    redirect_to projects_path, notice: 'Project was successfully deleted'
  end

  def create
    @project = Project.new(project_params)

    @project.submitter = current_user
    @project.season = Season.transition? ? Season.succ : Season.current
    respond_to do |format|
      if @project.save
        ProjectMailer.proposal(@project).deliver_later
        format.html { redirect_to projects_path, notice: 'Project was successfully submitted.' }
      else
        format.html { render action: :new }
      end
    end
  end

  def update
    respond_to do |format|
      if project.update_attributes(project_params)
        format.html { redirect_to projects_path, notice: 'Project was successfully updated.' }
      else
        format.html { render action: :new }
      end
    end
  end

  private

  def check_date!
    redirect_to root_path, alert: 'Project submissions are closed.' and return \
      unless Season.projects_proposable?
  end

  def project
    @project ||= Project.where(submitter_id: current_user.id).find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :name, :mentor_name, :mentor_github_handle, :mentor_email,
      :url, :description, :issues_and_features, :beginner_friendly,
      :taglist
    )
  end
end
