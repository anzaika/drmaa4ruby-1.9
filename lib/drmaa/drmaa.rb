#!/usr/bin/ruby

#########################################################################
#
#  The Contents of this file are made available subject to the terms of
#  the Sun Industry Standards Source License Version 1.2
#
#  Sun Microsystems Inc., March, 2006
#
#
#  Sun Industry Standards Source License Version 1.2
#  =================================================
#  The contents of this file are subject to the Sun Industry Standards
#  Source License Version 1.2 (the "License"); You may not use this file
#  except in compliance with the License. You may obtain a copy of the
#  License at http://gridengine.sunsource.net/Gridengine_SISSL_license.html
#
#  Software provided under this License is provided on an "AS IS" basis,
#  WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
#  WITHOUT LIMITATION, WARRANTIES THAT THE SOFTWARE IS FREE OF DEFECTS,
#  MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE, OR NON-INFRINGING.
#  See the License for the specific provisions governing your rights and
#  obligations concerning the Software.
#
#   The Initial Developer of the Original Code is: Sun Microsystems, Inc.
#
#   Copyright: 2006 by Sun Microsystems, Inc.
#
#   All Rights Reserved.
#
#########################################################################
#
#
#    Ruby 1.9 version of DRMAA wrapper
#
#
#

require 'pp'

