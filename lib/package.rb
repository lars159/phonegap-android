# ./droidgap pkg /Users/brianleroux/Desktop/MyApp
#
# Package
# 
# Generates an Android project from a PhoneGap project. Assumes a valid PhoneGap project structure:
# 
# project
#  |-pkg ... android project files
#  |-bin ... release files
#  '-www ... html, css and javascript (optional config.xml for additional properties)
#
class Package
  attr_reader :name, :pkg, :www, :path
  
  def initialize(path)
    
    # validates we have a correct sdk path
    # validtes a valid package
    
    # TODO need to generate these 
    # @name, @pkg, @www, @path = a
    @android_sdk_path = '/Users/brianleroux/Code/android-sdk-mac_86' # `which android`
    
    # use app name to extract package and name if no config.xml is found
    @pkg = 
    @name = 
    
    
    @path = path
    @www = File.join(@path, 'www')
    
    
    
    @android_dir = File.expand_path(File.dirname(__FILE__))
    @framework_dir = File.join(@android_dir, "src")
  end
  
  # runs the build script
  def run
    build_jar
    create_android
    include_www
    generate_manifest
    copy_libs
    add_name_to_strings
    write_java
	  puts "Complete!"
  end 
  
  # removes local.properties and recreates based on android_sdk_path 
  # then generates framework/phonegap.jar
  def build_jar
    puts "Building the JAR..."
    %w(local.properties phonegap.js phonegap.jar).each do |f|
      FileUtils.rm File.join(@framework_dir, f) if File.exists? File.join(@framework_dir, f)
    end
    open(File.join(@framework_dir, "local.properties"), 'w') do |f|
      f.puts "sdk.dir=#{ @android_sdk_path }"
    end 
    Dir.chdir(@framework_dir)
    `ant jar`
    Dir.chdir(@android_dir)
  end

  # runs android create project
  # TODO need to allow more flexible SDK targetting
  # TODO validate Android SDK
  def create_android
    android_exec = File.join(@android_sdk_path, "tools", "android");
    target_id = 5 
    puts "Creating Android project... #{ target_id }"
    `"#{android_exec}" create project -t #{ target_id } -k #{ @pkg } -a #{ @name } -n #{ @name } -p #{ @path }`
  end
  
  def include_www
    puts "Adding www folder to project..."
    
    FileUtils.mkdir_p File.join(@path, "assets", "www")
    FileUtils.cp_r File.join(@www, "."), File.join(@path, "assets", "www")
  end

  # creates an AndroidManifest.xml for the project
  def generate_manifest
    puts "Generating manifest..."
    manifest = ""
    open(File.join(@framework_dir, "AndroidManifest.xml"), 'r') do |old|
      manifest = old.read
      manifest.gsub! 'android:versionCode="5"', 'android:versionCode="1"'
      manifest.gsub! 'package="com.phonegap"', "package=\"#{ @pkg }\""
      manifest.gsub! 'android:name=".StandAlone"', "android:name=\".#{ @name }\""
      manifest.gsub! 'android:minSdkVersion="5"', 'android:minSdkVersion="3"'
    end
    open(File.join(@path, "AndroidManifest.xml"), 'w') { |x| x.puts manifest }
  end

  # copies stuff from framework into the project
  # TODO need to allow for www import inc icon
  def copy_libs
    puts "Copying over libraries and assets and creating phonegap.js..."
    
    framework_res_dir = File.join(@framework_dir, "res")
    app_res_dir = File.join(@path, "res")

    FileUtils.mkdir_p File.join(@path, "libs")
    FileUtils.cp File.join(@framework_dir, "phonegap.jar"), File.join(@path, "libs")

    FileUtils.mkdir_p File.join(app_res_dir, "values")
    FileUtils.cp File.join(framework_res_dir, "values","strings.xml"), File.join(app_res_dir, "values", "strings.xml")

    FileUtils.mkdir_p File.join(app_res_dir, "layout")
    %w(main.xml preview.xml).each do |f|
      FileUtils.cp File.join(framework_res_dir, "layout", f), File.join(app_res_dir, "layout", f)
    end

    %w(drawable-hdpi drawable-ldpi drawable-mdpi).each do |e|
      FileUtils.mkdir_p File.join(app_res_dir, e)
      FileUtils.cp File.join(framework_res_dir, "drawable", "icon.png"), File.join(app_res_dir, e, "icon.png")
    end

    # concat JS and put into www folder.
    js_dir = File.join(@framework_dir, "assets", "js")

    phonegapjs = IO.read(File.join(js_dir, 'phonegap.js.base'))

    Dir.new(js_dir).entries.each do |script|
      next if script[0].chr == "." or script == "phonegap.js.base"
      phonegapjs << IO.read(File.join(js_dir, script))
      phonegapjs << "\n\n"
    end

    File.open(File.join(@path, "assets", "www", "phonegap.js"), 'w') {|f| f.write(phonegapjs) }
  end
  
  # puts app name in strings
  def add_name_to_strings
    puts "Adding some application name to strings.xml..."
    x = "<?xml version=\"1.0\" encoding=\"utf-8\"?>
    <resources>
      <string name=\"app_name\">#{ @name }</string>
      <string name=\"go\">Snap</string>
    </resources>
    "
    open(File.join(@path, "res", "values", "strings.xml"), 'w') do |f|
      f.puts x.gsub('    ','')
    end 
  end 

  # this is so fucking unholy yet oddly beautiful
  # not sure if I should thank Ruby or apologize for this abusive use of string interpolation
  def write_java
	  puts "Writing application Java code..."
    j = "
    package #{ @pkg };

    import android.app.Activity;
    import android.os.Bundle;
    import com.phonegap.*;

    public class #{ @name } extends DroidGap
    {
        @Override
        public void onCreate(Bundle savedInstanceState)
        {
            super.onCreate(savedInstanceState);
            super.loadUrl(\"file:///android_asset/www/index.html\");
        }
    }
    "
    
    code_dir = File.join(@path, "src", @pkg.gsub('.', File::SEPARATOR))

    FileUtils.mkdir_p(code_dir)
    open(File.join(code_dir, "#{@name}.java"),'w') { |f| f.puts j.gsub('    ','') }
  end
  #
end