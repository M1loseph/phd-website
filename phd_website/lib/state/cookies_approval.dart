enum CookiesApproval {
  approved,
  rejected,
  awaitingApproval;

  static CookiesApproval parseFromStringOrGetDefault(String name) {
    return CookiesApproval.values.asNameMap()[name] ?? CookiesApproval.awaitingApproval;
  }
}
