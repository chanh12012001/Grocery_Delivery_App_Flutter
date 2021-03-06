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
                  return 'Vui l??ng nh???p t??n';
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
                labelText: 'T??n',
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
                  return 'Vui l??ng nh???p s??? ??i???n tho???i';
                }
                setState(() {
                  mobile=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixText: '+84',
                prefixIcon: Icon(Icons.phone_android),
                labelText: 'S??? ??i???n tho???i',
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
                  return 'Vui l??ng nh???p m???t kh???u';
                }
                if(value.length < 6){
                  return 'M???t kh???u t???i thi???u 6 k?? t???';
                }
                setState(() {
                  password=value;
                });
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined),
                labelText: 'M???t kh???u m???i',
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
                  return 'Vui l??ng x??c nh???n m???t kh???u';
                }
                if(value.length < 6){
                  return 'M???t kh???u t???i thi???u 6 k?? t???';
                }
                if(_passwordTextController.text != _cPasswordTextController.text){
                  return 'M???t kh???u x??c nh???n kh??ng ????ng';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key_outlined),
                labelText: 'X??c nh???n m???t kh???u',
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
                  return 'Vui l??ng nh???n n??t ??i???u h?????ng';
                }
                if(_authData.shopLatitude == null){
                  return 'Vui l??ng nh???n n??t ??i???u h?????ng';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.contact_mail_outlined),
                labelText: '?????a ch???',
                suffixIcon: IconButton(icon: Icon(Icons.location_searching),onPressed: (){
                  _addressTextController.text='??ang ?????nh v???...\n Vui l??ng ?????i...';
                  _authData.getCurrentAddress().then((address){
                    if(address!=null){
                      setState(() {
                        _addressTextController.text='${_authData.placeName}\n${_authData.shopAddress}';
                      });
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kh??ng t??m th???y ?????a ch???. Vui l??ng th??? l???i')));
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
                                scaffoldMessage('T???i ???nh h??? s?? th???t b???i');
                              }
                            });
                          }else{
                            scaffoldMessage(_authData.error);
                          }
                        });
                      }
                    }else{
                      scaffoldMessage('???nh h??? s?? ???? ???????c th??m');
                    }

                  },
                  child: Text(
                    '??ang k??',
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
                          text: '???? c?? t??i kho???n ? ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: '????ng nh???p',
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