class Publication {
  final String title;
  final Uri publicationUri;
  final Uri? preprintUri;
  final DateTime publicationDate;
  final List<String> coauthors;

  Publication({
    required this.title,
    required String publicationUri,
    String? preprintUri,
    required this.publicationDate,
    required this.coauthors,
  }) : publicationUri = Uri.parse(publicationUri),
       preprintUri = preprintUri == null ? null : Uri.parse(preprintUri);
}
