class Run

  def apk
    Package.new(args).run
  end
  
  def jar
    `ant jar`
  end 
  
  def list
    `adb devices`
  end 
  
  def install
    `apk -s 0123456789012 install phonegap.apk`
  end
  
  def log
    
  end
end