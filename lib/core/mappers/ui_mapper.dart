abstract class UIMapper<TDomain, TUI> {
  TUI toUI(TDomain domain);

  TUI? tryToUI(TDomain? domain) {
    if (domain == null) return null;
    return toUI(domain);
  }

  List<TUI> toUIList(List<TDomain> domains) {
    return domains.map((domain) => toUI(domain)).toList();
  }
}
