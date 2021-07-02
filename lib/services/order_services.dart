import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_delivery_app_flutter/services/firebase_services.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderServices {

  FirebaseServices _services = FirebaseServices();

  Color statusColor(document) {
    if (document.data()['orderStatus'] == 'Đã từ chối') {
      return Colors.red;
    }
    if (document.data()['orderStatus'] == 'Đã chấp nhận') {
      return Colors.blueGrey[400];
    }
    if (document.data()['orderStatus'] == 'Picked up') {
      return Colors.pink[900];
    }
    if (document.data()['orderStatus'] == 'Đang giao hàng') {
      return Colors.deepPurpleAccent;
    }
    if (document.data()['orderStatus'] == 'Đã giao hàng') {
      return Colors.green;
    }
    return Colors.orange;
  }

  Icon statusIcon(document) {
    if (document.data()['orderStatus'] == 'Đã chấp nhận') {
      return Icon(Icons.assignment_turned_in_outlined,color: statusColor(document),);
    }
    if (document.data()['orderStatus'] == 'Picked up') {
      return Icon(Icons.cases,color: statusColor(document),);

    }
    if (document.data()['orderStatus'] == 'Đang giao hàng') {
      return Icon(Icons.delivery_dining,color: statusColor(document),);

    }
    if (document.data()['orderStatus'] == 'Đã giao hàng') {
      return Icon(Icons.shopping_bag_outlined,color: statusColor(document),);
    }

    return Icon(Icons.assignment_turned_in_outlined,color: statusColor(document),);
  }

  Widget statusContainer(document, context) {
    if(document.data()['deliveryBoy']['name'].length > 1){
      if (document.data()['orderStatus'] == 'Đã chấp nhận') {
        return Container(
          color: Colors.grey[300],
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 8, 40, 8),
            child: TextButton(
              style: ButtonStyle(
                  backgroundColor: ButtonStyleButton.allOrNull<Color>(statusColor(document)) //:-(
              ),
              child: Text(
                'Update Status to Picked Up',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                EasyLoading.show();
                _services.updateStatus(id: document.id,status:  'Picked Up').then((value) {
                  EasyLoading.showSuccess('Order Status is now Picked Up');
                });
              },
            ),
          ),
        );
      }
    }
    if (document.data()['orderStatus'] == 'Picked Up') {
      return Container(
        color: Colors.grey[300],
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 8, 40, 8),
          child: TextButton(
            style: ButtonStyle(
                backgroundColor: ButtonStyleButton.allOrNull<Color>(statusColor(document)) //:-(
            ),
            child: Text(
              'Update Status to On The Way',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              EasyLoading.show();
              _services.updateStatus(id: document.id,status:  'On the way').then((value) {
                EasyLoading.showSuccess('Order Status is now On the way');
              });
            },
          ),
        ),
      );
    }

    if (document.data()['orderStatus'] == 'On the way') {
      return Container(
        color: Colors.grey[300],
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 8, 40, 8),
          child: TextButton(
            style: ButtonStyle(
                backgroundColor: ButtonStyleButton.allOrNull<Color>(statusColor(document))
            ),
            child: Text(
              'Giao hàng',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if(document.data()['cod'] == true){
                return showMyDialog('Nhận thanh toán', 'Đã giao hàng', document.id, context);
              }else{
                EasyLoading.show();
                _services.updateStatus(id: document.id,status: 'Đã giao hàng').then((value) {
                  EasyLoading.showSuccess('Trạng thái đơn hàng đã được giao');
                });
              }

            },
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[300],
      height: 30,
      width: MediaQuery.of(context).size.width,
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: ButtonStyleButton.allOrNull<Color>(Colors.green)
        ),
        child: Text(
          'Hoàn thành đơn hàng',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
        },
      ),
    );
  }

  void launchCall(number) async =>
      await canLaunch(number) ? await launch(number) : throw 'Không thể gọi $number';

  void launchMap(lat,long,name)async {
    final availableMaps = await MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
      coords: Coords(lat, long),
      title: name,
    );
  }

  showMyDialog(title, status, documentId, context) {
    OrderServices _orderServices = OrderServices();
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text('Đảm bảo rằng bạn đã nhận được thanh toán'),
            actions: [
              TextButton(
                child: Text(
                  'ĐÃ NHẬN',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  EasyLoading.show();
                  _services.updateStatus(id: documentId, status: 'Đã giao hàng').then((value){
                    EasyLoading.showSuccess('Trạng thái đơn hàng đã được giao ');
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}