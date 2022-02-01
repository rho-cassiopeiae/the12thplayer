import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/vm/account_vm.dart';
import '../bloc/account_actions.dart';
import '../bloc/account_bloc.dart';
import '../bloc/account_states.dart';
import '../../general/bloc/image_actions.dart';
import '../../general/bloc/image_bloc.dart';
import '../../general/bloc/image_states.dart';
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isOpen;
  PanelController _panelController;
  double _width;
  double _height;

  _ProfilePageState(this._accountBloc, this._imageBloc);

  @override
  void initState() {
    super.initState();
    _isOpen = false;
    _panelController = PanelController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
  }

  void _updateProfileImage(BuildContext context) async {
    var source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                child: Text('Gallery'),
                onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              SizedBox(height: 12.0),
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

    var pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile == null) {
      return;
    }

    var croppedFile = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: _width, ratioY: _width * 16.0 / 9.0),
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
    if (state.succeeded) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var action = LoadAccount();
    _accountBloc.dispatchAction(action);

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      body: FutureBuilder<LoadAccountState>(
        initialData: AccountLoading(),
        future: action.state,
        builder: (context, snapshot) {
          var state = snapshot.data;
          if (state is AccountLoading || state is AccountError) {
            return Center(child: CircularProgressIndicator());
          }

          var account = (state as AccountReady).account;

          var action = GetProfileImage(username: account.username);
          _imageBloc.dispatchAction(action);

          return Stack(
            fit: StackFit.expand,
            children: [
              FractionallySizedBox(
                alignment: Alignment.topCenter,
                heightFactor: 0.7,
                child: FutureBuilder<GetProfileImageState>(
                  initialData: ProfileImageLoading(),
                  future: action.state,
                  builder: (context, snapshot) {
                    var state = snapshot.data;
                    if (state is ProfileImageLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var imageFile = (state as ProfileImageReady).imageFile;
                    return InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(imageFile),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      onLongPress: () => _updateProfileImage(context),
                    );
                  },
                ),
              ),
              Positioned(
                top: 20.0,
                child: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: _scaffoldKey.currentState.openDrawer,
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: 0.3,
                child: Container(color: Colors.white),
              ),
              SlidingUpPanel(
                controller: _panelController,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32.0),
                  topLeft: Radius.circular(32.0),
                ),
                minHeight: _height * 0.35,
                maxHeight: _height * 0.85,
                panelBuilder: (controller) => _panelBody(controller, account),
                onPanelSlide: (value) {
                  if (value >= 0.2 && !_isOpen) {
                    setState(() => _isOpen = true);
                  }
                },
                onPanelClosed: () => setState(() => _isOpen = false),
              ),
            ],
          );
        },
      ),
    );
  }

  SingleChildScrollView _panelBody(
    ScrollController controller,
    AccountVm account,
  ) {
    return SingleChildScrollView(
      controller: controller,
      physics: ClampingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            height: _height * 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTitleSection(account),
                _buildInfoSection(),
                _buildActionSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column _buildTitleSection(AccountVm account) {
    return Column(
      children: [
        Text(
          account.username,
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.w700,
            fontSize: 30.0,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          account.email,
          style: GoogleFonts.openSans(
            fontStyle: FontStyle.italic,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Row _buildInfoSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoCell(title: 'Club', value: 'Rangers'),
        Container(
          width: 1.0,
          height: 40.0,
          color: Colors.grey,
        ),
        _buildInfoCell(title: 'Joined', value: '2035-03-24'),
        Container(
          width: 1.0,
          height: 40.0,
          color: Colors.grey,
        ),
        _buildInfoCell(title: 'Location', value: 'Moon base'),
      ],
    );
  }

  Column _buildInfoCell({String title, String value}) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.w300,
            fontSize: 14.0,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          value,
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.w700,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }

  Row _buildActionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Visibility(
          visible: !_isOpen,
          child: Expanded(
            child: OutlinedButton(
              child: Text(
                'EDIT PROFILE',
                style: GoogleFonts.openSans(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => _panelController.open(),
              style: ButtonStyle(
                side: MaterialStateProperty.all(
                  BorderSide(color: Colors.blue),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: !_isOpen,
          child: SizedBox(width: 16.0),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: _isOpen ? (_width - 80.0) / 1.6 : double.infinity,
              child: TextButton(
                child: Text(
                  'LOG OUT',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
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
}
