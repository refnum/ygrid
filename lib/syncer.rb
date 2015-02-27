#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		syncer.rb
#
#	DESCRIPTION:
#		Rsync-based syncer.
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
require_relative 'daemon';
require_relative 'utils';
require_relative 'workspace';





#==============================================================================
# Module
#------------------------------------------------------------------------------
module Syncer

# Config
CONFIG_FILE = <<CONFIG_FILE
log file  = TOKEN_PATH_LOG
pid file  = TOKEN_PATH_PID

port       = 7948
use chroot = no
list       = no
read only  = no

[ygrid]
path = TOKEN_PATH_ROOT

CONFIG_FILE





#============================================================================
#		Syncer.start : Start the syncer.
#----------------------------------------------------------------------------
def Syncer.start

	# Get the state we need
	pathRoot   = Workspace.path();
	pathConfig = Workspace.pathConfig("syncer");
	pathLog    = Workspace.pathLog(   "syncer");
	pathPID    = Workspace.pathPID(   "syncer");

	theConfig = CONFIG_FILE.dup;
	theConfig.gsub!("TOKEN_PATH_LOG",  pathLog);
	theConfig.gsub!("TOKEN_PATH_PID",  pathPID);
	theConfig.gsub!("TOKEN_PATH_ROOT", pathRoot);

	abort("Syncer already running!") if (Daemon.running?("syncer"));



	# Start the server
	IO.write(pathConfig, theConfig);

	system("rsync", "--daemon", "--config=#{pathConfig}");

end





#==============================================================================
# Module
#------------------------------------------------------------------------------
end
