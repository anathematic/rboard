class ReportsController < ApplicationController
  before_filter :login_required
  before_filter :find_reportable
  before_filter :already_reported
  
  def new
    @report = Report.new
  end
  
  def create
    @report = @reportable.reports.build(params[:report].merge!(:user => current_user))
    if @report.save
      flash[:notice] = t(:report_created)
      redirect_to_reportable
    else
      flash[:notice] = t(:report_not_created)
      render :action => "new"
    end
  end
  
  private
    def find_reportable
      if params[:post_id]
        @reportable = Post.find(params[:post_id], :include => { :topic => :posts }) if params[:post_id]
        @reportable = Topic.find(params[:topic_id]) if params[:topic_id]
        if !@reportable.forum.viewable?(current_user)
          flash[:notice] = t(:post_or_topic_not_found)
          redirect_back_or_default(root_path)
        end
      end
    end
    
    def already_reported
      if @reportable.reporters.include?(current_user)
        flash[:notice] = t(:already_reported)
        redirect_to_reportable
      end
    end
    
    def redirect_to_reportable
     if @reportable.is_a?(Topic)
        redirect_to forum_topic_path(@reportable.forum, @reportable)
      else
        redirect_to forum_topic_path(@reportable.forum,@reportable.topic) + "/#{@reportable.page_for(current_user)}" + "#post_#{@reportable.id}"
      end
    end
end
