# Controls the classrooms that are within the Head Start schools.
class ClassroomsController < ApplicationController
  before_filter :require_user
  before_filter :require_admin, except: [:index, :show]

  def index
    @classroom = Classroom.all
  end

  def show
    @classroom = Classroom.find(params[:id])
    @students = Student.all
  end

  def new
    @classroom = Classroom.new
  end

  def edit
    @classroom = Classroom.find(params[:id])
  end

  def create
    @classroom = Classroom.new(params[:classroom])
    if @classroom.save
      flash[:notice] = 'Classroom was successfully created.'
      redirect_to @classroom
    else
      flash[:notice] = 'There was a problem creating the classroom.'
      render action: :new
    end
  end

  def destroy
    Classroom.find(params[:id]).destroy
    flash[:notice] = 'Classroom deleted.'
    redirect_to '/classrooms'
  end
end
