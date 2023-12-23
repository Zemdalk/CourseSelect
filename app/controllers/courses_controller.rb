class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]#add open by qiao
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: true)
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------for students----------------------

  def list
    # -------QiaoCode--------
    # @courses = Course.where(:open=>true).paginate(page: params[:page], per_page: 5)
    # @course_unselect = @courses - current_user.courses
    user_course_ids = current_user.courses.pluck(:id)
    @course_unselect = Course.where(open: true)
                             .where.not(id: user_course_ids)
                             .paginate(page: params[:page], per_page: 4)
    # tmp=[]
    # @course_unselect.each do |course|
    #   if course.open==true
    #     tmp<<course
    #   end
    # end
    # @course_unselect=tmp
  end

  def select
    @course=Course.find_by_id(params[:id])
    current_user.courses<<@course
    flash={:suceess => "成功选择课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def search
    @courses = Course.where(open: true)
    @courses = @courses.where("course_time LIKE ?", "%#{params[:course_time]}%") if params[:course_time].present?
    @courses = @courses.where(course_type: params[:course_type]) if params[:course_type].present?
    @courses = @courses.where("name LIKE ?", "%#{params[:course_name]}%") if params[:course_name].present?
    @course_unselect = @courses.paginate(page: params[:page], per_page: 4)
    render 'list'
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  # def credit_stats
  #   @credit_require_public_compulsory = 
  # end
  def credit
    @credit_requirements = CreditRequirement.find(current_user.major_id)
    @credit_selected_public_mandatory, @credit_selected_major, @credit_selected_all = get_selected_credit()
    @credit_needed_public_mandatory = (@credit_requirements.public_mandatory_credits > @credit_selected_public_mandatory) ? (@credit_requirements.public_mandatory_credits - @credit_selected_public_mandatory) : 0
    @credit_needed_major = (@credit_requirements.major_credits > @credit_selected_major) ? (@credit_requirements.major_credits - @credit_selected_major) : 0
    @credit_needed_all = (@credit_requirements.all_credits > @credit_selected_all) ? (@credit_requirements.all_credits - @credit_selected_all) : 0
  end

  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses.paginate(page: params[:page], per_page: 4) if teacher_logged_in?
    @course=current_user.courses.paginate(page: params[:page], per_page: 4) if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end

  def get_course_credit(course_credit)
    parts = course_credit.split('/')
    return parts[1].to_f
  end

  def get_selected_credit()
    credit_public_mandatory = 0
    credit_major = 0
    credit_all = 0
    current_user.courses.each do |course|
      if course.course_type == "公共选修课"
        credit_public_mandatory += get_course_credit(course.credit)
      elsif course.course_type == "一级学科核心课" ||
            course.course_type == "一级学科普及课" ||
            course.course_type == "专业核心课" ||
            course.course_type == "专业普及课" ||
            course.course_type == "专业研讨课"
        puts "#{course.credit}"
        credit_major += get_course_credit(course.credit)
      else
        credit_all += get_course_credit(course.credit)
      end
    end
    credit_all += credit_public_mandatory + credit_major
    return credit_public_mandatory, credit_major, credit_all
  end

end