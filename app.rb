require './minazuki'
class App < Sinatra::Base
  register Sinatra::Reloader

  HTML_PATTERN = %r{^/(.*)\.html$}

  before do
    @site_name = '水無月の余韻'
    @analytics_on = false
    @google_analytics_id = Minazuki::GA_UA_ID
  end

  get HTML_PATTERN do
    haml :"#{params[:captures].first}"
  end

  get '/' do
      haml :index
  end

end