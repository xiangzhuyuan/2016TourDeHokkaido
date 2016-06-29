module Tcxxxer
  class DB
    def self.file_type(file_name)
      case File.extname(file_name).downcase
      when '.tcx'
        TCX
      when '.gpx'
        GPX
      when '.fit'
        FIT
      else
        raise "Unknown filetype"
      end
    end
    
    def self.open(file_name)
      db = new(file_name)
      db.parse
      return db
    end

    def initialize(file)
      @file_name = file
    end
    
    def parse 
      case self.class.file_type(@file_name)
      when TCX
        @doc = Tcxxxer::TcxParser.open(@file_name)
      when GPX
        @doc = Tcxxxer::GpxParser.open(@file_name)
      when FIT
        @doc = Tcxxxer::FitParser.open(@file_name)
      end
    end

    def courses
      @doc.courses
    end

    def course(course_id)
      @doc.courses(course_id)
    end
  end
end
