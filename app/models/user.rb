class User < ApplicationRecord
  has_many :enrollments, foreign_key: :user_id
  has_many :teachers, through: :enrollments, source: :teacher
  enum kind: { student: 0, teacher: 1, student_and_teacher: 2 }
  validate :teacher_kind_validation, :student_kind_validation
  
  def self.classmates(user)
    teacher_ids = user.enrollments.pluck(:teacher_id)
    classmates = User.joins(:enrollments).where(enrollments: { teacher_id: teacher_ids })
    classmates.where.not(id: user.id)
  end
  
  private

  def teacher_kind_validation
    if kind == 'teacher' && enrolled_in_programs?
      errors.add(:kind, "can not be teacher because is studying in at least one program")
    end
  end

  def enrolled_in_programs?
    enrollments.any?
  end
  
  def student_kind_validation
    if kind == 'student' && teaching_programs.present?
      errors.add(:kind, "can not be student because is teaching in at least one program")
    end
  end
  
  def teaching_programs
    Enrollment.all.where("teacher_id = ?", self.id).present?
  end
end