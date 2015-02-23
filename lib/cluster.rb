#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		cluster.rb
#
#	DESCRIPTION:
#		Serf-based cluster.
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

require_relative 'daemon';
require_relative 'host';
require_relative 'utils';
require_relative 'workspace';





#==============================================================================
# Module
#------------------------------------------------------------------------------
module Cluster

# Config
CONFIG_FILE = <<CONFIG_FILE
{
    "discover" : "ygrid",

    "tags" : {
        "os"    : "TOKEN_HOST_OS",
        "cpu"   : "TOKEN_HOST_CPUS",
        "ghz"   : "TOKEN_HOST_SPEED",
        "mem"   : "TOKEN_HOST_MEM",
        "load"  : "TOKEN_HOST_LOAD",
        "grids" : "TOKEN_GRIDS"
    }
}
CONFIG_FILE





#============================================================================
#		Cluster.start : Start the cluster.
#----------------------------------------------------------------------------
def Cluster.start(theArgs)

	# Get the state we need
	theHost   = Host.new();
	theConfig = CONFIG_FILE.dup;
	theGrids  = theArgs["grids"].split(",").sort.uniq.join(",");

	pathConfig = Workspace.pathConfig("cluster");
	pathLog    = Workspace.pathLog(   "cluster");

	theConfig.gsub!("TOKEN_HOST_OS",    theHost.os);
	theConfig.gsub!("TOKEN_HOST_CPUS",  theHost.cpus.to_s);
	theConfig.gsub!("TOKEN_HOST_SPEED", theHost.speed.to_s);
	theConfig.gsub!("TOKEN_HOST_MEM",   theHost.memory.to_s);
	theConfig.gsub!("TOKEN_HOST_LOAD",  theHost.load.to_s);
	theConfig.gsub!("TOKEN_GRIDS",      theGrids);

	abort("Cluster already running!") if (Daemon.running?("cluster"));



	# Start the server
	IO.write(pathConfig, theConfig);

	thePID = Process.spawn("serf agent -config-file=\"#{pathConfig}\"", [:out, :err]=>[pathLog, "w"])
	Process.detach(thePID);

	Daemon.started("cluster", thePID);

end





#============================================================================
#		Cluster.joinGrids : Join some grids.
#----------------------------------------------------------------------------
def Cluster.joinGrids(theGrids)

	# Join the grids
	addToTag("grids", theGrids.join(","));

end





#============================================================================
#		Cluster.leaveGrids : Leave some grids.
#----------------------------------------------------------------------------
def Cluster.leaveGrids(theGrids)

	# Leave the grids
	removeFromTag("grids", theGrids.join(","));

end





#============================================================================
#		Cluster.gridStatus : Get the status of a grid.
#----------------------------------------------------------------------------
def Cluster.gridStatus(theGrid)

	# Get the state we need
	if (!theGrid.empty?)
		theGrid = "-tag grid=\btheGrid\b";
	end



	# Get the status
	theStatus = JSON.parse(`serf members #{theGrid} -format=json`);

	return(theStatus);

end





#============================================================================
#		Cluster.addToTag : Add a value to a tag list
#----------------------------------------------------------------------------
def Cluster.addToTag(theTag, theValue)

	theValues = getTag(theTag).split(",") << theValue;
	theValue  = theValues.sort.uniq.join(",");
	
	setTag(theTag, theValue);

end





#============================================================================
#		Cluster.removeFromTag : Remove a value from a tag list.
#----------------------------------------------------------------------------
def Cluster.removeFromTag(theTag, theValue)

	theValues = getTag(theTag).split(",");
	theValues.delete(theValue);

	theValue = theValues.sort.uniq.join(",");
	theValue = nil if (theValue.empty?)

	setTag(theTag, theValue);

end





#============================================================================
#		Cluster.getTag : Get a tag.
#----------------------------------------------------------------------------
def Cluster.getTag(theTag, defaultValue="")

	theInfo  = JSON.parse(`serf info -format=json`);
	theValue = theInfo["tags"].fetch(theTag, defaultValue);

	return(theValue);

end





#============================================================================
#		Cluster.setTag : Set a tag.
#----------------------------------------------------------------------------
def Cluster.setTag(theTag, theValue)

	theCmd = (theValue == nil) ? "-delete #{theTag}" : "-set #{theTag}=\"#{theValue}\"";
	theLog  = `serf tags #{theCmd}`.chomp;

	if (theLog != "Successfully updated agent tags")
		puts "ERROR - Unable to set #{theTag} to #{theValue}: #{theLog}";
	end

end





#==============================================================================
# Module
#------------------------------------------------------------------------------
end

