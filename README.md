# android_long_task

android long task is a flutter plugin to run dart code in an android foreground service with simplicity

Does it work on IOS as well?
What About IOS?
Is there a plugin to run long running tasks in IOS background?
**Answer :**
No & No & No. this is an IOS limitation and you must consider this before creating your app and change your design or requirements if necessary

  ## How does this plugin work?
![screenshot 1](diagram.jpg?raw=true "diagram")
**TLDR**
basically you should know that you should write the code you want to run in your ForegroundService in a different main function called **serviceMain**
if you want to know exactly why read the rest.


**This is why :**
a flutter app that runs on android runs in an **Activity**. and Activity is an android OS component where all android apps run in.  in order for Android OS components to run their code they must run in  a system **Process**.  so activities run in a **Process**

**Service** is another Android OS component that runs code in the background without showing anything to the user.  since Android OS since Android 8 will not allow Services to run for long. we have a special type of Service which is **Foreground Service**. it is a type of Service in Android OS that will not be killed by Android OS and shows a notification to the user as long as it runs. the purpose of Foreground Service is to run your code as long as you want outside the application

**Here comes the YOU MUST KNOW PART :**

Android Activities and Services do not in the same process. that is the reason why when use closes your app and your app's process gets killed by the system your code in foreground service will still run. because your flutter app code runs in an Activity which has a separate process from your Foreground Service. This behavior also means that the code that runs in an Activities and Foreground Services are running in different Environments. because of this the dart process you run in your activity is different from the dart code you run in your service. that is why we have basically to functions that runs dart code one is the **main** function which runs your app. one is **serviceMain** function which runs your dart code in your service.


## Getting Started

## Notification icon:
Foreground Service has a notification icon. this icon must be named `ic_launcher.png` and exist in this directory `android\app\src\main\res\mipmap`

if you're using `flutter_launcher_icons` to generate your app launcher icons, you don't need to do any changes

# install:
just add plugin to your pubspec.yaml
there is no need to fore adding native code or making changes in your `AndroidManifest.xml` file

```yaml
dependencies:
	android_long_task: ^last_version
```

## Step 1: create Service shared data
create a service data class to specify the data that is shared between your app dart-code and your service dart-code. in this class you  will add the shared data you need and also specify the ForegroundService notification's title and description

```dart
import  'dart:convert';
import  'package:android_long_task/android_long_task.dart';

class  SharedUploadData  extends  ServiceData {

    int progress =  0;

    @override
    String  get  notificationTitle => 'uploading';

    @override
    String  get  notificationDescription => 'progress -> $progress';

    String  toJson() {
        var jsonMap = {
            'progress': progress,
         };
        return  jsonEncode(jsonMap);
     }

    static  AppServiceData  fromJson(Map<String, dynamic> json) {
         return  AppServiceData()..progress = json['progress'] as  int;
    }

}
```

## Step 2 : create serviceMain

create a `serviceMain()` function in your `lib/main.dart` file. this is where you define the dart code that is going to run in your ForegroundService

```dart
//this entire function runs in your ForegroundService
serviceMain() async {
	//make sure you add this
	WidgetsFlutterBinding.ensureInitialized();
	//if your use dependency injection you initialize them here
	//what ever objects you created in your app main function is not accessible here

	//set a callback and define the code you want to execute when your ForegroundService runs
	ServiceClient.setExecutionCallback((initialData) async {
		//you set initialData when you are calling AppClient.execute()
		//from your flutter application code and receive it here
		var serviceData =  AppServiceData.fromJson(initialData);
		//runs your code here
		serviceData.progress = 20;
		await ServiceClient.update(serviceData);
		//run some more code
		serviceData.progress = 100;
		await ServiceClient.update(serviceData);
		await ServiceClient.stopService();
	});

}
```

**What is ServiceClient**
service client is basically an interface to your ForegroundService. it providers methods like
* `update(sharedDate)` which is used to update the shared data between you app dart-code and service-dart code.

* `stopService()` which stops the service. note that you don't have to stop the ForegroundService if that is what you need.

* `setExecutionCallback(callback)` which sets the callback that runs in your service when you call `AppClient.execute()` from application side

**Note :** `ServiceClient` should only be used in the code that runs in `serviceMain()` function

## Step 3 : execute

now you can call `AppClient.execute()` from your app dart-code to start ForegroundService and run the `serviceMain()` function in it.

```dart
import  'package:android_long_task/android_long_task.dart';

//you can listen for shared data update
AppClient.observe.listen((json) {
	var serviceData =  AppServiceData.fromJson(json);
	//your code
});

await AppClient.execute(initialSharedData);

```
* you could also use `AppClient.getData()` to get the last data. if the ForegroundService is running it will return the last changes. if ForegroundService is stopped the initial data will be returned. if you have not called `AppClient.execute()` at all `null` will be returned

* `AppCient` is the interface that allows you to communicate with ForegroundService from application side dart-code. `AppClient` methods must only be called from the application side

# ToDo list

* add options to customize ForegroundService Notification more

