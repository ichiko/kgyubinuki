class App < Sinatra::Base
	register Sinatra::Reloader

	get '/' do
		haml :index
	end

end