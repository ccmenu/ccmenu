#!/usr/bin/env ruby

require 'Date'
load 'Tools/ReleaseManager.rb'

label = DateTime.now.strftime("%Y%m%d%H%M%S")
worker = CompositeWorker.new([Logger.new(), Executer.new()])

# clean up
worker.run("chmod -R a+w build")
worker.run("rm -Rf build")

# build and run unit tests
worker.run("xcodebuild -project CCMenu.xcodeproj -target UnitTests -configuration Debug | tee build/buildlog.txt")

# build release app
worker.run("mkdir build/SnapshotInstall")
worker.run("xcodebuild -project CCMenu.xcodeproj -target CCMenu -configuration Release DSTROOT=build/SnapshotInstall INSTALL_PATH=\"/\" install")

# create snapshot dmg
worker.chdir("build")
worker.run("rm ccmenu-snapshot.dmg")
worker.makedmg("SnapshotInstall", "CCMenu #{label}", "ccmenu-snapshot.dmg")
