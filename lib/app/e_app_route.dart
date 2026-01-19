enum AppRoute {
  login('/blocs'),
  main('/'),
  profile('/profile');

  const AppRoute(this.path);
  final String path;
}