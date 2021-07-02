import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_delivery_app_flutter/providers/auth_provider.dart';
import 'package:grocery_delivery_app_flutter/screens/home_screen.dart';
import 'package:grocery_delivery_app_flutter/screens/register_screen.dart';
import 'package:grocery_delivery_app_flutter/services/firebase_services.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  Icon icon;
  bool _visible = false;
  var _emailTextController = TextEditingController();
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/logo.png',
                              height: 80,
                            ),
                            FittedBox(
                              child: Text(
                                'DELIVERY APP - ĐĂNG NHẬP',
                                style: TextStyle(
                                  fontFamily: 'Anton',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _emailTextController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Vui lòng nhập Email';
                          }
                          final bool _isValid = EmailValidator.validate(_emailTextController.text);
                          if (!_isValid) {
                            return 'Email không đúng định dạng';
                          }
                          setState(() {
                            email = value;
                          });
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(),
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          focusColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu tối thiểu 6 ký tự';
                          }
                          setState(() {
                            password = value;
                          });
                          return null;
                        },
                        obscureText: _visible == false ? true : false,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: _visible
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _visible = !_visible;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(),
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Mật khẩu',
                            prefixIcon: Icon(Icons.vpn_key_outlined),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            focusColor: Theme.of(context).primaryColor),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      /*Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, ResetPassword.id);
                              },
                              child: Text(
                                'Forgot Password ? ',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),*/
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: FlatButton(
                              color: Theme.of(context).primaryColor,
                              child:Text(
                                'Đăng nhập',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  EasyLoading.show(status: 'Vui lòng đợi...');
                                  _services.validateUser(email).then((value) {
                                    if(value.exists){
                                      if(value['password'] == password){
                                        _authData.loginBoys(email, password).then((credential) {
                                          if (credential != null) {
                                            EasyLoading.showSuccess('Đăng nhập thành công').then((value){
                                              Navigator.pushReplacementNamed(
                                                  context, HomeScreen.id);
                                            });
                                          } else {
                                            EasyLoading.showInfo('Cần hoàn thành đăng kí thành viên').then((value){
                                              _authData.getEmail(email);
                                              Navigator.pushNamed(context, RegisterScreen.id);
                                            });
                                          }
                                        });
                                      }else{
                                        EasyLoading.showError('Mật khẩu không đúng');
                                      }
                                    }else{
                                      EasyLoading.showError('$email chưa đăng kí thành viên vận chuyển của chúng tôi');
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

