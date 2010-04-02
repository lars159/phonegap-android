PhoneGap/Android
================
PhoneGap/Android is an Android application library that allows for PhoneGap based projects to be built for the Android Platform. PhoneGap based applications are, at the core, an application written with web technology: HTML, CSS and JavaScript. 

Pre Requisites
--------------
- Java JDK 1.5
- Android SDK Package [http://developer.android.com](http://developer.android.com)
- Apache ANT
- Ruby

Install
-------

Add PhoneGap/Android to your PATH variable like so:

export PATH=$PATH:~/phonegap-android/bin

DroidGap: PhoneGap/Android Dev Script
-------------------------------------

Useful utilities for developers building mobile apps using PhoneGap for Android.

<pre>    
    ./droidgap [android_sdk_path] [name] [package_name] [www] [path]

    android_sdk_path ... The path to your Android SDK install.
    name ............... The name of your application.
    package_name ....... The name of your package (For example: com.nitobi.demo)
    www ................ The path to your www folder. (Wherein your HTML, CSS and JS app is.)
    path ............... The path to generate the application.
</pre>

Thats it!

Importing a PhoneGap/Android app into Eclipse
---------------------------------------------

1. File > New > Project...
2. Android > Android Project
3. Create project from existing source (point to the generated app). This should import the project into Eclipse. Almost done!
4. Right click on libs/phonegap.jar and add to build path.
5. Right click on the project root: Run as > Run Configurations
6. Click on the Target tab and select Manual (this way you can choose the emulator or device to build to).


Command Line Hacks
==================
    
Compile an APK
---

Converting a W3C Widget into a an APK
---

    $ ./droidgap

List devices attached
---

    $ adb devices 
    List of devices attached 
    0123456789012	device

Install APK onto device
---

    $ apk -s 0123456789012 install phonegap.apk
    
Logging 
---

Via console.log calls from your apps javascript.

    $ adb logcat
    
Debugging
---
    
Attach it to a process on the device

    $ adb jdwp
    adb forward tcp:8000 jdwp: jdb -attach localhost:8000
    
    
For more info see
-----------------
- [http://docs.phonegap.com](http://docs.phonegap.com)
- [http://wiki.phonegap.com](http://wiki.phonegap.com)