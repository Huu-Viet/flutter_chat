enum AppRoute {
  login('/login'),
  main('/'),
  profile('/profile'),
  chat('/chat'),
  forgotPass('/forgot-password');

  const AppRoute(this.path);
  final String path;
}