require 'rubygems'
require 'sinatra'
require 'haml'

$KCODE = 'u' if RUBY_VERSION < '1.9'

@@ACTIVITY = :Sleeping
@@STATUS = :Success
@@BUILD_NUM = 1
@@BUILD_TIME = DateTime.now.to_s


#set :port, 80
set :bind, '0.0.0.0'


helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area. Go away or provide a password. Now."'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['dev', 'rosebud']
  end

  def is_building()
    @@ACTIVITY != :Sleeping
  end
end

get '/' do
  redirect "/control"
end

get '/control' do
  haml :control
end

post '/control/build' do
  @@ACTIVITY = :Building
  @@BUILD_NUM += 1
  @@BUILD_TIME = Time.now.iso8601
  redirect "/control"
end

post '/control/success' do
  @@STATUS = :Success
  @@ACTIVITY = :Sleeping
  redirect "/control"
end

post '/control/failure' do
  @@STATUS = :Failure
  @@ACTIVITY = :Sleeping
  redirect "/control"
end

get '/cctray.xml' do
  content_type :xml
  haml :cctray
end

get '/protected/cctray.xml' do
  protected!
  content_type :xml
  haml :cctray
end

get '/weird/cctray.xml' do
  halt 500, 'oops!'
end

get '/weird/cc.xml' do
  sleep 2
  redirect "/cctray.xml"
end

get '/dashboard/build/detail/connectfour' do
  haml :project
end


__END__

@@ control
!!! 5
%html
  %h1 Fake CI Server
  %table
    %tr
      %td Activitiy:	
      %td= @@ACTIVITY
    %tr
      %td Status:
      %td= @@STATUS
    %tr
      %td Build number:	
      %td= @@BUILD_NUM
    %tr
      %td Build time:	
      %td= @@BUILD_TIME
  %p 
  %form{:name => "input", :action => "control/build", :method => "post"}
    %input{:type => "submit", :value => "Start build", :disabled => is_building() }
  %form{:name => "input", :action => "control/success", :method => "post"}
    %input{:type => "submit", :value => "Success", :disabled => !is_building() }
  %form{:name => "input", :action => "control/failure", :method => "post"}
    %input{:type => "submit", :value => "Failure", :disabled => !is_building() }
  %p
  %a{:href => "ccmenu+http://localhost:4567/cctray.xml"} Add a project to CCMenu

@@ cctray
!!! XML
%Projects
  %Project{:name => 'Other Project', :webUrl => 'http://localhost:4567/dashboard/build/detail/other-project',
    :activity => :Sleeping, :lastBuildStatus => :Success,
    :lastBuildLabel => "build.1234", :lastBuildTime => "2007-07-18T18:44:48"}
  %Project{:name => 'connectfour', :webUrl => 'http://localhost:4567/dashboard/build/detail/connectfour',
    :activity => @@ACTIVITY, :lastBuildStatus => @@STATUS,
    :lastBuildLabel => "build.#{@@BUILD_NUM}", :lastBuildTime => @@BUILD_TIME}
  %Project{:name => 'dummy', :webUrl => 'http://localhost:4567/dashboard/build/detail/dummy',
    :activity => :Sleeping, :lastBuildStatus => :Unknown,
    :lastBuildLabel => "build.99", :lastBuildTime => "2007-07-18T18:44:48"}


@@ project
!!! 5
%html
  %h1 Connect Four
  %p This is the project page on the build server.


