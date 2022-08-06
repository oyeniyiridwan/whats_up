import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsup/authentication.dart';

class AuthCard extends StatefulWidget {
  final Function submit;
  bool isLoading;
  AuthCard({Key? key, required this.isLoading, required this.submit})
      : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  bool active = true;
  bool active2 = false;
  void _switchMode() {
    if (_select == Select.signup) {
      setState(() {
        _select = Select.login;
      });
      _controller.forward();
    } else {
      setState(() {
        _select = Select.signup;
      });
      _controller.reverse();
    }
  }

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));

  late final Animation<double> _opacity = Tween(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  late final Animation<Offset> _offset =
      Tween(begin: const Offset(0.0, -0.5), end: const Offset(0.0, 0.0))
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

  Select _select = Select.login;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final FocusNode _focus = FocusNode();
  final FocusNode _focus2 = FocusNode();
  final FocusNode _focus3 = FocusNode();
  final FocusNode _focus4 = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey();
  var data = {"email": "", "password": "", "username": ""};
  final TextEditingController _passwordController = TextEditingController();
  void _trySubmit() {
    if (_imagePath == "" && _select == Select.signup) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Pls add image..."),
      ));
      return;
    }
    final isValid = _formKey.currentState!.validate();
    // && _imagePath != null;
    if (isValid) {
      _formKey.currentState!.save();
      widget.submit(data["email"], data["username"], data["password"], _select,
          File(_imagePath), context);
    }
  }

  var _imagePath = "";
  void _imageCamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      _saveImage(_imagePath);
    }
  }

  void _imageGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      _saveImage(_imagePath);
    }
  }

  //@override
  // void didChangeDependencies() {
  //   _loadImage();
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              "What's Up",
              style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 50,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold),
            ),
            Icon(
              Icons.messenger,
              color: Colors.white,
            )
          ],
        ),
        Flexible(
          flex: 1,
          child: AnimatedContainer(
            duration: const Duration(seconds: 1),
            height: _select == Select.login ? 0 : 100,
            child: FadeTransition(
              opacity: _opacity,
              child: GestureDetector(
                onTap: () {
                  _showDialog();
                },
                child: _imagePath != ""
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(File(_imagePath)))
                    : const CircleAvatar(
                        radius: 50,
                        child: Icon(
                          Icons.person,
                          size: 50,
                        ),
                      ),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: AnimatedContainer(
                  curve: Curves.easeIn,
                  height: _select == Select.login ? 290 : 434,
                  duration: const Duration(seconds: 1),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          onFieldSubmitted: (_) {
                            if (_select == Select.login) {
                              FocusScope.of(context).requestFocus(_focus3);
                            } else {
                              FocusScope.of(context).requestFocus(_focus2);
                            }
                          },
                          focusNode: _focus,
                          onSaved: (value) {
                            data["email"] = value!.trim();
                          },
                          validator: (value) {
                            if (value == null || !value.contains("@")) {
                              return "Invalid email";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: "e-mail",
                          ),
                        ),
                        AnimatedContainer(
                          height: _select == Select.signup ? 70 : 0,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeIn,
                          child: FadeTransition(
                            opacity: _opacity,
                            child: SlideTransition(
                              position: _offset,
                              child: TextFormField(
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_focus3);
                                },
                                focusNode: _focus2,
                                onSaved: (value) {
                                  data["username"] = value!.trim();
                                },
                                validator: _select == Select.signup
                                    ? (value) {
                                        if (value!.length < 4) {
                                          return "unknown username";
                                        }
                                        return null;
                                      }
                                    : (value) {
                                        return null;
                                      },
                                decoration: const InputDecoration(
                                  labelText: "username",
                                ),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                            onSaved: (value) {
                              data["password"] = value!.trim();
                            },
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return " password length is not accepted";
                              }
                              return null;
                            },
                            controller: _passwordController,
                            onFieldSubmitted: (_) {
                              if (_select == Select.signup) {
                                FocusScope.of(context).requestFocus(_focus4);
                              } else {
                                FocusScope.of(context).unfocus();
                              }
                            },
                            focusNode: _focus3,
                            obscureText: active,
                            decoration: InputDecoration(
                                labelText: "password",
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      active = !active;
                                    });
                                  },
                                  icon: Icon(
                                    active
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 15,
                                  ),
                                ))),
                        AnimatedContainer(
                          height: _select == Select.signup ? 70 : 0,
                          curve: Curves.easeIn,
                          duration: const Duration(seconds: 1),
                          child: SlideTransition(
                            position: _offset,
                            child: FadeTransition(
                              opacity: _opacity,
                              child: TextFormField(
                                  validator: _select == Select.signup
                                      ? (value) {
                                          if (value !=
                                              _passwordController.text) {
                                            return "password mismatched";
                                          }
                                          return null;
                                        }
                                      : (_) {
                                          return null;
                                        },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).unfocus();
                                  },
                                  focusNode: _focus4,
                                  obscureText: active2,
                                  decoration: InputDecoration(
                                      labelText: "Confirm password",
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            active2 = !active2;
                                          });
                                        },
                                        icon: Icon(
                                          active2
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          size: 15,
                                        ),
                                      ))),
                            ),
                          ),
                        ),
                        widget.isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: ElevatedButton(
                                  child: Text(
                                    _select == Select.login
                                        ? "Login"
                                        : "SignUp",
                                  ),
                                  onPressed: () {
                                    _trySubmit();
                                  },
                                ),
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              child: Text(
                                "Login Instead",
                                style: TextStyle(
                                    color: _select == Select.login
                                        ? Colors.grey
                                        : Colors.greenAccent),
                              ),
                              onPressed: () {
                                if (_select == Select.signup &&
                                    widget.isLoading != true) {
                                  setState(() {
                                    _select = Select.login;
                                  });
                                  _controller.reverse();
                                }
                              },
                            ),
                            TextButton(
                              child: Text(
                                "SignUp Instead",
                                style: TextStyle(
                                    color: _select == Select.signup
                                        ? Colors.grey
                                        : Colors.greenAccent),
                              ),
                              onPressed: () {
                                if (_select == Select.login &&
                                    widget.isLoading != true) {
                                  setState(() {
                                    _select = Select.signup;
                                    _controller.forward();
                                  });
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future _showDialog() {
    return showDialog(
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text("Select..."),
              content: SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        _imageCamera();
                        Navigator.of(context).pop();
                      },
                      child: const Text("Camera"),
                    ),
                    TextButton(
                      onPressed: () {
                        _imageGallery();
                        Navigator.of(context).pop();
                      },
                      child: const Text("Gallery"),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
        context: context);
  }

  void _saveImage(String path) async {
    var save = await SharedPreferences.getInstance();
    save.setString("imagePath", path);
  }

  // void _loadImage() async {
  //   var load = await SharedPreferences.getInstance();
  //   _imagePath = load.getString("imagePath")!;
  // }
}
