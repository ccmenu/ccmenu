require 'sinatra'
require 'haml'

$KCODE = 'u' if RUBY_VERSION < '1.9'

@@ACTIVITY = "Sleeping"
@@STATUS = "Success"
@@BUILD_NUM = 1
@@BUILD_TIME = "2007-07-18T18:44:48"

before do
	content_type :html, 'charset' => 'utf-8'
end

get '/' do
  redirect "/control"
end

get '/control' do
  haml :control
end

post '/control/build' do
  @@ACTIVITY = 'Building'
  @@BUILD_NUM += 1
  @@BUILD_TIME = Time.now.iso8601
  redirect "/control"
end

post '/control/success' do
  @@STATUS = 'Success'
  @@ACTIVITY = 'Sleeping'
  redirect "/control"
end

post '/control/failure' do
  @@STATUS = "Failure"
  @@ACTIVITY = "Sleeping"
  redirect "/control"
end

get '/cctray.xml' do
  body = "
  <Projects>
    <Project name='connectfour' activity='#{@@ACTIVITY}' lastBuildStatus='#{@@STATUS}'
             lastBuildLabel='build.#{@@BUILD_NUM}' lastBuildTime='#{@@BUILD_TIME}'
             webUrl='http://localhost:4567/dashboard/build/detail/connectfour' />
  </Projects>"
	[200, {"Content-Type" => "application/xml"}, body]
end

get '/dashboard/build/detail/connectfour' do
  haml :project
end


__END__

@@ layout
!!! 5
%html
  = yield


@@ control
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
  %input{:type => "submit", :value => "Start build", :disabled => @@ACTIVITY != "Sleeping" }
%form{:name => "input", :action => "control/success", :method => "post"}
  %input{:type => "submit", :value => "Success", :disabled => @@ACTIVITY == "Sleeping" }
%form{:name => "input", :action => "control/failure", :method => "post"}
  %input{:type => "submit", :value => "Failure", :disabled => @@ACTIVITY == "Sleeping" }


@@ project

%h1 Connect Four
%p This is the project page on the build server.


