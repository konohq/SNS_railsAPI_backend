class Api::TasksController < ApplicationController
  
  def index
    render json: Task.all
  end

  def create
    task = Task.create!(task_params)
    render json: task
  end

  private

  def task_params
    params.require(:task).permit(:title)
  end
end