#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		controller.rb
#
#	DESCRIPTION:
#		ygrid controller.
#
#	COPYRIGHT:
#		Copyright (c) 2012, refNum Software
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
require_relative 'cluster';
require_relative 'syncer';





#==============================================================================
# Module
#------------------------------------------------------------------------------
module Controller

# Paths
PATH_CONFIG = "/tmp/ygrid";





#============================================================================
#		Controller.running? : Is the controller running?
#----------------------------------------------------------------------------
def Controller.running?

	return(Syncer.running? && Cluster.running?);

end





#============================================================================
#		Controller.start : Start the controller.
#----------------------------------------------------------------------------
def Controller.start(theArgs)

	startedSyncer  = Syncer.start( theArgs);
	startedCluster = Cluster.start(theArgs);

	return(startedSyncer && startedCluster);

end





#============================================================================
#		Syncer.stop : Stop the syncer.
#----------------------------------------------------------------------------
def Syncer.stop()

	Syncer.stop();
	Cluster.stop();

end





#==============================================================================
# Module
#------------------------------------------------------------------------------
end
