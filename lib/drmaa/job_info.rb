module DRMAA
# const char *drmaa_strerror(int drmaa_errno)
# DRMAA job info as returned by drmaa_wait()
class JobInfo
  attr_reader :job
  def initialize(job, stat, rusage = nil)
      @job = job
      @stat = stat.read_int
      @rusage = Hash.new

      if ! rusage.nil?
          DRMAA.get_attr_values(rusage).each { |u|
              nv = u.scan(/[^=][^=]*/)
              @rusage[nv[0]] = nv[1]
          }
      end
  end
  def wifaborted?  
      DRMAA.wifaborted(@stat) 
  end
  # true if job finished and exit status available
  def wifexited?  
      DRMAA.wifexited(@stat) 
  end
  # true if job was signaled and termination signal available
  def wifsignaled?  
      DRMAA.wifsignaled(@stat) 
  end
  # true if job core dumped
  def wcoredump?  
      DRMAA.wcoredump(@stat) 
  end
  # returns job exit status
  def wexitstatus 
      DRMAA.wexitstatus(@stat) 
  end
  # returns termination signal as string
  def wtermsig 
      DRMAA.wtermsig(@stat) 
  end
  # returns resource utilization as string array ('name=value')
  def rusage
      return @rusage
  end
end
end
