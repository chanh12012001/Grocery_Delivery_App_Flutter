import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_delivery_app_flutter/providers/auth_provider.dart';
import 'package:grocery_delivery_app_flutter/screens/login_screen.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  var _emailTextController = TextEditingController();
  var _passwordTextController = TextEditingController();
  var _cPasswordTextController = TextEditingController();
  var _addressTextController = TextEditingController();
  var _nameTextController = TextEditingController();
  String email;
  String password;
  String name;
  String mobile;
  bool _isLoading = false;

  Future<String> uploadFile(filePath) async {
    File file = File(filePath);
    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage.ref('boyProfilePic/${_nameTextController.text}').putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }

    String downloadURL = await _storage.ref('boyProfilePic/${_nameTextController.text}').getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    setState(() {
      _emailTextController.text = _authData.email;
      email = _authData.email;
    });
    scaffoldMessage(message){
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    return _isLoading ? CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    ) : Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Vui lòng nhập tên';
                }
                setState(() {
                  _nameTextController.text=value;
                });
                setState(() {
                  name=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
                labelText: 'Tên',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              maxLength: 10, //depends on the country where u use the app
              validator: (value) {
                if (value.isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                setState(() {
                  mobile=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixText: '+84',
                prefixIcon: Icon(Icons.phone_android),
                labelText: 'Số điện thoại',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              enabled: false,
              controller: _emailTextController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
                labelText: 'Email',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              obscureText: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if(value.length < 6){
                  return 'Mật khẩu tối thiểu 6 ký tự';
                }
                setState(() {
                  password=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined),
                labelText: 'Mật khẩu mới',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              obscureText: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                }
                if(value.length < 6){
                  return 'Mật khẩu tối thiểu 6 ký tự';
                }
                if(_passwordTextController.text != _cPasswordTextController.text){
                  return 'Mật khẩu xác nhận không đúng';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined),
                labelText: 'Xác nhận mật khẩu',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextFormField(
              maxLines: 6,
              controller: _addressTextController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Vui lòng nhấn nút điều hướng';
                }
                if(_authData.shopLatitude == null){
                  return 'Vui lòng nhấn nút điều hướng';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.contact_mail_outlined),
                labelText: 'Địa chỉ',
                suffixIcon: IconButton(icon: Icon(Icons.location_searching),onPressed: (){
                  _addressTextController.text='Đang định vị...\n Vui lòng đợi...';
                  _authData.getCurrentAddress().then((address){
                    if(address!=null){
                      setState(() {
                        _addressTextController.text='${_authData.placeName}\n${_authData.shopAddress}';
                      });
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không tìm thấy địa chỉ. Vui lòng thử lại')));
                    }
                  });
                },),
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 2,
                      color: Theme.of(context).primaryColor
                  ),
                ),
                focusColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(height: 20,),
          Row(
            children: [
              Expanded(
                child: FlatButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    if(_authData.isPicAvail==true){
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          _isLoading=true;
                        });
                        _authData.registerBoys(email, password).then((credential){
                          if(credential.user.uid!=null){
                            uploadFile(_authData.image.path).then((url){
                              if(url!=null){
                                _authData.saveBoysDataToDb(
                                    url: url,
                                    mobile: mobile,
                                    name: name,
                                    password: password,
                                    context: context
                                );
                                setState(() {
                                  _isLoading=false;
                                });
                              }else{
                                scaffoldMessage('Tải ảnh hồ sơ thất bại');
                              }
                            });
                          }else{
                            scaffoldMessage(_authData.error);
                          }
                        });
                      }
                    }else{
                      scaffoldMessage('Ảnh hồ sơ đã được thêm');
                    }

                  },
                  child: Text(
                    'Đang kí',
                    style: TextStyle(color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              FlatButton(
                padding: EdgeInsets.zero,
                child: RichText(
                  text: TextSpan(
                      text: '',
                      children: [
                        TextSpan(
                          text: 'Đã có tài khoản ? ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Đăng nhập',
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),
                        ),
                      ]
                  ),
                ),
                onPressed: (){
                  Navigator.pushNamed(context, LoginScreen.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}