// import 'package:dairy_connect/data/rest_ds.dart';
// import 'package:dairy_connect/models/admin.dart';
// import 'package:dairy_connect/models/user.dart';
//
// abstract class RegisterScreenContract {
//   void onLoginSuccess(Admin user);
//   void onLoginError(String errorTxt);
// }
//
// class RegisterScreenPresenter {
//   RegisterScreenContract _view;
//   RestDatasource api = new RestDatasource();
//   RegisterScreenPresenter(this._view);
//
//   doLogin(String user_id,String address, String _pickedLocation) {
//     api.login2(user_id,address,_pickedLocation).then((Admin user) {
//       _view.onLoginSuccess(user);
//     }).catchError((Object error) => _view.onLoginError(error.toString()));
//   }
// }