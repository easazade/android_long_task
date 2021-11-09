import 'package:android_long_task/android_long_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_service_config.dart';

AppServiceData data = AppServiceData();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'my foreground service example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'android long task example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _result = 'result';
  String _status = 'status';

  @override
  void initState() {
    AppClient.updates.listen((json) {
      if (json != null) {
        var serviceData = AppServiceData.fromJson(json);
        setState(() {
          _status = serviceData.notificationDescription;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_status', textAlign: TextAlign.center),
            SizedBox(height: 6),
            Text('$_result',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () async {
                try {
                  var result = await AppClient.execute(data);
                  var resultData = AppServiceData.fromJson(result);
                  setState(() => _result =
                      'finished executing service process ;) -> ${resultData.progress}');
                } on PlatformException catch (e, stacktrace) {
                  print(e);
                  print(stacktrace);
                }
              },
              child: Text('run dart function'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  var result = await AppClient.getData();
                  setState(() => _result = result.toString());
                } on PlatformException catch (e, stacktrace) {
                  print(e);
                  print(stacktrace);
                }
              },
              child: Text('get service data'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AppClient.stopService();
                  setState(() => _result = 'stop service');
                } on PlatformException catch (e, stacktrace) {
                  print(e);
                  print(stacktrace);
                }
              },
              child: Text('stop service'),
            ),
          ],
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
serviceMain() async {
  // print(arg);
  WidgetsFlutterBinding.ensureInitialized();
  ServiceClient.setExecutionCallback((initialData) async {
    var serviceData = AppServiceData.fromJson(initialData);
    for (var i = 0; i < 50; i++) {
      print('dart -> $i');
      serviceData.progress = i;
      await ServiceClient.update(serviceData);
      if (i > 5) {
        await ServiceClient.endExecution(serviceData);
        var result = await ServiceClient.stopService();
        print(result);
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  });
}
