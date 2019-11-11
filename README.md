# tf_album_saver
A plugin that can save image/gif/video to an album.

## Features
> Save image（jpg/jpeg/png）、gif、video to album

## Usage 
#### To use this plugin, add tf_ablum_saver as a dependency in your pubspec.yaml file. For example:
  ```
    dependencies:
        tf_album_saver: ^0.2.0
  ```

## Android and iOS specific permissions #
For this plugin to work you will have to add permission configuration to your AndroidManifest.xml (Android) and Info.plist (iOS) files. This will tell the platform which hardware or software features your app needs. Complete lists of these permission options can be found in our example app here:

### AndroidManifest.xml
 ```
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
 ```
### Info.plist
 ```
    Privacy - Photo Library Additions Usage Description
    Privacy - Photo Library Usage Description
 ```