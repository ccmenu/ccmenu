require 'sinatra'
require 'haml'

$KCODE = 'u' if RUBY_VERSION < '1.9'

@@ACTIVITY = :Sleeping
@@STATUS = :Success
@@BUILD_NUM = 1
@@BUILD_TIME = "2007-07-18T18:44:48"

helpers do
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


@@ cctray
!!! XML
%Projects
  %Project{:name => 'connectfour', :webUrl => 'http://localhost:4567/dashboard/build/detail/connectfour',
    :activity => @@ACTIVITY, :lastBuildStatus => @@STATUS,
    :lastBuildLabel => "build.#{@@BUILD_NUM}", :lastBuildTime => @@BUILD_TIME}


@@ project
!!! 5
%html
  %h1 Connect Four
  %p This is the project page on the build server.


