require 'sinatra'
require "sinatra/reloader"
require 'yaml'
require 'rack-flash'
require 'json'
require 'strava/api/v3'
require 'polylines'

require 'tcxxxer'


use Rack::Flash

# configure sinatra
set :run, false
set :raise_errors, true

# setup logging to file
log = File.new("app.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)
$stderr.sync = true
$stdout.sync = true

# server-side flow
get '/' do
  #redirect '/auth/strava'
  erb :index
end
get '/index' do
  #redirect '/auth/strava'
  redirect '/'
end

get '/auth/:provider/callback' do
  content_type 'text/html'
  @result                 = JSON.parse(MultiJson.encode(request.env['omniauth.auth']))
  session['current_user'] = @result['info']
  session['token']        = @result['credentials']['token']
  flash[:notice]          = "Welcome back #{@result['info']['nickname']}"
  redirect '/home'
end

get '/home' do
  if session['current_user']
    @result          = session['current_user']

    # new client
    @client          = Strava::Api::V3::Client.new(:access_token => session['token'])
    @routes          = @client.list_athlete_routes[0...3]
    # get only latest 3 routes
    @route_point_arr = []
    @routes.each do |route|
      point_arr = Polylines::Decoder.decode_polyline(route['map']['summary_polyline'])
      route_str = ''
      route_str += "["
      point_arr.each_with_index do |latlng, index|
        route_str += "{lat:#{latlng[0]}, lng: #{latlng[1]}}"
        if index < point_arr.length-1
          route_str += ","
        end
      end
      route_str += "]"

      _center = "{lat:#{ point_arr[point_arr.length-1][0]}, lng: #{point_arr[point_arr.length-1][1]}}"

      @route_point_arr << {
        :name   => route['name'],
        :center => _center,
        :route  => route_str
      }
    end
    puts @route_point_arr[0]
    erb :home
  else
    redirect '/'
  end

end

get '/auth/failure' do
  content_type 'application/json'
  MultiJson.encode(request.env)
end

get '/logout' do
  session.clear
  flash[:notice] = "You have logouted"
  redirect 'index'
end

get '/map' do
  # input parameter
  # name
  day = params['day']
  file_name = "TourDeHokkaido_day#{day}"
  db           = Tcxxxer::DB.open("./tcx/#{file_name}.tcx")
  @points_list = []
  db.courses.each do |course|
    course_range = course.track.each_slice(400).to_a

    course_range.each_with_index do |range, _i|
      @points    = []
      @altitudes = []
      range.each do |point|
        @points << (point.distance/1000).round(2).to_s + "km"
        @altitudes << point.altitude.round(2)
        # @points_list << {:points => @points, :altitudes => @altitudes}
      end

      begin
          # read all, get each id
          html_file = "./tcx_result/#{file_name}_#{_i}.html"
          puts "start read erb, and create html file ...."
          renderer = ERB.new(File.read("./views/line.erb"))
          result   = renderer.result(binding)

          File.open(html_file, 'w') do |f|
            puts "write #{html_file} start"
            f.write(result)
          end

        rescue => e
          puts e.message
        end

    end
  end
  # get file list
  @result_list = Dir["./tcx_result/#{file_name}*.html"]
  erb :line_result
end
