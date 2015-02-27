#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		job.rb
#
#	DESCRIPTION:
#		Job object.
#
#	COPYRIGHT:
#		Copyright (c) 2015, refNum Software
#		<http://www.refnum.com/>
#
#		All rights reserved.
#
#		Redistribution and use in source and binary forms, with or without
#		modification, are permitted provided that the following conditions
#		are met:
#
#			o Redistributions of source code must retain the above
#			copyright notice, this list of conditions and the following
#			disclaimer.
#
#			o Redistributions in binary form must reproduce the above
#			copyright notice, this list of conditions and the following
#			disclaimer in the documentation and/or other materials
#			provided with the distribution.
#
#			o Neither the name of refNum Software nor the names of its
#			contributors may be used to endorse or promote products derived
#			from this software without specific prior written permission.
#
#		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#		"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#		LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#		A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#		OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#		SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#		LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#		DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#		THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#		(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#==============================================================================
# Imports
#------------------------------------------------------------------------------
require 'json';
require 'xmlrpc/utils';

require_relative 'utils';





#==============================================================================
# Class
#------------------------------------------------------------------------------
class Job

# Includes
include XMLRPC::Marshallable;


# Attributes
attr_accessor :grid
attr_accessor :host
attr_accessor :src_host
attr_accessor :src_index
attr_accessor :cmd_task
attr_accessor :cmd_done
attr_accessor :status
attr_accessor :inputs
attr_accessor :outputs


# Constants
DEFAULT_GRID      = "";
DEFAULT_HOST      = nil;
DEFAULT_SRC_HOST  = nil;
DEFAULT_SRC_INDEX = nil;
DEFAULT_CMD_TASK  = "";
DEFAULT_CMD_DONE  = "";
DEFAULT_STATUS    = nil;
DEFAULT_INPUTS    = [];
DEFAULT_OUTPUTS   = [];





#==============================================================================
#		Job::initialize : Initialiser.
#------------------------------------------------------------------------------
def initialize(thePath)

	# Load the file
	load(thePath);

end





#============================================================================
#		Job::validate : Validate a job.
#----------------------------------------------------------------------------
def validate

	# Validate the job
	theErrors = [];
	
	if (@cmd_task.empty?)
		theErrors << "job does not contain 'cmd_task'";
	end

	return(theErrors);

end





#==============================================================================
#		Job::load : Load a job.
#------------------------------------------------------------------------------
def load(thePath)

	# Load the job
	theInfo = JSON.parse(IO.read(thePath));

	@grid      = theInfo.fetch("grid",        DEFAULT_GRID);
	@host      = theInfo.include?("host")     ? IPAddr.new(theInfo["host"])     : DEFAULT_HOST;
	@src_host  = theInfo.include?("src_host") ? IPAddr.new(theInfo["src_host"]) : DEFAULT_HOST;
	@src_index = theInfo.fetch("src_index",   DEFAULT_SRC_INDEX);
	@cmd_task  = theInfo.fetch("cmd_task",    DEFAULT_CMD_TASK);
	@cmd_done  = theInfo.fetch("cmd_done",    DEFAULT_CMD_DONE);
	@status    = theInfo.fetch("status",      DEFAULT_STATUS);
	@inputs    = theInfo.fetch("inputs",      DEFAULT_INPUTS);
	@outputs   = theInfo.fetch("outputs",     DEFAULT_OUTPUTS);

end





#============================================================================
#		Job::save : Save a job.
#----------------------------------------------------------------------------
def save(theFile)

	# Get the state we need
	tmpFile = theFile + "_tmp";
	theInfo = Hash.new();

	theInfo["grid"]      = @grid      if (@grid      != DEFAULT_GRID);
	theInfo["host"]      = @host      if (@host      != DEFAULT_HOST);
	theInfo["src_host"]  = @src_host  if (@src_host  != DEFAULT_SRC_HOST);
	theInfo["src_index"] = @src_index if (@src_index != DEFAULT_SRC_INDEX);
	theInfo["cmd_task"]  = @cmd_task  if (@cmd_task  != DEFAULT_CMD_TASK);
	theInfo["cmd_done"]  = @cmd_done  if (@cmd_done  != DEFAULT_CMD_DONE);
	theInfo["status"]    = @status    if (@status    != DEFAULT_STATUS);
	theInfo["inputs"]    = @inputs    if (@inputs    != DEFAULT_INPUTS);
	theInfo["outputs"]   = @outputs   if (@outputs   != DEFAULT_OUTPUTS);



	# Save the file
	#
	# To ensure the write is atomic we save to a temporary and then rename.
	IO.write(    tmpFile, JSON.pretty_generate(theInfo) + "\n");
	FileUtils.mv(tmpFile, theFile);

end





#============================================================================
#		Job::id : Get the job ID.
#----------------------------------------------------------------------------
def id

	# Get the ID
	#
	# A job ID is a unique 16-character identifier that contains the IP
	# address of its source host and a host-specific index.
	theID = "%08X%08X" % [@src_index, @src_host.to_i];

	return(theID);

end





#==============================================================================
# Class
#------------------------------------------------------------------------------
end
