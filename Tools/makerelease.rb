#!/usr/bin/env ruby

load "ReleaseManager.rb"

proj = Project.new("CCMenu", "0.9")
proj.svnroot = "https://ccmenu.svn.sourceforge.net/svnroot/ccmenu"
proj.settings = "INSTALL_PATH=\"/\" COPY_PHASE_STRIP=YES"

env = Environment.new()

m = ReleaseManager.new(proj, env, ARGV.index("-d") == nil)
m.createWorkingDirectories
m.checkOutSource
m.createSourcePackage
m.buildModules
m.createBinaryPackage
#m.upload
#m.cleanup


