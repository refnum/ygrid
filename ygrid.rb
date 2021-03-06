#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		ygrid.rb
#
#	DESCRIPTION:
#		ygrid - simple clustering.
#
#	COPYRIGHT:
#		Copyright (c) 2015-2019, refNum Software
#		All rights reserved.
#
#		Redistribution and use in source and binary forms, with or without
#		modification, are permitted provided that the following conditions
#		are met:
#		
#		1. Redistributions of source code must retain the above copyright
#		notice, this list of conditions and the following disclaimer.
#		
#		2. Redistributions in binary form must reproduce the above copyright
#		notice, this list of conditions and the following disclaimer in the
#		documentation and/or other materials provided with the distribution.
#		
#		3. Neither the name of the copyright holder nor the names of its
#		contributors may be used to endorse or promote products derived from
#		this software without specific prior written permission.
#		
#		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#		"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#		LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#		A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#		HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#		SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#		LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#		DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#		THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#		(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#==============================================================================
# Imports
#------------------------------------------------------------------------------
require 'optparse';

require_relative 'lib/controller';
require_relative 'lib/utils';





#==============================================================================
#		cmdStart : Start the server.
#------------------------------------------------------------------------------
def cmdStart(theArgs)

	# Get the state we need
	theRoot  = theArgs[:root];
	theGrids = theArgs[:grid].split(",").sort.uniq;



	# Start the server
	puts "#{Controller.running? ? "Restarting" : "Starting"} ygrid server...";
	
	Controller.start(theRoot, theGrids);

end





#==============================================================================
#		cmdStop : Stop the server.
#------------------------------------------------------------------------------
def cmdStop(theArgs)

	# Stop the server
	puts "Stopping ygrid server...";

	Controller.stop();

end





#==============================================================================
#		cmdJoin : Join some grids.
#------------------------------------------------------------------------------
def cmdJoin(theArgs)

	# Get the state we need
	theGrids = theArgs[:args].sort.uniq;
	numGrids = Utils.getCount(theGrids, "grid");



	# Join the grids
	puts "Joining #{numGrids}...";
	
	Controller.joinGrids(theGrids);

end





#==============================================================================
#		cmdLeave : Leave some grids.
#------------------------------------------------------------------------------
def cmdLeave(theArgs)

	# Get the state we need
	theGrids = theArgs[:args].sort.uniq;
	numGrids = Utils.getCount(theGrids, "grid");



	# Leave the grids
	puts "Leaving #{numGrids}...";

	Controller.leaveGrids(theGrids);

end





#==============================================================================
#		cmdSubmit : Submit a job.
#------------------------------------------------------------------------------
def cmdSubmit(theArgs)

	# Get the state we need
	#
	# Resolving the file path may fail so we grab the filename first then
	# update it after it's resolved (if we could).
	theGrid  = theArgs[:grid];
	theFile  = theArgs[:args][0];

	fileName = File.basename(theFile);
	theError = "";



	# Submit the job
	begin
		theFile  = File.realpath(theFile);
		fileName = File.basename(theFile);
		jobID    = Controller.submitJob(theGrid, theFile);

	rescue Errno::ENOENT
		theError = "unable to open #{fileName}";
	
	rescue Errno::EISDIR
		theError = "#{fileName} is a directory";
	
	rescue JSON::ParserError
		theError = "#{fileName} is not a valid .json file";
	
	rescue YGrid::MissingTask
		theError = "#{fileName} is missing a 'task' command";
	end



	# Show the result
	Utils.fatalError(theError) if (!theError.empty?)

	puts "Submitted #{fileName} as #{jobID}";

end





#==============================================================================
#		cmdCancel : Cancel a job.
#------------------------------------------------------------------------------
def cmdCancel(theArgs)

	raise("cmdCancel -- not implemented");

end





#==============================================================================
#		cmdStatus : Show the status.
#------------------------------------------------------------------------------
def cmdStatus(theArgs)

	# Get the state we need
	theGrids = theArgs[:grid].split(",").sort.uniq;



	# Show the status
	Controller.showStatus(theGrids);

end





#==============================================================================
#		cmdHelp : Display the help.
#------------------------------------------------------------------------------
def cmdHelp

	puts "ygrid: simple grid clustering";
	puts "";
	puts "Available commands are:";
	puts "";
	puts "    ygrid start [--root=/path/to/workspace] [--grid=grid1,grid2,gridN]";
	puts "";
	puts "        Start the ygrid server.";
	puts "";
	puts "";
	puts "    ygrid stop";
	puts "";
	puts "        Stop the ygrid server.";
	puts "";
	puts "";
	puts "    ygrid join grid1 [grid2] [gridN]";
	puts "";
	puts "        Joins the specified grids. Joining a named grid removes this node";
	puts "        from the default grid.";
	puts "";
	puts "";
	puts "    ygrid leave grid1 [grid2] [gridN]";
	puts "";
	puts "        Leaves the specified grids. Once all named grids have been left then";
	puts "        the node returns to the default grid.";
	puts "";
	puts "";
	puts "    ygrid status [--grid=grid1,grid2,gridN]";
	puts "";
	puts "        Displays the status of the grid.";
	puts "";
	puts "";
	puts "    ygrid submit [--grid=name] job.json";
	puts "";
	puts "        Submit a job.";
	puts "";
	exit(0);

end





#==============================================================================
#		checkStatus : Check the status.
#------------------------------------------------------------------------------
def checkStatus(theCmd)
	
	if (!["start", "stop", "help"].include?(theCmd) && !Controller.running?)
		puts "No ygrid server running!";
		exit(-1);
	end

end





#==============================================================================
#		ygrid : Simple clustering.
#------------------------------------------------------------------------------
def ygrid

	# Initialise ourselves
	Thread.abort_on_exception = true;

	theArgs = Utils.getArguments();
	theCmd  = theArgs[:cmd];

	Utils.checkInstall();
	checkStatus(theCmd);



	# Perform the command
	case theCmd
		when "start"
			cmdStart(theArgs);

		when "stop"
			cmdStop(theArgs);
		
		when "join"
			cmdJoin(theArgs);
		
		when "leave"
			cmdLeave(theArgs);
		
		when "submit"
			cmdSubmit(theArgs);
		
		when "cancel"
			cmdCancel(theArgs);
		
		when "status"
			cmdStatus(theArgs);
		
		else
			cmdHelp();

	end

end

ygrid();

