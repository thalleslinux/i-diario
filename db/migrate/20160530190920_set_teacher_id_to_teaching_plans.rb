class SetTeacherIdToTeachingPlans < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE teaching_plans
         SET teacher_id = (SELECT teacher_id
                             FROM users
                            WHERE id = (SELECT audits.user_id
                                    FROM audits
                                   WHERE audits.auditable_type = 'TeachingPlan'
                                     AND audits.action = 'create'
                                     AND audits.auditable_id = teaching_plans.id));
    SQL
  end
end