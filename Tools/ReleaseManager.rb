
## Project configuration
## use attributes to configure your release

class Project
    def initialize(name, version)
        @name = name
        @version = version
        @basename = name.downcase + "-" + version
        @webdir = "/www/sites/www.mulle-kybernetik.com/htdocs/software/#{name}"
        @uploaddir = webdir + "/Downloads"
        @settings = "INSTALL_PATH=\"/\" COPY_PHASE_STRIP=YES"
    end
    
    attr_accessor :name, :version, :svnroot, :basename, :webdir, :uploaddir, :settings
end


## Environment configuration
## use attributes to configure manager for your environment

class Environment
    def initialize()
        @svn = "/usr/local/bin/svn"
        @tmpdir = "/tmp/makerelease.#{Process.pid}"
        @sourcedir = tmpdir + "/Source"
        @productdir = tmpdir + "/Products"
        @packagedir = tmpdir
    end
    
    attr_accessor :svn, :tmpdir, :sourcedir, :productdir, :packagedir
end


## Logger (Worker)
## used to print commands that would be run

class Logger
    def chdir(dir)
        puts "** chdir #{dir}"
    end
    
    def write(filename, content)
        content = content[0, 40] + "..." if content.length > 40
        puts "** writing to file #{filename}: #{content}"
    end

    def run(cmd)
        puts "** #{cmd}"
    end
end


## Executer (Worker)
## used to actually run commands

class Executer
    def chdir(dir)
        Dir.chdir(dir)
    end

    def write(filename, content)
        f = File.new(filename, "w")
        f.write(content)
        f.close
    end

    def run(cmd)
        system(cmd)
    end
end


## Composite Worker (Worker)
## used to send commands to multiple workers

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
end    


## The ReleaseManager class
## contains methods for the individual release steps

class ReleaseManager

    def initialize(proj, env, doit)
        @proj = proj
        @env = env
        if(doit)
            @worker = CompositeWorker.new([Logger.new(), Executer.new()])
        else
            @worker = Logger.new()
        end
    end
    
    def createWorkingDirectories
        @worker.run("mkdir #{@env.tmpdir}")
        @worker.run("mkdir #{@env.sourcedir}")
        @worker.run("mkdir #{@env.productdir}")
    end
    
    def checkOutSource
        @worker.chdir(@env.sourcedir)
        @worker.run("#{@env.svn} export #{@proj.svnroot}/trunk #{@proj.basename}")
    end

    def createSourcePackage
        @worker.chdir(@env.sourcedir)
        @worker.run("gnutar cvzf #{@env.packagedir}/#{@proj.basename}-s.tar.gz #{@proj.basename}")
    end
    
    def buildModules
        @worker.chdir("#{@env.sourcedir}/#{@proj.basename}")
        @worker.run("xcodebuild -project #{@proj.name}.xcodeproj -target CCMenu -configuration Release DSTROOT=#{@env.productdir} #{@proj.settings} install")
    end

    def createBinaryPackage
        @worker.chdir(@env.productdir)
        @worker.run("gnutar cvzf #{@env.packagedir}/#{@proj.basename}-b.tar.gz *")
    end
    
    def upload
        @worker.chdir(@env.packagedir)
        @worker.run("scp *.tar.gz #{ENV['USER']}@muller.mulle-kybernetik.com:#{@proj.uploaddir}")
    end
   
    def cleanup
        @worker.run("chmod -R u+w #{@env.tmpdir}")
        @worker.run("rm -rf #{@env.tmpdir}");
    end
    
end

