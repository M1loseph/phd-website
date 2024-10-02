class ConferenceDO {
  final String conferenceName;
  final Uri website;
  final String talkTitle;
  final DateTime begin;
  final DateTime end;
  final String location;

  ConferenceDO({
    required this.conferenceName,
    required String website,
    required this.talkTitle,
    required this.begin,
    required this.end,
    required this.location,
  }) : website = Uri.parse(website);
}
