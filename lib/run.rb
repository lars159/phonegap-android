#
# Run
# ---
#
# A handy machine that does the following:
#
# - packages www to a valid android project in tmp/android
# - builds tmp/android project into an apk
# - installs apk onto first device found
# - attaches a logger to catch output from console.log statements
#
class Run
  # if no path is supplied uses current directory for project
  def initialize(path)
    @pkg = Package.new(path)
    @apk = File.join(@pkg.path, "bin", "#{ @pkg.name }-debug.apk")
    
    build
    install
  end
  
  # creates tmp/android/bin/project.apk
  def build
    `cd #{ @pkg.path }; ant debug`
  end 
  
  # installs apk to first device found
  def install
    @device = `adb devices`.split("\n")[1]
    raise "Unable to run! No devices found." if @device.nil?
    @device.gsub!("\tdevice",'')
    puts `adb -s #{ @device } install -r #{ @apk }`
  end
end