require "rubygems"
require "sinatra"
require "rack-flash"
require "sinatra/redirect_with_flash"
require "dm-core"
require "dm-migrations"
require "digest/sha1"
require "sinatra-authentication"
require "coderay"
require "./model/snippet"
Bundler.require

use Rack::Session::Cookie, :secret => "noseQUE$%$#^$#esEsTo...P3r0Bueh!"
enable :sessions
use Rack::Flash

SITE_TITLE = "Snippets - Venezuela"
SITE_DESCRIPTION = "Fragmentos de codigo para compartir"

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

# Index Action
get "/" do
  @title = "Nuevo Snippet"

  erb :index
end

get "/list" do
  if current_user.admin?
    @snippets = Snippet.all :order => :id.desc
    @title = "Snippets"

    erb :list
  else
    redirect "/", :error => "NO tienes permisos para realizar esta accion."
  end
end

# Create Action
post "/" do
  s = Snippet.new
  s.title = params[:title]
  s.language = params[:language]
  s.code = params[:code]
  if s.save
    redirect "/" + s.id.to_s, :notice => "Snippet guardado!"
    
  else
    redirect "/", :error => "Error al guardar el Snippet..."
  end
end

# Show Action
get "/:id" do
  @snippet = Snippet.get params[:id]
  
  if @snippet
    @title = @snippet.title
    erb :show
  else
    redirect "/", :error => "No se encontro el Snippet"
  end
end

get "/:id/delete" do
  login_required
  @snippet = Snippet.get params[:id]
  @title = "Eliminar el Snippet ##{params[:id]}"

  if current_user.admin?
    if @snippet
      erb :delete
    else
      redirect "/", :error => "No se encontro el Snippet..."
    end
  else
    redirect "/", :error => "NO tienes permisos para realizar esta accion."
  end
end

delete "/:id" do
  s = Snippet.get params[:id]
  if s.destroy
    redirect "/", :notice => "Snippet Eliminado!"
  else
    redirect "/", :error => "Error al eliminar el Snippet..."
  end
end

