module DRMAA
# DRMAA job template as required by drmaa_run_job() and drmaa_run_bulk_jobs()
class JobTemplate
  attr_reader :ptr
  def initialize
      @ptr = DRMAA.allocate_job_template
      ObjectSpace.define_finalizer(self, self.method(:finalize).to_proc)
  end
  def finalize(id)
      # STDERR.puts "... releasing job template"
      DRMAA.delete_job_template(@ptr)
  end
  def set(name, value)
      DRMAA.set_attribute(@ptr, name, value)
  end
  def get(name)
      DRMAA.get_attribute(@ptr, name)
  end
  def vset(name, values)
      DRMAA.set_vector_attribute(@ptr, name, values)
  end
  def vget(name)
      DRMAA.get_vector_attribute(@ptr, name)
  end

  # path of the command to be started as a job
  def command=(cmd)
    set("drmaa_remote_command", cmd) 
  end
  def command()
    get("drmaa_remote_command") 
  end

  # DRMAA job category
  def category=(cat)
    set("drmaa_job_category", cat)
  end
  def category()
    set("drmaa_job_category")
  end

  # an opaque string that is interpreted by the DRM
  # refer to DRM documentation for what can be specified here
  def native=(nat)
    set("drmaa_native_specification", nat)
  end
  def native()
    get("drmaa_native_specification")
  end

  # jobs stdin path (format "[<hostname>]:<file_path>")
  def stdin=(host_path)
    set("drmaa_input_path", host_path)
  end
  def stdin()
    get("drmaa_input_path")
  end

  # jobs stdout path (format "[<hostname>]:<file_path>")
  def stdout=(host_path)
    set("drmaa_output_path", host_path)
  end
  def stdout()
    get("drmaa_output_path")
  end

  # jobs stderr path (format "[<hostname>]:<file_path>")
  def stderr=(host_path)
    set("drmaa_error_path", host_path) 
  end
  def stderr()
    get("drmaa_error_path")
  end

  # specifies which files need to be transfered	
  def transfer=(transfer)
    set("drmaa_transfer_files", transfer)
  end

  # job name
  def name=(name)
    set("drmaa_job_name", name)
  end
  def name
    get("drmaa_job_name")
  end

  # jobs working directory
  def wd=(path)
      set("drmaa_wd", path)
  end
  def wd
    get("drmaa_wd")
  end

  # set jobs start time (format ""[[[[CC]YY/]MM/]DD] hh:mm[:ss] [{-|+}UU:uu])")
  def start_time=(time)
    set("drmaa_start_time", time)
  end

  # jobs can be submitted in hold state and released later-on
  def hold=(hold)
    set("drmaa_js_state", hold ? 'drmaa_hold' : 'drmaa_active')
  end

  def hold?
    get("drmaa_js_state") == "drmaa_hold"
  end

  def block_mail=(block)
    set('drmaa_block_email', block ? '1' : 0)
  end

  # join jobs stdout/stderr
  def join=(join)
    set('drmaa_join_files', join ? 'y' : 'n')
  end

  def join?()
    get('drmaa_join_files') == 'y'
  end

  # job arguments
  def arg=(argv)
      vset("drmaa_v_argv", argv)
  end
  def arg()
    vget("drmaa_v_argv")
  end

  # job environment
  def env=(env)
    vset("drmaa_v_env", env)
  end

  # mail receipants
  def mail=(mail)
    vset("drmaa_v_email", mail)
  end
end
end
