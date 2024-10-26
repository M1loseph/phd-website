class Publication {
  final String title;
  final Uri archiveUri;
  final DateTime publicationDate;
  final List<String> coauthors;

  Publication({
    required this.title,
    required String archiveUri,
    required this.publicationDate,
    required this.coauthors,
  }) : archiveUri = Uri.parse(archiveUri);
}
