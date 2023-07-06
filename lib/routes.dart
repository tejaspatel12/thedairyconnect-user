
import 'package:flutter/material.dart';
import 'package:dairy_connect/screens/bottom_navigation/bottomnavigation_bar_controller.dart';
import 'package:dairy_connect/screens/calendar/calendar_screen.dart';
import 'package:dairy_connect/screens/calendar/calendar_subscription_screen.dart';
import 'package:dairy_connect/screens/home/home_screen.dart';
import 'package:dairy_connect/screens/invoice/invoice_list_screen.dart';
import 'package:dairy_connect/screens/invoice/invoice_screen.dart';
import 'package:dairy_connect/screens/invoice/invoice_view_screen.dart';
import 'package:dairy_connect/screens/login/check_screen.dart';
import 'package:dairy_connect/screens/login/forgot_password_pin_screen.dart';
import 'package:dairy_connect/screens/login/forgot_password_screen.dart';
import 'package:dairy_connect/screens/login/login_screen.dart';
import 'package:dairy_connect/screens/login/otp_screen.dart';
import 'package:dairy_connect/screens/more/changepassword/change_password_screen.dart';
import 'package:dairy_connect/screens/more/contact_us/contact_us_screen.dart';
import 'package:dairy_connect/screens/more/faq/faq_screen.dart';
import 'package:dairy_connect/screens/more/notification/notification_screen.dart';
import 'package:dairy_connect/screens/more/profile_screen.dart';
import 'package:dairy_connect/screens/order/order_screen.dart';
import 'package:dairy_connect/screens/order/push_subscription_screen.dart';
import 'package:dairy_connect/screens/order/resume_subscription_screen.dart';
import 'package:dairy_connect/screens/product/product/all_product_screen.dart';
import 'package:dairy_connect/screens/product/product/already_product_subscription_screen.dart';
import 'package:dairy_connect/screens/product/product/product_buyonce_screen.dart';
import 'package:dairy_connect/screens/product/product/product_subscription_screen.dart';
import 'package:dairy_connect/screens/register/register_done_screen.dart';
import 'package:dairy_connect/screens/register/register_first_screen.dart';
import 'package:dairy_connect/screens/register/register_otp_screen.dart';
import 'package:dairy_connect/screens/register/register_sec_screen.dart';
import 'package:dairy_connect/screens/register/register_thread_screen.dart';
import 'package:dairy_connect/screens/terms_condition/term_condition_screen.dart';
import 'package:dairy_connect/screens/wallet/balance_log_screen.dart';
import 'package:dairy_connect/screens/wallet/recharge_offer_screen.dart';
import 'package:dairy_connect/screens/wallet/wallet_screen.dart';
import 'main.dart';

final routes = {
  '/' :          (BuildContext context) => new SplashScreen(),
  // '/' :          (BuildContext context) => new RegisterThrScreen(),
  //Home
  '/login' :          (BuildContext context) => new LoginScreen(),
  '/otp' :          (BuildContext context) => new OTPScreen(),
  '/check' :          (BuildContext context) => new CheckScreen(),
  '/register' :          (BuildContext context) => new RegisterFirstScreen(),
  // '/registerotp' :          (BuildContext context) => new RegisterOTPScreen(),
  '/registersec' :          (BuildContext context) => new RegisterSecScreen(),
  // '/registerthr' :          (BuildContext context) => new RegisterThrScreen(),
  '/registerdone' :          (BuildContext context) => new RegisterDoneScreen(),

  '/forgotpassword' :          (BuildContext context) => new ForgotPassword(),
  '/forgot_password_pin' :          (BuildContext context) => new ForgotPasswordPin(),

  '/termscondition' :          (BuildContext context) => new TermsConditionScreen(),

  '/bottomhome' :          (BuildContext context) => new BottomNavigationBarController(),
  '/calendar' :          (BuildContext context) => new CalendarScreen(),
  '/calendardetail' :          (BuildContext context) => new CalendarSubscriptionScreen(),

  '/contactus' :          (BuildContext context) => new ContactUsScreen(),
  '/faq' :          (BuildContext context) => new FAQScreen(),
  '/mynotifications' :          (BuildContext context) => new NotificationScreen(),

  '/wallet' :          (BuildContext context) => new WalletScreen(),
  '/rechargeoffer' :          (BuildContext context) => new RechargeOfferScreen(),
  '/paymentlist' :          (BuildContext context) => new PaymentListScreen(),

  // '/invoice' :          (BuildContext context) => new InvoiceScreen(),
  '/invoice' :          (BuildContext context) => new InvoiceListScreen(),
  '/invoiceview' :          (BuildContext context) => new InvoiceViewScreen(),
  '/order' :          (BuildContext context) => new OrderScreen(),
  '/pushsubscription' :          (BuildContext context) => new PushSubscriptionScreen(),
  '/resumesubscription' :          (BuildContext context) => new ResumeSubscriptionScreen(),

  '/allproduct' :          (BuildContext context) => new AllProductScreen(),
  '/productsubscription' :          (BuildContext context) => new ProductSubscriptionDetailScreen(),
  '/alreadyproductsubscription' :          (BuildContext context) => new AlreadyProductSubscriptionDetailScreen(),
  '/productbuyonce' :          (BuildContext context) => new ProductBuyOnceDetailScreen(),

  '/profile' :          (BuildContext context) => new ProfileScreen(),
  '/changepassword' :          (BuildContext context) => new ChangePasswordScreen(),
  //Home
};