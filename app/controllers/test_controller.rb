class TestController < ApplicationController
  def loop
    job_checking_polling_time = params.fetch(:job_checking_polling_time, 5).to_f # seconds
    max_poll_time_until_redirect = params.fetch(:max_poll_time_until_redirect, 20).to_i #seconds
    maximum_iterations = params.fetch(:maximum_iterations, 30).to_i
    redirect_again = true
    iteration_start_time = Time.now
    params[:never_complete] ||= "false"

    job_identifier = build_or_fetch_job
    poll_iteration = params[:iteration].to_i + 1

    if never_complete? || poll_iteration <= maximum_iterations
      Rails.logger.info("We're into another poll iteration")

      while (Time.now - iteration_start_time) < max_poll_time_until_redirect
        if !job_done?(job_identifier)
          sleep(job_checking_polling_time)
          redirect_again = true
        else
          render(json: {status: :success, job_id: job_identifier, message: "Took #{poll_iteration} iteration. And we were successful"})
          redirect_again = false
          break
        end
      end

      redirect_to(action: :loop, iteration: poll_iteration,
                                 job_id: job_identifier,
                                 job_checking_polling_time: job_checking_polling_time,
                                 max_poll_time_until_redirect: max_poll_time_until_redirect,
                                 maximum_iterations: maximum_iterations,
                                 never_complete: never_complete?) if redirect_again
    else
      render json: {status: :failure, job_id: job_identifier, message: "Got to iteration #{poll_iteration}. Too many iterations"}
    end
  end

  private

    def build_or_fetch_job
      params[:job_id] ||= build_job
    end

    def build_job
      SecureRandom.hex(32)
    end

    def never_complete?
      params[:never_complete] == "true"
    end

    # This would be checking in Sidekiq whether the job is still queued or in progress
    def job_done?(identifier)
      v = if never_complete?
            0
          else
            rand(100)
          end

      Rails.logger.info("job_done? #{v} == 50?")
      v == 50
    end
end
