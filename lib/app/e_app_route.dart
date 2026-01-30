enum AppRoute {
  login('/blocs'),
  main('/'),
  profile('/profile'),
  chat('/chat');

  const AppRoute(this.path);
  final String path;
}