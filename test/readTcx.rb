require 'tcxxxer'
require 'nokogiri'

db = Tcxxxer::DB.open('../tcx/TourDeHokkaido_day1.tcx')
db.courses.each do |course|
  course.track.each { |point| puts "#{point.altitude}" }
end
#
# run = db.activity('2016-06-27T10:53:26Z')
#
# run.laps.each do |lap|
#   puts "Lap Time: #{lap.time}"
#   puts "Lap Distance: #{lap.distance}"
#   puts "Lap Calories: #{lap.calories}"
#   lap.track_points.each do |track_point|
#     puts "#{track_point.latitude} #{track_point.longitude}"
#   end
# end