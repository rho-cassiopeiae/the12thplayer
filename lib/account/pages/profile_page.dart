import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/account_actions.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_states.dart';
import '../../general/bloc/image_actions.dart';
import '../../general/bloc/image_bloc.dart';
import '../../general/bloc/image_states.dart';
import '../../general/extensions/color_extension.dart';
import '../../general/extensions/kiwi_extension.dart';
import '../../general/widgets/app_drawer.dart';

class ProfilePage extends StatefulWidget
    with DependencyResolver2<AccountBloc, ImageBloc> {
  static const routeName = '/account/profile';

  @override
  _ProfilePageState createState() => _ProfilePageState(resolve1(), resolve2());
}

class _ProfilePageState extends State<ProfilePage> {
  final AccountBloc _accountBloc;
  final ImageBloc _imageBloc;

  ImagePicker _imagePicker;
  ImagePicker get imagePicker {
    if (_imagePicker == null) {
      _imagePicker = ImagePicker();
    }
    return _imagePicker;
  }

  _ProfilePageState(this._accountBloc, this._imageBloc);

  void _updateProfileImage(BuildContext context) async {
    var source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                child: Text('Gallery'),
                onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                child: Text('Camera'),
                onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) {
      return;
    }

    var pickedFile = await imagePicker.getImage(source: source);

    if (pickedFile == null) {
      return;
    }

    var croppedFile = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      cropStyle: CropStyle.circle,
      compressQuality: 100,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop the image',
        toolbarColor: Colors.white,
      ),
      iosUiSettings: IOSUiSettings(
        title: 'Crop the image',
        doneButtonTitle: 'Ok',
        cancelButtonTitle: 'Cancel',
      ),
    );

    if (croppedFile == null) {
      return;
    }

    var action = UpdateProfileImage(imageFile: croppedFile);
    _accountBloc.dispatchAction(action);

    var state = await action.state;
    if (state is UpdateProfileImageError) {
      var snackBar = SnackBar(
        content: Text(state.message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var action = LoadAccount();
    _accountBloc.dispatchAction(action);

    return Scaffold(
      backgroundColor: HexColor.fromHex('023e8a'),
      appBar: AppBar(
        backgroundColor: HexColor.fromHex('023e8a'),
        title: Text(
          'The 12th Player',
          style: GoogleFonts.teko(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<AccountState>(
              initialData: AccountLoading(),
              future: action.state,
              builder: (context, snapshot) {
                var state = snapshot.data;
                if (state is AccountLoading || state is AccountError) {
                  return CircularProgressIndicator();
                }

                var account = (state as AccountReady).account;

                var action = GetProfileImage(username: account.username);
                _imageBloc.dispatchAction(action);

                return Row(
                  children: [
                    FutureBuilder<ImageState>(
                      initialData: ImageLoading(),
                      future: action.state,
                      builder: (context, snapshot) {
                        var state = snapshot.data;
                        if (state is ImageLoading) {
                          return CircleAvatar(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var imageFile = (state as ImageReady).imageFile;
                        return InkWell(
                          child: CircleAvatar(
                            backgroundImage: FileImage(imageFile),
                          ),
                          onTap: () => _updateProfileImage(context),
                        );
                      },
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(account.email),
                          Text(account.username),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
