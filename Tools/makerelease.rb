#!/usr/bin/env ruby

require 'date'
require 'rexml/document'
include REXML


class ReleaseManager

    def initialize
        @proj = Project.new("CCMenu", "1.4.1", "https://ccmenu.svn.sourceforge.net/svnroot/ccmenu/branches/sparkleupdate")
        @env = Environment.new()
        @worker = CompositeWorker.new([Logger.new(), Executer.new()])
    end
    
    def makeAll
      createWorkingDirectories
      checkOutSource 
      createSourcePackage
      buildModules
      createBinaryPackage
      createAppcast
      openPackageDir
    end
    
    def createWorkingDirectories
        @worker.run("mkdir #{@env.tmpdir}")
        @worker.run("mkdir #{@env.sourcedir}")
        @worker.run("mkdir #{@env.productdir}")
    end
    
    def checkOutSource
        @worker.chdir(@env.sourcedir)
        @worker.run("svn export #{@proj.svnroot} #{@proj.basename}")
    end

    def createSourcePackage
        @worker.chdir(@env.sourcedir)
        @worker.run("gnutar cvzf #{@env.packagedir}/#{@proj.basename}-s.tar.gz #{@proj.basename}")
    end
    
    def buildModules
        @worker.chdir("#{@env.sourcedir}/#{@proj.basename}")
        @worker.run("xcodebuild -project #{@proj.name}.xcodeproj -target #{@proj.name} -configuration Release DSTROOT=#{@env.productdir} INSTALL_PATH=\"/\" install")
    end

    def createBinaryPackage
        @worker.chdir(@env.packagedir)
        @worker.run("hdiutil create -size 4m temp.dmg -layout NONE") 
        disk_id = nil
        @worker.run("hdid -nomount temp.dmg") { |hdid| disk_id = hdid.readline.split[0] }
        @worker.run("newfs_hfs -v '#{@proj.name}' #{disk_id}")
        @worker.run("hdiutil eject #{disk_id}")
        @worker.run("hdid temp.dmg") { |hdid| disk_id = hdid.readline.split[0] }
        @worker.run("cp -R #{@env.productdir}/* '/Volumes/#{@proj.name}'")
        @worker.run("hdiutil eject #{disk_id}")
        @worker.run("hdiutil convert -format UDZO temp.dmg -o #{@env.packagedir}/#{@proj.basename}-b.dmg -imagekey zlib-level=9")
        @worker.run("hdiutil internet-enable -yes #{@env.packagedir}/#{@proj.basename}-b.dmg")
        @worker.run("rm temp.dmg")
        
    end
    
    def createAppcast
        @worker.chdir(@env.packagedir)

        pubdate = DateTime.now.strftime("%A, %B %d, %Y %H:%M:%S %Z")
        imagename = "#{@proj.basename}-b.dmg"
        imagesize = File.stat("#{@env.packagedir}/#{imagename}").size
        svnout = IO.popen("svn --xml info #{@proj.svnroot}").read
        svnrev = Document.new(svnout).elements["info/entry/@revision"].value
        
        appcast=<<END_OF_TEMPLATE        
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>#{@proj.name} Updates</title>
    <language>en</language>
    <item>
        <title>#{@proj.name} #{@proj.version}</title>
        <pubDate>#{pubdate}</pubDate>
        <sparkle:releaseNotesLink>http://ccmenu.svn.sourceforge.net/viewvc/*checkout*/ccmenu/trunk/RELEASENOTES.txt?revision=#{svnrev}</sparkle:releaseNotesLink> 
        <enclosure 
          sparkle:version="#{@proj.version}"
          url="http://sourceforge.net/projects/ccmenu/files/#{@proj.name}/#{@proj.version}/#{imagename}/download" 
          length="#{imagesize}" 
          type="application/octet-stream"/>
    </item>
  </channel>
</rss>
END_OF_TEMPLATE
        @worker.write("update.xml", appcast)
    end
   
    def openPackageDir
        @worker.run("open #{@env.packagedir}") 
    end
   
    def cleanup
        @worker.run("chmod -R u+w #{@env.tmpdir}")
        @worker.run("rm -rf #{@env.tmpdir}");
    end
    
end


## Project configuration
## use attributes to configure your release

class Project
    def initialize(name, version, svnroot)
        @name = name
        @version = version
        @basename = name.downcase + "-" + version
        @svnroot = svnroot
    end
    
    attr_accessor :name, :version, :basename, :svnroot
end


## Environment
## use attributes to configure manager for your environment

class Environment
    def initialize()
        @tmpdir = "/tmp/makerelease.#{Process.pid}"
        @sourcedir = tmpdir + "/Source"
        @productdir = tmpdir + "/Products"
        @packagedir = tmpdir
    end
    
    attr_accessor :tmpdir, :sourcedir, :productdir, :packagedir
end


## Logger (Worker)
## prints commands

class Logger
    def chdir(dir)
        puts "## chdir #{dir}"
    end
    
    def write(filename, content)
        content = content[0, 40] + "..." if content.length > 40
        puts "** writing to file #{filename}: #{content}"
    end

    def run(cmd)
        puts "## #{cmd}"
    end
end


## Executer (Worker)
## actually runs commands

class Executer
    def chdir(dir)
        Dir.chdir(dir)
    end
    
    def write(filename, content)
        f = File.new(filename, "w")
        f.write(content)
        f.close
    end

    def run(cmd, &block)     
        if block == nil
          system(cmd)
        else
          IO.popen(cmd, &block)
        end
    end
end


## Composite Worker (Worker)
## sends commands to multiple workers

class CompositeWorker
    def initialize(workers)
        @workers = workers
    end
    
    def chdir(dir)
        @workers.each { |w| w.chdir(dir) }
    end

    def write(filename, content)
        @workers.each { |w| w.write(filename, content) }
    end
    
    def run(cmd)
         @workers.each { |w| w.run(cmd) }
    end
 
    def run(cmd, &block)
         @workers.each { |w| w.run(cmd, &block) }
    end
end    


## Runner convenience

ReleaseManager.new.makeAll
