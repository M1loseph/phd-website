class Conference {
  final String conferenceName;
  final Uri website;
  final String talkTitle;
  final DateTime begin;
  final DateTime end;
  final String location;
  final String? details;

  Conference({
    required this.conferenceName,
    required String website,
    required this.talkTitle,
    required this.begin,
    required this.end,
    required this.location,
    this.details
  }) : website = Uri.parse(website) {
    assert(begin.isBefore(end) || begin == end);
  }
}
