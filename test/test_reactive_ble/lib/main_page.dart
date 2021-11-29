import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:test_reactive_ble/ble_manager.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLE"),
      ),
      body: Consumer<BleManager>(
        builder: (context, manager, child) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                child: const Text("Discovered devices"),
                onPressed: manager.discovery,
              ),
            ),
            Expanded(
              flex: 4,
              child: _ListView(
                list: manager.discoveredDevices,
                onTap: (index) => manager.connect(index),
              ),
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                child: const Text("Connected devices"),
                onPressed: () {},
              ),
            ),
            Expanded(
              flex: 4,
              child: _ListView(
                list: manager.connectedDevices,
                onTap: (index) => manager.send(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  final List<DiscoveredDevice> list;
  final ValueSetter onTap;

  const _ListView({Key? key, required this.list, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(list.elementAt(index).name),
        ),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemCount: list.length,
    );
  }
}
