#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		job_status.rb
#
#	DESCRIPTION:
#		Job status object.
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
require_relative 'job';





#==============================================================================
# Class
#------------------------------------------------------------------------------
class JobStatus


# Attributes
attr_reader :id
attr_reader :status
attr_reader :dst_host


# Progress
ACTIVE = 'A';
DONE   = 'D';





#==============================================================================
#		JobStatus::initialize : Initialiser.
#------------------------------------------------------------------------------
def initialize(jobID, theStatus, dstHost)

	# Initialise ourselves
	@id       = jobID;
	@status   = theStatus;
	@dst_host = dstHost;

end





#============================================================================
#		JobStatus::pretty_status : Get a readable status.
#----------------------------------------------------------------------------
def pretty_status

	case @status
		when ACTIVE
			theStatus = "Active";

		when DONE
			theStatus = "Done";
		
		else
			theStatus = @status.to_i.to_s + "%";
	end

	return(theStatus);

end





#============================================================================
#		JobStatus::src_host : Get the source host.
#----------------------------------------------------------------------------
def src_host

	return(Job.decodeID(@id)[:src_host]);

end





#============================================================================
#		JobStatus::to_s : Convert to a string.
#----------------------------------------------------------------------------
def to_s

	# Get the state we need
	theInfo  = Job.decodeID(@id);
	srcIndex = theInfo[:src_index];
	srcIP    = theInfo[:src_host].to_i;
	dstIP    = @dst_host.to_i;



	# Generate the short address
	#
	# A 'short address' encodes the difference between the source address
	# within the job ID and the destination address that's executing the job.
	#
	#		Src IP		0A000117	(10.0.1.23)
	#		Dst IP		0A000107	(10.0.1.7)
	#
	#		Mask		000000FF
	#		Short IP	00000017
	#
	# The short address can be combined with the destination address to recover
	# the original source address and hence the full job ID.
	theMask = JobStatus::getMask(srcIP ^ dstIP);
	shortIP = srcIP & theMask;



	# Pack the state
	theState = "%X.%X.%s" % [srcIndex, shortIP, @status];

	return(theState);

end





#============================================================================
#		JobStatus.from_s : Convert from a string.
#----------------------------------------------------------------------------
def self.from_s(theState, dstHost)

	# Get the state we need
	theValues = theState.split(".");
	srcIndex  = theValues[0].hex;
	shortIP   = theValues[1].hex;
	dstIP     = dstHost.to_i;



	# Generate the source address
	#
	# Combining the 'short address' and the destination address it was generated
	# on we can reapply the mask to obtain the original IP address.
	theMask = getMask(shortIP);
	srcIP   = shortIP | (dstIP & ~theMask)
	srcHost = IPAddr.new(srcIP, Socket::AF_INET);



	# Create the status
	theID     = Job.encodeID(srcIndex, srcHost);
	theStatus = JobStatus.new(theID, theValues[2], dstHost);

	return(theStatus);

end





#============================================================================
#		JobStatus::getMask : Get a mask for packing.
#----------------------------------------------------------------------------
def self.getMask(theValue)

	# Generate the mask
	mask1 = (((theValue >> 24) & 0xFF) == 0 ? 0 : 0xFF);
	mask2 = (((theValue >> 16) & 0xFF) == 0 ? 0 : 0xFF);
	mask3 = (((theValue >>  8) & 0xFF) == 0 ? 0 : 0xFF);
	mask4 = (((theValue >>  0) & 0xFF) == 0 ? 0 : 0xFF);

	theMask = (mask1 << 24) | (mask2 << 16) | (mask3 << 8) | (mask4 << 0);

	return(theMask);

end






#==============================================================================
# Class
#------------------------------------------------------------------------------
end
