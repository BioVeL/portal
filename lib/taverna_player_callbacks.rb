
def player_post_run_callback(run)
  now = DateTime.now
  running_time = run.finish_time - run.start_time

  update_biovel_user_statistics(run.user, run.workflow, now)
  update_biovel_workflow_statistics(run.workflow, running_time, now)
end

def update_biovel_user_statistics(user, workflow, now)
  if user.nil?
    user_statistic = UserStatistic.find_or_create_by_id(0)
  else
    user_statistic = user.user_statistic
  end

  user_statistic.run_count += 1

  user_statistic.first_run_date = now if user_statistic.first_run_date.blank?
  user_statistic.last_run_date = now

  months_running =
    ((user_statistic.last_run_date - user_statistic.first_run_date).to_i) /
      (60 * 60 * 24 * 30)

  months_running = 1 if months_running < 1

  user_statistic.latest_workflow_id = workflow.id
  user_statistic.mothly_run_average = user_statistic.run_count / months_running
  user_statistic.save
end

def update_biovel_workflow_statistics(workflow, running_time, now)
  prev_run_count = workflow.run_count
  prev_avg_run = workflow.average_run
  workflow.average_run = ((prev_run_count * prev_avg_run) + running_time ) /
                       (prev_run_count + 1)

  workflow.run_count += 1

  if (workflow.fastest_run == 0.0) || (workflow.fastest_run > running_time)
    workflow.fastest_run_date = now
    workflow.fastest_run = running_time
  end

  if workflow.slowest_run < running_time
    workflow.slowest_run_date = now
    workflow.slowest_run = running_time
  end

  workflow.save
end
