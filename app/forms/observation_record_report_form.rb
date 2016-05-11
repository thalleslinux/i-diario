class ObservationRecordReportForm
  include ActiveModel::Model
  include I18n::Alchemy

  localize :start_at, using: :date
  localize :end_at, using: :date

  attr_accessor(
    :teacher_id,
    :unity_id,
    :classroom_id,
    :discipline_id,
    :start_at,
    :end_at
  )

  validates :teacher_id, presence: true
  validates :unity_id, presence: true
  validates :classroom_id, presence: true
  validates :discipline_id, presence: true, if: :require_discipline?
  validates :discipline_id, absence: true, unless: :require_discipline?
  validates(
    :start_at,
    presence: true,
    date: { less_than_or_equal_to: :end_at, not_in_future: true }
  )
  validates(
    :end_at,
    presence: true,
    date: { greater_than_or_equal_to: :start_at, not_in_future: true }
  )
  validates :observation_diary_records, presence: true, if: :require_observation_diary_records?

  def teacher
    return unless teacher_id.present?
    @teacher ||= Teacher.find(teacher_id)
  end

  def unity
    return unless unity_id.present?
    @unity ||= Unity.find(unity_id)
  end

  def classroom
    return unless classroom_id.present?
    @classroom ||= Classroom.find(classroom_id)
  end

  def discipline
    return unless discipline_id.present?
    @discipline ||= Discipline.find(discipline_id)
  end

  def observation_diary_records
    @observation_diary_records ||= query.observation_diary_records
  end

  def show_records_not_found_message?
    errors[:observation_diary_records].any?
  end

  def records_not_found_message
    errors[:observation_diary_records].first
  end

  private

  def query
    @query ||= ObservationRecordReportQuery.new(
      teacher_id,
      classroom_id,
      discipline_id,
      start_at,
      end_at
    )
  end

  def require_discipline?
    return unless classroom_id.present? && teacher_id.present?

    FrequencyTypeResolver.new(classroom, teacher).by_discipline?
  end

  def require_observation_diary_records?
    errors.blank?
  end
end
