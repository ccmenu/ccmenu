require 'sinatra'

$KCODE = 'u' if RUBY_VERSION < '1.9'

before do
	content_type :html, 'charset' => 'utf-8'
end

get '/cctray.xml' do

	body = 
	'<Projects>
    <Project name="connectfour" activity="Sleeping" lastBuildStatus="Success" lastBuildLabel="build.1" 
       lastBuildTime="2007-07-18T18:44:48" webUrl="http://localhost:8080/dashboard/build/detail/connectfour"/>
  </Projects>'
     
	[200, {"Content-Type" => "application/xml"}, body]
	 
end

get '/cctray.html' do

  body = '<html><body>sdhfsjkdf<p></body></html>'

  [200, {"Content-Type" => "text/html"}, body]

end
