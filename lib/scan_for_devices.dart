import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ScanForDevices extends HookWidget {
  ScanForDevices({super.key});
  @override
  Widget build(BuildContext context) {
    final deviceScanResultSubscription = useStream(
      FlutterBluePlus.scanResults,
      initialData: FlutterBluePlus.scanResults.first
    );

    final listOfResults = useState<List<ScanResult>>([]);
    // final sub = useState(null)
    void scanForDevices() {
      try{
        // Empty the list before refilling it.
        listOfResults.value = [];
        print("Scanning for blutooth devices....");
        StreamSubscription<ScanResult> sub = FlutterBluePlus.scan(scanMode: ScanMode.lowLatency).listen((event) {
          listOfResults.value.add(event);
        });
        
        // When the stream is done
        sub.onDone(() {
          print("Completed scanning for blutooth devices");
          sub.cancel(); // Cancel the stream subscription
        });

        sub.onError((error)=>{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()),))
        });
      }catch(err){
        print(err);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString()),));
      }
    }

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: ()=> scanForDevices(), 
              child: const Text("Scan")
            )
          ],
        ),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.media_bluetooth_on),
            title: Text(listOfResults.value.elementAt(index).device.localName.isNotEmpty ? listOfResults.value.elementAt(index).device.localName : "Unknown Device Name"),
            subtitle: Text(listOfResults.value.elementAt(index).device.type.name) ,
          ) ,
          itemCount: listOfResults.value.length,
        )
    );
  }
}