module DRMAA
  class DRMAAException < StandardError ; end
  class DRMAAInternalError < DRMAAException ; end
  class DRMAACommunicationError < DRMAAException ; end
  class DRMAAAuthenticationError < DRMAAException ; end
  class DRMAAInvalidArgumentError < DRMAAException ; end
  class DRMAANoActiveSessionError < DRMAAException ; end
  class DRMAANoMemoryError < DRMAAException ; end
  class DRMAAInvalidContactError < DRMAAException ; end
  class DRMAADefaultContactError < DRMAAException ; end
  class DRMAASessionInitError < DRMAAException ; end
  class DRMAAAlreadyActiveSessionError < DRMAAException ; end
  class DRMAASessionExitError < DRMAAException ; end
  class DRMAAInvalidAttributeFormatError < DRMAAException ; end
  class DRMAAInvalidAttributeValueError < DRMAAException ; end
  class DRMAAConflictingAttributeValuesError < DRMAAException ; end
  class DRMAATryLater < DRMAAException ; end
  class DRMAADeniedError < DRMAAException ; end
  class DRMAAInvalidJobError < DRMAAException ; end
  class DRMAAResumeInconsistent < DRMAAException ; end
  class DRMAASuspendInconsistent < DRMAAException ; end
  class DRMAAHoldInconsistent < DRMAAException ; end
  class DRMAAReleaseInconsistent < DRMAAException ; end
  class DRMAATimeoutExit < DRMAAException ; end

  class DRMAANoDefaultContactSelected < DRMAAException ; end
  class DRMAANoMoreElements < DRMAAException ; end

  # drmaa_job_ps() constants
  STATE_UNDETERMINED          = 0x00
  STATE_QUEUED_ACTIVE         = 0x10
  STATE_SYSTEM_ON_HOLD        = 0x11
  STATE_USER_ON_HOLD          = 0x12
  STATE_USER_SYSTEM_ON_HOLD   = 0x13
  STATE_RUNNING               = 0x20
  STATE_SYSTEM_SUSPENDED      = 0x21
  STATE_USER_SUSPENDED        = 0x22
  STATE_USER_SYSTEM_SUSPENDED = 0x23
  STATE_DONE                  = 0x30
  STATE_FAILED                = 0x40

  # drmaa_control() constants
  ACTION_SUSPEND   = 0
  ACTION_RESUME    = 1
  ACTION_HOLD      = 2
  ACTION_RELEASE   = 3
  ACTION_TERMINATE = 4

  # placeholders for job input/output/error path and working dir
  PLACEHOLDER_INCR = "$drmaa_incr_ph$"
  PLACEHOLDER_HD   = "$drmaa_hd_ph$"
  PLACEHOLDER_WD   = "$drmaa_wd_ph$"

  private
  ANY_JOB  = "DRMAA_JOB_IDS_SESSION_ANY"
  ALL_JOBS = "DRMAA_JOB_IDS_SESSION_ALL"

  # need errno mapping due to errno's changed from DRMAA 0.95 to 1.0 ... sigh!
  ERRNO_MAP_095 = [
    [ "DRMAA_ERRNO_SUCCESS",                        0 ],
    [ "DRMAA_ERRNO_INTERNAL_ERROR",                 1 ],
    [ "DRMAA_ERRNO_DRM_COMMUNICATION_FAILURE",      2 ],
    [ "DRMAA_ERRNO_AUTH_FAILURE",                   3 ],
    [ "DRMAA_ERRNO_INVALID_ARGUMENT",               4 ],
    [ "DRMAA_ERRNO_NO_ACTIVE_SESSION",              5 ],
    [ "DRMAA_ERRNO_NO_MEMORY",                      6 ],

    [ "DRMAA_ERRNO_INVALID_CONTACT_STRING",         7 ],
    [ "DRMAA_ERRNO_DEFAULT_CONTACT_STRING_ERROR" ,  8 ],
    [ "DRMAA_ERRNO_DRMS_INIT_FAILED",               9 ],
    [ "DRMAA_ERRNO_ALREADY_ACTIVE_SESSION",         10 ],
    [ "DRMAA_ERRNO_DRMS_EXIT_ERROR",                11 ],

    [ "DRMAA_ERRNO_INVALID_ATTRIBUTE_FORMAT",       12 ],
    [ "DRMAA_ERRNO_INVALID_ATTRIBUTE_VALUE",        13 ],
    [ "DRMAA_ERRNO_CONFLICTING_ATTRIBUTE_VALUES",   14 ],

    [ "DRMAA_ERRNO_TRY_LATER",                      15 ],
    [ "DRMAA_ERRNO_DENIED_BY_DRM",                  16 ],

    [ "DRMAA_ERRNO_INVALID_JOB",                    17 ],
    [ "DRMAA_ERRNO_RESUME_INCONSISTENT_STATE",      18 ],
    [ "DRMAA_ERRNO_SUSPEND_INCONSISTENT_STATE",     19 ],
    [ "DRMAA_ERRNO_HOLD_INCONSISTENT_STATE",        20 ],
    [ "DRMAA_ERRNO_RELEASE_INCONSISTENT_STATE",     21 ],
    [ "DRMAA_ERRNO_EXIT_TIMEOUT",                   22 ],
    [ "DRMAA_ERRNO_NO_RUSAGE",                      23 ] ]

  ERRNO_MAP_100 = [
    [ "DRMAA_ERRNO_SUCCESS",                            0 ],
    [ "DRMAA_ERRNO_INTERNAL_ERROR",                     1 ],
    [ "DRMAA_ERRNO_DRM_COMMUNICATION_FAILURE",          2 ],
    [ "DRMAA_ERRNO_AUTH_FAILURE",                       3 ],
    [ "DRMAA_ERRNO_INVALID_ARGUMENT",                   4 ],
    [ "DRMAA_ERRNO_NO_ACTIVE_SESSION",                  5 ],
    [ "DRMAA_ERRNO_NO_MEMORY",                          6 ],

    [ "DRMAA_ERRNO_INVALID_CONTACT_STRING",             7 ],
    [ "DRMAA_ERRNO_DEFAULT_CONTACT_STRING_ERROR",       8 ],
    [ "DRMAA_ERRNO_NO_DEFAULT_CONTACT_STRING_SELECTED", 9 ],
    [ "DRMAA_ERRNO_DRMS_INIT_FAILED",                   10 ],
    [ "DRMAA_ERRNO_ALREADY_ACTIVE_SESSION",             11 ],
    [ "DRMAA_ERRNO_DRMS_EXIT_ERROR",                    12 ],

    [ "DRMAA_ERRNO_INVALID_ATTRIBUTE_FORMAT",           13 ],
    [ "DRMAA_ERRNO_INVALID_ATTRIBUTE_VALUE",            14 ],
    [ "DRMAA_ERRNO_CONFLICTING_ATTRIBUTE_VALUES",       15 ],

    [ "DRMAA_ERRNO_TRY_LATER",                          16 ],
    [ "DRMAA_ERRNO_DENIED_BY_DRM",                      17 ],

    [ "DRMAA_ERRNO_INVALID_JOB",                        18 ],
    [ "DRMAA_ERRNO_RESUME_INCONSISTENT_STATE",          19 ],
    [ "DRMAA_ERRNO_SUSPEND_INCONSISTENT_STATE",         20 ],
    [ "DRMAA_ERRNO_HOLD_INCONSISTENT_STATE",            21 ],
    [ "DRMAA_ERRNO_RELEASE_INCONSISTENT_STATE",         22 ],
    [ "DRMAA_ERRNO_EXIT_TIMEOUT",                       23 ],
    [ "DRMAA_ERRNO_NO_RUSAGE",                          24 ],
    [ "DRMAA_ERRNO_NO_MORE_ELEMENTS",                   25 ]]

  def DRMAA.errno2str(drmaa_errno)
    # stack = caller
    # puts stack
    if DRMAA.version < 1.0
        s = ERRNO_MAP_095.find{ |pair| pair[1] == drmaa_errno }[0]
    else
        s = ERRNO_MAP_100.find{ |pair| pair[1] == drmaa_errno }[0]
    end
    s = "DRMAA_ERRNO_INTERNAL_ERROR" if s.nil?
      puts "errno2str(" + drmaa_errno.to_s + ") = " + s
    return s
  end

  def DRMAA.str2errno(str)
      if DRMAA.version < 1.0
          errno = ERRNO_MAP_095.find{ |pair| pair[0] == str }[1]
      else
          errno = ERRNO_MAP_100.find{ |pair| pair[0] == str }[1]
      end
      errno = 1 if errno.nil? # internal error
      # puts "str2errno(" + str + ") = " + errno.to_s
      return errno
  end

  # 101 character buffer constant (length is arbitrary)
  ErrSize = 161
  WaitSize = 15
  EC = " " * ErrSize

  public
  # returns string specifying the DRM system
  # int drmaa_get_drm_system(char *, size_t , char *, size_t)
  def DRMAA.drm_system
      drm = " " * 20
      err = " " * ErrSize
      r = FFI_DRMAA.drmaa_get_DRM_system(drm, 20, err, ErrSize)
      r1 = [drm, 20, err, ErrSize]
      DRMAA.throw(r, r1[2])
      drm.delete! "\000"
      drm.strip!
      return r1[0]
  end

  # returns string specifying contact information
  # int drmaa_get_contact(char *, size_t, char *, size_t)
  def DRMAA.contact
      contact = " " * ErrSize
      err = " " * ErrSize
      r,r1 = FFI_DRMAA.drmaa_get_contact(contact, ErrSize, err, ErrSize)
      r1 = [contact, ErrSize, err, ErrSize]
      contact.delete! "\000"
      contact.strip!
      DRMAA.throw(r, r1[2])
      return r1[0]
  end

  # returns string specifying DRMAA implementation
  # int drmaa_get_DRMAA_implementation(char *, size_t , char *, size_t)
  def DRMAA.drmaa_implementation
      err = " " * ErrSize
      impl = " " * 30
      r = FFI_DRMAA.drmaa_get_DRMAA_implementation(impl, 30, err, ErrSize)
      r1 = [impl, 30, err, ErrSize]
      DRMAA.throw(r, r1[2])
      impl.delete! "\000"
      impl.strip!
      return r1[0]
  end

  # returns DRMAA version (e.g. 1.0 or 0.95)
  # int drmaa_version(unsigned int *, unsigned int *, char *, size_t )
  def DRMAA.version
      err= " " * ErrSize
      major = FFI::MemoryPointer.new(:int, 1)
      minor = FFI::MemoryPointer.new(:int, 1)
      r = FFI_DRMAA.drmaa_version major,minor, err, ErrSize
      r1 = [major.read_int,minor.read_int, err, ErrSize]	
      DRMAA.throw(r, r1[2])
      @version = r1[0] + (Float(r1[1])/100)
  end

  private
  # const char *drmaa_strerror(int drmaa_errno)
  def DRMAA.strerror(errno)
      r =  @drmaa_strerror.call(drmaa_errno)
      return r.to_s
  end

  # int drmaa_job_ps( const char *, int *, char *, size_t )
  def DRMAA.job_ps(job)
      err = " " * ErrSize
      state = FFI::MemoryPointer.new(:int,4)
      r = FFI_DRMAA.drmaa_job_ps(job, state, err, ErrSize)
      r1 = [job, state.read_int, err, ErrSize]
      DRMAA.throw(r, r1[2])
      return r1[1]
  end

  # int drmaa_control(const char *, int , char *, size_t )
  def DRMAA.control(job, action)
      err = ' ' * ErrSize
      r = FFI_DRMAA.drmaa_control(job, action, err, ErrSize)
      r1 = [job, action, err, ErrSize]
      DRMAA.throw(r, r1[2])
  end


  # int drmaa_init(const char *, char *, size_t)
  def DRMAA.init(contact)
      err=" " * ErrSize
      r = FFI_DRMAA.drmaa_init contact, err, ErrSize-1
      r1 = [contact,err,ErrSize-1]
      contact.delete! "\000"
      contact.strip!
      DRMAA.throw(r, r1[1])
  end

  # int drmaa_exit(char *, size_t)
  def DRMAA.exit
      err=" " * ErrSize
      r = FFI_DRMAA.drmaa_exit err, ErrSize-1
      r1 = [err,ErrSize-1]
      DRMAA.throw(r, r1[0])
  end

  # int drmaa_allocate_job_template(drmaa_job_template_t **, char *, size_t)
  def DRMAA.allocate_job_template
      err=" " * ErrSize
      jt = FFI::MemoryPointer.new :pointer
      r = FFI_DRMAA.drmaa_allocate_job_template jt, err, ErrSize
      r1 = [jt,err,ErrSize]

      DRMAA.throw(r, r1[1])
      return jt
  end

  # int drmaa_delete_job_template(drmaa_job_template_t *, char *, size_t)
  def DRMAA.delete_job_template(jt)
      err = EC
      r,r1 = @drmaa_delete_job_template.call(jt.ptr, err, ErrSize)
      DRMAA.throw(r, r1[1])
  end

  # int drmaa_get_vector_attribute_names(drmaa_attr_names_t **, char *, size_t)
  def DRMAA.vector_attributes()
      err=""
      (0..100).each { |x| err << " "}
      jt = FFI::MemoryPointer.new :pointer
      r = FFI_DRMAA.drmaa_get_vector_attribute_names jt, err, ErrSize
      r1 = [jt,err,ErrSize]
      DRMAA.throw(r, r1[1])
      return DRMAA.get_attr_names(jt)
  end

  # int drmaa_get_attribute_names(drmaa_attr_names_t **, char *, size_t)
  def DRMAA.attributes()
      err=""
      (0..100).each { |x| err << " "}
      jt = FFI::MemoryPointer.new :pointer
      r = FFI_DRMAA.get_attribute_names jt, err, ErrSize
      r1 = [jt,err,ErrSize]
      DRMAA.throw(r, r1[1])
      return DRMAA.get_attr_names(jt)
  end

  def DRMAA.get_all(ids, nxt, rls)
      if DRMAA.version < 1.0
          errno_expect = DRMAA.str2errno("DRMAA_ERRNO_INVALID_ATTRIBUTE_VALUE")
      else
          errno_expect = DRMAA.str2errno("DRMAA_ERRNO_NO_MORE_ELEMENTS")
      end
      # STDERR.puts "get_all(1)"
      values = Array.new
      ret = 0
      while  ret != errno_expect do
          # STDERR.puts "get_all(2) " + DRMAA.errno2str(ret)
          err=" " * ErrSize
          jobid=" " * ErrSize
          r = FFI_DRMAA.send(nxt,ids.get_pointer(0), jobid, ErrSize)
          jobid = jobid.unpack('Z*')[0]
          # unpack null-terminated string , return first value
          r1 =  [ids.get_pointer(0),jobid,ErrSize]
          
          if r != errno_expect
              DRMAA.throw(r, "unexpected error")
              values.push(r1[1])
              # puts "get_all(3) " + DRMAA.errno2str(r)
          end
          ret = r
      end
      # puts "get_all(4)"
      FFI_DRMAA.send(rls,ids.get_pointer(0))
      return values
  end

  # int drmaa_get_next_job_id(drmaa_job_ids_t*, char *, size_t )
  # void drmaa_release_job_ids(drmaa_job_ids_t*)
  def DRMAA.get_job_ids(ids)
      return DRMAA.get_all(ids, :drmaa_get_next_job_id, :drmaa_release_job_ids)
  end


  # int drmaa_get_next_attr_name(drmaa_attr_names_t*, char *, size_t )
  # void drmaa_release_attr_names(drmaa_attr_names_t*)
  def DRMAA.get_attr_names(names)
      return DRMAA.get_all(names, :drmaa_get_next_attr_name, :drmaa_release_attr_names)
  end

  # int drmaa_get_next_attr_value(drmaa_attr_values_t*, char *, size_t )
  # void drmaa_release_attr_values(drmaa_attr_values_t*)
  def DRMAA.get_attr_values(ids)
      return DRMAA.get_all(ids, :drmaa_get_next_attr_value, :drmaa_release_attr_values)
  end

  # int drmaa_wifexited(int *, int, char *, size_t)
  def DRMAA.wifexited(stat)
      return DRMAA.wif(stat, :drmaa_wifexited)
  end

  # int drmaa_wifsignaled(int *, int, char *, size_t)
  def DRMAA.wifsignaled(stat)
      return DRMAA.wif(stat, :drmaa_wifsignaled)
  end

  # int drmaa_wifaborted(int *, int , char *, size_t)
  def DRMAA.wifaborted(stat)
      return DRMAA.wif(stat, :drmaa_wifaborted)
  end

  # int drmaa_wcoredump(int *, int , char *, size_t)
  def DRMAA.wcoredump(stat)
      return DRMAA.wif(stat, :drmaa_wcoredump)
  end

  def DRMAA.wif(stat, method)
      err = " " * ErrSize
      intp = FFI::MemoryPointer.new(:int,4)
      r = FFI_DRMAA.send(method, intp, stat, err, ErrSize)
      r1 = [intp, stat, err, ErrSize]
      DRMAA.throw(r, r1[2])
      boo = r1[0].read_int
      if boo == 0
          return false
      else
          return true
      end
  end

  # int drmaa_wexitstatus(int *, int, char *, size_t)
  def DRMAA.wexitstatus(stat)
      err = " " * ErrSize
      ret = FFI::MemoryPointer.new(:int,4)
      r = FFI_DRMAA.drmaa_wexitstatus(ret, stat, err, ErrSize)
      r1 = [ret, stat, err, ErrSize]
      DRMAA.throw(r, r1[2]) 
      return r1[0].read_int
  end

  # int drmaa_wtermsig(char *signal, size_t signal_len, int stat, char *error_diagnosis, size_t error_diag_len);
  def DRMAA.wtermsig(stat)
      err = " " * ErrSize
      signal = " " * ErrSize
      r = FFI_DRMAA.drmaa_wtermsig(signal, ErrSize, stat, err, ErrSize)
      r1 = [signal, ErrSize, stat, err, ErrSize]
      DRMAA.throw(r, r1[3]) 
      return r1[0]
  end

  # int drmaa_wait(const char *, char *, size_t , int *, signed long , 
  #               drmaa_attr_values_t **, char *, size_t );
  def DRMAA.wait(jobid, timeout)
      errno_timeout = DRMAA.str2errno("DRMAA_ERRNO_EXIT_TIMEOUT")
      errno_no_rusage = DRMAA.str2errno("DRMAA_ERRNO_NO_RUSAGE")
      err = " " * ErrSize
      waited = " " * WaitSize
      stat = FFI::MemoryPointer.new(:int,4)
      usage = FFI::MemoryPointer.new :pointer, 1

      r = FFI_DRMAA.drmaa_wait jobid, waited, WaitSize, stat, timeout, usage, err, ErrSize
      r1 = [jobid, waited, WaitSize, stat, timeout, usage, err, ErrSize]
      # getting null's at end of string
      waited.delete! "\000"
      waited.strip!

      return nil if r == errno_timeout
      if r != errno_no_rusage
          DRMAA.throw(r, r1[6])
          return JobInfo.new(r1[1], r1[3], usage) 
      else
          return JobInfo.new(r1[1], r1[3])
      end
  end

  # int drmaa_run_bulk_jobs(drmaa_job_ids_t **, const drmaa_job_template_t *jt, 
  #                         int, int, int, char *, size_t)
  def DRMAA.run_bulk_jobs(jt, first, last, incr)
      err = " " * ErrSize
      #strptrs = []
      #numJobs = (last - first + 1) / incr
      #numJobs.times {|i| strptrs << FFI::MemoryPointer.from_string(i) }
      #strptrs << nil
      #ids = FFI::MemoryPointer.new(:pointer,strptrs.length)
      #strptrs.each_with_index do |p,i|
      #    ids[i].put_pointer(0, p)
      #end
      ids = FFI::MemoryPointer.new :pointer
      r = FFI_DRMAA.drmaa_run_bulk_jobs(ids, jt.get_pointer(0), first, last, incr, err, ErrSize)
      r1 = [ids, jt, first, last, incr, err, ErrSize]
      DRMAA.throw(r, r1[5])
      return DRMAA.get_job_ids(ids)
  end

  # int drmaa_run_job(char *, size_t, const drmaa_job_template_t *, char *, size_t)
  def DRMAA.run_job(jt)
      err=" " * ErrSize
      jobid=" " * ErrSize
      r = FFI_DRMAA.drmaa_run_job jobid, ErrSize, jt.get_pointer(0), err, ErrSize
      r1 = [jobid,ErrSize,jt.get_pointer(0), err, ErrSize]
      jobid.delete! "\000"
      jobid.strip!

      DRMAA.throw(r, r1[3])
      return r1[0]
  end

  # int drmaa_set_attribute(drmaa_job_template_t *, const char *, const char *, char *, size_t)
  def DRMAA.set_attribute(jt, name, value)
      err=" " * ErrSize
      r = FFI_DRMAA.drmaa_set_attribute jt.get_pointer(0), name, value, err, ErrSize
      r1 =  [jt.get_pointer(0),name,value,err,ErrSize]
      DRMAA.throw(r, r1[3])
  end

  # int drmaa_set_vector_attribute(drmaa_job_template_t *, const char *, 
  #                               const char *value[], char *, size_t)
  def DRMAA.set_vector_attribute(jt, name, ary)
      err=" " * ErrSize
      ary.flatten!

      strptrs = []
      ary.each { |x| strptrs << FFI::MemoryPointer.from_string(x) }
      strptrs << nil

      argv = FFI::MemoryPointer.new(:pointer,strptrs.length)
      strptrs.each_with_index do |p,i|
          argv[i].put_pointer(0, p)
      end

      r = FFI_DRMAA.drmaa_set_vector_attribute jt.get_pointer(0), name, argv, err, ErrSize
      r1 = [jt.get_pointer(0),name, argv, err, ErrSize]
      DRMAA.throw(r, r1[3])
  end

  # int drmaa_get_attribute(drmaa_job_template_t *, const char *, char *, 
  #  							size_t , char *, size_t)
  def DRMAA.get_attribute(jt, name)
      err = " " * ErrSize
      value = " " * ErrSize
      r = FFI_DRMAA.drmaa_get_attribute jt.get_pointer(0), name, value, ErrSize, err, ErrSize
      value = value.unpack('Z*')[0]
      # unpack null-terminated string , return first value
      r1 = [jt.get_pointer(0), name, value, ErrSize, err, ErrSize]
      DRMAA.throw(r, r1[3])
      return r1[2]
  end

  # int drmaa_get_vector_attribute(drmaa_job_template_t *, const char *, 
  #                   drmaa_attr_values_t **, char *, size_t )
  def DRMAA.get_vector_attribute(jt, name)
      err=" " * ErrSize
      attr = FFI::MemoryPointer.new :pointer
      r = FFI_DRMAA.drmaa_get_vector_attribute jt.get_pointer(0), name, attr, err, ErrSize
      r1 = [jt.get_pointer(0), name, attr, err, ErrSize]	
      DRMAA.throw(r, r1[3])

      # Original author had a method called "drmaa_get_vector_attribute" that did the same thing as this
      return DRMAA.get_attr_values(attr)
  end

  # int drmaa_synchronize(const char *job_ids[], signed long timeout, int dispose, char *, size_t)
  def DRMAA.synchronize(jobs, timeout, dispose)
      err = " " * ErrSize
      if dispose == false
          disp = 0
      else
          disp = 1
      end
      errno_timeout = DRMAA.str2errno("DRMAA_ERRNO_EXIT_TIMEOUT")
      jobs.flatten!
      strptrs = []
      jobs.each { |x| strptrs << FFI::MemoryPointer.from_string(x) }
      strptrs << nil
      job_ids = FFI::MemoryPointer.new(:pointer,strptrs.length)
      strptrs.each_with_index do |p,i|
          job_ids[i].put_pointer(0, p)
      end
      r = FFI_DRMAA.drmaa_synchronize job_ids, timeout, disp, err, ErrSize
      r1 = [job_ids, timeout, disp, err, ErrSize]
      if r == errno_timeout
          return false
      else
          DRMAA.throw(r, r1[3]) 
          return true
      end
  end

  def DRMAA.throw(r, diag)
      return if r == 0
      s_errno = DRMAA.errno2str(r)
      case s_errno
      when "DRMAA_ERRNO_INTERNAL_ERROR"
          raise DRMAAInternalError, diag
      when "DRMAA_ERRNO_DRM_COMMUNICATION_FAILURE"
          raise DRMAACommunicationError, diag
      when "DRMAA_ERRNO_AUTH_FAILURE"
          raise DRMAAAuthenticationError, diag
      when "DRMAA_ERRNO_INVALID_ARGUMENT"
          raise DRMAAInvalidArgumentError, diag
      when "DRMAA_ERRNO_NO_ACTIVE_SESSION"
          raise DRMAANoActiveSessionError, diag
      when "DRMAA_ERRNO_NO_MEMORY"
          raise DRMAANoMemoryError, diag
      when "DRMAA_ERRNO_INVALID_CONTACT_STRING"
          raise DRMAAInvalidContactError, diag
      when "DRMAA_ERRNO_DEFAULT_CONTACT_STRING_ERROR"
          raise DRMAADefaultContactError, diag
      when "DRMAA_ERRNO_NO_DEFAULT_CONTACT_STRING_SELECTED"
          raise DRMAANoDefaultContactSelected, diag
      when "DRMAA_ERRNO_DRMS_INIT_FAILED"
          raise DRMAASessionInitError, diag
      when "DRMAA_ERRNO_ALREADY_ACTIVE_SESSION"
          raise DRMAAAlreadyActiveSessionError, diag
      when "DRMAA_ERRNO_DRMS_EXIT_ERROR"
          raise DRMAASessionExitError, diag
      when "DRMAA_ERRNO_INVALID_ATTRIBUTE_FORMAT"
          raise DRMAAInvalidAttributeFormatError, diag
      when "DRMAA_ERRNO_INVALID_ATTRIBUTE_VALUE"
          raise DRMAAInvalidAttributeValueError, diag
      when "DRMAA_ERRNO_CONFLICTING_ATTRIBUTE_VALUES"
          raise DRMAAConflictingAttributeValuesError, diag
      when "DRMAA_ERRNO_TRY_LATER"
          raise DRMAATryLater, diag
      when "DRMAA_ERRNO_DENIED_BY_DRM"
          raise DRMAADeniedError, diag
      when "DRMAA_ERRNO_INVALID_JOB"
          raise DRMAAInvalidJobError, diag
      when "DRMAA_ERRNO_RESUME_INCONSISTENT_STATE"
          raise DRMAAResumeInconsistent, diag
      when "DRMAA_ERRNO_SUSPEND_INCONSISTENT_STATE"
          raise DRMAASuspendInconsistent, diag
      when "DRMAA_ERRNO_HOLD_INCONSISTENT_STATE"
          raise DRMAAHoldInconsistent, diag
      when "DRMAA_ERRNO_RELEASE_INCONSISTENT_STATE"
          raise DRMAAReleaseInconsistent, diag
      when "DRMAA_ERRNO_EXIT_TIMEOUT"
          raise DRMAATimeoutExit, diag
      when "DRMAA_ERRNO_NO_RUSAGE"
          raise DRMAANoRusage, diag
      when "DRMAA_ERRNO_NO_MORE_ELEMENTS"
          raise DRMAANoMoreElements, diag
      end
  end

end
