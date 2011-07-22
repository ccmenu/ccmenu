require 'sinatra'

$KCODE = 'u' if RUBY_VERSION < '1.9'

before do
	content_type :html, 'charset' => 'utf-8'
end

get '/cctray.xml' do

	body = File.open('fakeresponse.xml').read()
	[200, {"Content-Type" => "application/xml"}, body]
	 
end

get '/dashboard/build/detail/connectfour' do

  body = '<html><body><h1>Connect Four</h1>This is the project page on the build server.</body></html>'
  [200, {"Content-Type" => "text/html"}, body]

end
