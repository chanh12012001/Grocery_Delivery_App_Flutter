import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:grocery_delivery_app_flutter/screens/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class AuthProvider extends ChangeNotifier {
  File image;
  bool isPicAvail = false;
  String pickerError = '';
  String error = '';

  //shop data
  double shopLatitude;
  double shopLongitude;
  String shopAddress;
  String placeName;
  String email;
  bool loading = false;

  CollectionReference _boys = FirebaseFirestore.instance.collection('boys');

  getEmail(email){
    this.email = email;
    notifyListeners();
  }

  //---------------------Reduce image size---------------------
  Future<File> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'Không có ảnh nào được chọn';
      notifyListeners();
    }
    return this.image;
  }
  //---------------------Reduce image size---------------------


  //---------------------Get Current Address---------------------
  Future getCurrentAddress() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    this.shopLatitude = _locationData.latitude;
    this.shopLongitude = _locationData.longitude;
    notifyListeners();

    final coordinates =
    new Coordinates(_locationData.latitude, _locationData.longitude);
    var _addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var shopAddress = _addresses.first;
    this.shopAddress = shopAddress.addressLine;
    this.placeName = shopAddress.featureName;
    notifyListeners();
    return shopAddress;
  }
  //---------------------Get Current Address---------------------



  //------------------Register vendor using email-----------------
  Future<UserCredential> registerBoys(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        this.error = 'Mật khẩu được cung cấp quá yếu.';
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        this.error = 'Tài khoản không tồn tại.';
        notifyListeners();
      }
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
    return userCredential;
  }
  //------------------Register vendor using email-----------------


  //-----------------------------Login---------------------------
  Future<UserCredential> loginBoys(email, password) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      this.error=e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }
  //-----------------------------Login---------------------------


  //-------------------------Reset password-----------------------
  Future<void> resetPassword(email) async {
    this.email = email;
    notifyListeners();
    UserCredential userCredential;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email).whenComplete((){

      });
    } on FirebaseAuthException catch (e) {
      this.error=e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e);
    }
    return userCredential;
  }
  //-------------------------Reset password-----------------------


  //-------------------Save vendor data to Firestore-----------------
  Future<void> saveBoysDataToDb({String url, String name, String mobile, String password, context}) {
    User user = FirebaseAuth.instance.currentUser;
    _boys.doc(this.email).update({
      'uid':user.uid,
      'name':name,
      'password' : password,
      'mobile':mobile,
      'address' : '${this.placeName}: ${this.shopAddress}',
      'location': GeoPoint(this.shopLatitude, this.shopLongitude),
      'imageUrl':url,
      'accVerified':false
    }).whenComplete(() {
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    });
    return null;
  }
//-------------------Save vendor data to Firestore-----------------
}

