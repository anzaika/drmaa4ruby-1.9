module DRMAA
class Session
  attr_accessor :retry

  # initialize DRMAA session
  def initialize(contact = "")
    DRMAA.init(contact)
    ObjectSpace.define_finalizer(self, self.method(:finalize).to_proc)
    @retry = 0
  end

  # close DRMAA session
  def finalize(id=0)
    # STDERR.puts "... exiting DRMAA"
    DRMAA.exit
  end

  # non-zero retry interval causes DRMAA::DRMAATryLater be handled transparently  
  def retry_until
      if @retry == 0
          job = yield
      else
          begin
              job = yield
          rescue DRMAA::DRMAATryLater
              STDERR.puts "... sleeping"
              sleep @retry
              retry
          end
      end
      return job
  end

  # submits job described by JobTemplate 't' and returns job id as string
  def run(t)
      retry_until { DRMAA.run_job(t.ptr) }
  end

  # submits bulk job described by JobTemplate 't' 
  # and returns an array of job id strings
  def run_bulk(t, first, last, incr = 1)
      retry_until { DRMAA.run_bulk_jobs(t.ptr, first, last, incr) }
  end

  # wait for any job of this session and return JobInfo 
  def wait_any(timeout = -1)
      DRMAA.wait(ANY_JOB, timeout)
  end

  # wait for job and return JobInfo 
  def wait(job, timeout = -1)
      DRMAA.wait(job, timeout)
  end

  # run block with JobInfo to finish for each waited session job
  # or return JobInfo array if no block was passed
  def wait_each(timeout = -1)
      if ! block_given?
          ary = Array.new
      end
      while true
          begin
              info = DRMAA.wait(ANY_JOB, timeout)
          rescue DRMAAInvalidJobError
              break
          end
          if block_given?
              yield info
          else
              ary << info
          end
      end
      if ! block_given?
          return ary
      end
  end

  # synchronize with all session jobs and dispose any job finish information
  # returns false in case of a timeout
  def sync_all!(timeout = -1)
      DRMAA.synchronize([ ALL_JOBS ], timeout, true)
  end

  # synchronize with all session jobs
  # returns false in case of a timeout
  def sync_all(timeout = -1, dispose = false)
      DRMAA.synchronize([ ALL_JOBS ], timeout, dispose)
  end

  # synchronize with specified session jobs and dispose any job finish information
  # returns false in case of a timeout
  def sync!(jobs, timeout = -1)
      DRMAA.synchronize(jobs, timeout, true)
  end

  # synchronize with specified session jobs
  # returns false in case of a timeout
  def sync(jobs, timeout = -1)
      DRMAA.synchronize(jobs, timeout, false)
  end

  # suspend specified job or all session jobs
  def suspend(job = ALL_JOBS)
      DRMAA.control(job, DRMAA::ACTION_SUSPEND)
  end

  # resume specified job or all session jobs
  def resume(job = ALL_JOBS)
      DRMAA.control(job, DRMAA::ACTION_RESUME)
  end

  # put specified job or all session jobs in hold state
  def hold(job = ALL_JOBS)
      DRMAA.control(job, DRMAA::ACTION_HOLD)
  end

  # release hold state for specified job or all session jobs
  def release(job = ALL_JOBS)
      DRMAA.control(job, DRMAA::ACTION_RELEASE)
  end

  # terminate specified job or all session jobs
  def terminate(job = ALL_JOBS)
      DRMAA.control(job, DRMAA::ACTION_TERMINATE)
  end

  # get job state
  def job_ps(job)
      DRMAA.job_ps(job)
  end
end
end
