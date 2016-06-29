require 'nokogiri'
module Tcxxxer

  class TcxParser

    def self.open(file)
      tcx_parser = self.new(file)
      tcx_parser.parse
      tcx_parser
    end

    def initialize(file)
      @file = file
    end

    def parse
      f    = File.open(@file)
      @doc = Nokogiri.XML(f.read)
      @doc.remove_namespaces!
      f.close
    end

    def courses()
      @doc.xpath('//Courses').map do |course_node|
        build_course(course_node)
      end
    end

    private
    def build_course(course_node)
      course       = Course.new
      course.name  = course_node.xpath('//Name').inner_text.to_s
      course.lap   = build_lap(course_node.xpath('//Lap'))
      course.track = build_track_point(course_node.xpath('//Track'))

      course
    end

    def build_lap(lap_node)
      lap                    = Tcxxxer::Lap.new
      lap.total_time_seconds = lap_node.xpath('//TotalTimeSeconds').inner_text.to_s
      lap.distance_meters    = lap_node.xpath('//DistanceMeters').inner_text.to_s
      lap.begin_lat          = lap_node.xpath('//BeginPosition/LatitudeDegrees').inner_text.to_s
      lap.begin_lng          = lap_node.xpath('//BeginPosition/LongitudeDegrees').inner_text.to_s
      lap.end_lat            = lap_node.xpath('//EndPosition/LatitudeDegrees').inner_text.to_s
      lap.end_lng            = lap_node.xpath('//EndPosition/LongitudeDegrees').inner_text.to_s
      lap
    end

    def build_track_point(track_point_node)

      track_points = []
      track_point_node.xpath('//Trackpoint').map do |track_node|
        track_point            = Tcxxxer::TrackPoint.new
        track_point.latitude   = track_node.xpath('Position/LatitudeDegrees').inner_text.to_f
        track_point.longitude  = track_node.xpath('Position/LongitudeDegrees').inner_text.to_f
        track_point.altitude   = track_node.xpath('AltitudeMeters').inner_text.to_f
        track_point.distance   = track_node.xpath('DistanceMeters').inner_text.to_f
        track_point.heart_rate = track_node.xpath('HeartRateBpm').inner_text.to_i
        track_point.time       = Time.parse(track_node.xpath('Time').inner_text)
        track_point.cadence    = track_node.xpath('Cadence').inner_text.to_i
        track_point.watts      = track_node.xpath('Watts').inner_text.to_i
        track_point.speed      = track_node.xpath('Speed').inner_text.to_f

        track_points<< track_point
      end

      track_points

    end

  end
end
