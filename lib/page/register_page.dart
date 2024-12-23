import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:konnekt/model/user_profile.dart';
import 'package:konnekt/services/alert_service.dart';
import 'package:konnekt/services/auth_service.dart';
import 'package:konnekt/services/media_service.dart';
import 'package:konnekt/services/navigation_service.dart';
import 'package:konnekt/services/storage_service.dart';

import '../consts.dart';
import '../services/database_service.dart';
import '../widgets/custom_form_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _formKey = GlobalKey();

  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AuthService _authService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;

  File? selectedImage;
  String? _name, _email, _password;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 20,
        ),
        child: Column(
          children: [
            _headerText(),
            if (!isLoading) _registrationForm(),
            if (!isLoading) _loginAccountLink(),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s get going!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Register an account using the form below!',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registrationForm() {
    return Container(
        height: MediaQuery.sizeOf(context).height * 0.6,
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.05,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _pfpSelection(),
              CustomFormField(
                hintText: 'Name',
                height: MediaQuery.of(context).size.height * 0.1,
                validationRegex: NAME_VALIDATION_REGEX,
                onSaved: (value) {
                  _name = value;
                },
              ),
              CustomFormField(
                hintText: 'Email',
                height: MediaQuery.of(context).size.height * 0.1,
                validationRegex: EMAIL_VALIDATION_REGEX,
                obscureText: false,
                onSaved: (value) {
                  _email = value;
                },
              ),
              CustomFormField(
                hintText: 'Password',
                height: MediaQuery.of(context).size.height * 0.1,
                validationRegex: PASSWORD_VALIDATION_REGEX,
                obscureText: true,
                onSaved: (value) {
                  _password = value;
                },
              ),
              _registerButton(),
            ],
          ),
        ));
  }

  Widget _pfpSelection() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.sizeOf(context).width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP),
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        color: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if ((_formKey.currentState?.validate() ?? false) &&
                selectedImage != null) {
              _formKey.currentState?.save();
              bool? result = await _authService.signUp(
                _email!,
                _password!,
              );
              if (result) {
                bool? imageUploaded = await _storageService.uploadPFP(
                  selectedImage!,
                  _authService.user!.uid,
                );
                if (imageUploaded) {
                  String? uploadedImageUrl = _storageService.uploadedImageUrl;
                  if (uploadedImageUrl != null) {
                    _databaseService.createUserProfile(
                      userProfile: UserProfile(
                        uid: _authService.user!.uid,
                        name: _name,
                        pfpURL: uploadedImageUrl,
                      ),
                    );
                    _alertService.showToast(
                      text: 'Registration successful!',
                      icon: Icons.check,
                    );
                    _navigationService.goBack();
                    _navigationService.pushReplacementNamed('/home');
                  }else{
                    _alertService.showToast(
                      text: 'Unable to upload profile picture, please try again!',
                      icon: Icons.error,
                    );
                    throw Exception('Failed to upload profile picture');
                  }
                }
              } else {
                _alertService.showToast(
                  text: 'Failed to register, please try again!',
                  icon: Icons.error,
                );
                throw Exception('Failed to register user');
              }
            }
          } catch (error) {
            print(error);
            _alertService.showToast(
              text: 'Failed to register, please try again!',
              icon: Icons.error,
            );
          }
          setState(() {
            isLoading = false;
          });
        },
        child: const Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _loginAccountLink() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('Already have an account?  '),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              'Sign In',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        ],
      ),
    );
  }
}
