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

require 'dl/import'
require 'ffi'

module FFI_DRMAA
    extend FFI::Library

    ffi_lib 'libdrmaa.so'

    #TODO / Missing: 
    #
    # drmaa_delete_job_template
    # drmaa_strerror

    attach_function 'drmaa_version', [ :pointer , :pointer , :string , :ulong ], :int
    attach_function 'drmaa_init', [:string, :string, :ulong], :int
    attach_function 'drmaa_allocate_job_template', [:pointer, :string, :ulong], :int
    attach_function 'drmaa_get_attribute', [:pointer, :string, :pointer, :ulong, :string, :ulong], :int
    attach_function 'drmaa_get_attribute_names', [:pointer, :string, :ulong], :int
    attach_function 'drmaa_get_vector_attribute', [:pointer, :string, :pointer, :string, :ulong], :int
    attach_function 'drmaa_get_vector_attribute_names', [:pointer, :string, :ulong], :int

    attach_function 'drmaa_run_job', [:string, :ulong, :pointer, :string, :ulong], :int
    attach_function 'drmaa_set_attribute', [:pointer, :string, :string, :string, :ulong], :int
    attach_function 'drmaa_set_vector_attribute', [:pointer, :string, :pointer, :string, :ulong], :int
    attach_function 'drmaa_get_contact', [:string, :ulong, :string, :ulong], :int
    attach_function 'drmaa_get_DRM_system', [:string, :ulong, :string, :ulong], :int
    attach_function 'drmaa_get_DRMAA_implementation', [:string, :ulong, :string, :ulong], :int
    attach_function 'drmaa_wait', [:buffer_in,:string,:ulong,:pointer,:long,:pointer,:string,:ulong], :int
    attach_function 'drmaa_wifexited', [:pointer,:int,:string,:ulong], :int
    attach_function 'drmaa_wexitstatus', [:pointer,:int,:string,:ulong], :int
    attach_function 'drmaa_wifsignaled', [:pointer,:int,:string,:ulong], :int
    attach_function 'drmaa_wtermsig', [:string,:ulong,:int,:string,:ulong], :int
    attach_function 'drmaa_wifaborted', [:pointer,:int,:string,:ulong], :int
    attach_function 'drmaa_wcoredump', [:pointer,:int,:string,:ulong], :int
    attach_function 'drmaa_exit', [:string, :ulong], :int
    attach_function 'drmaa_run_bulk_jobs', [:pointer,:pointer,:int,:int,:int,:string,:ulong], :int
    attach_function 'drmaa_get_next_job_id', [ :pointer , :string , :ulong ], :int
    attach_function 'drmaa_release_job_ids', [ :pointer ], :void
    attach_function 'drmaa_get_next_attr_name', [ :pointer , :string, :ulong], :int
    attach_function 'drmaa_release_attr_names', [ :pointer ], :void
    attach_function 'drmaa_get_next_attr_value',[ :pointer, :string, :ulong], :int
    attach_function 'drmaa_release_attr_values',[ :pointer ], :void
    attach_function 'drmaa_control', [:string,:int,:string,:ulong], :int
    attach_function 'drmaa_job_ps', [ :string, :pointer , :string, :ulong], :int

    attach_function 'drmaa_synchronize', [:pointer,:long,:int,:string,:ulong], :int

end
