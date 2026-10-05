import 'package:flutter/foundation.dart';

/// Register this exact URL in Supabase Auth > URL Configuration.
const mobileAuthRedirectUrl = 'com.minthug.nextmate://login-callback/';

String get authRedirectUrl => kIsWeb
    ? Uri.base.toString().split('#').first.split('?').first
    : mobileAuthRedirectUrl;

/// Ignore unrelated app links, even if they contain OAuth-looking parameters.
bool isAuthCallbackUri(Uri uri) {
  final expected = Uri.parse(authRedirectUrl);
  if (uri.scheme != expected.scheme ||
      uri.host != expected.host ||
      uri.port != expected.port ||
      uri.path != expected.path ||
      uri.userInfo != expected.userInfo) {
    return false;
  }
  final fragment = Uri.splitQueryString(uri.fragment);
  return const [
    'code',
    'access_token',
    'error',
    'error_code',
    'error_description',
  ].any(
    (key) => uri.queryParameters.containsKey(key) || fragment.containsKey(key),
  );
}
