class ConferenceDO {
  final String conferenceName;
  final Uri website;
  final String talkTitle;
  final DateTime date;
  final String location;

  ConferenceDO({
    required this.conferenceName,
    required String website,
    required this.talkTitle,
    required this.date,
    required this.location,
  }) : website = Uri.parse(website);
}
