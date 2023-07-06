import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/models/admin.dart';
import 'package:dairy_connect/models/user.dart';

abstract class LoginScreenContract {
  void onLoginSuccess(Admin user);
  void onLoginError(String errorTxt);
}

class LoginScreenPresenter {
  LoginScreenContract _view;
  RestDatasource api = new RestDatasource();
  LoginScreenPresenter(this._view);

  doLogin(String user_id, String _otpcode, String user_token) {
    api.login(user_id,_otpcode,user_token).then((Admin user) {
      _view.onLoginSuccess(user);
    }).catchError((Object error) => _view.onLoginError(error.toString()));
  }
}