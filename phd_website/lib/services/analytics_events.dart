class PageData {
  final String pageName;

  PageData({required this.pageName});
}

abstract class Event {
  Map<String, dynamic> toJson();
}

class AppOpenedEvent extends Event {
  final DateTime _timestamp;
  final String _environment;
  final String _appVersion;

  AppOpenedEvent(
    this._timestamp,
    this._environment,
    this._appVersion,
  );

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventTime': _timestamp.toIso8601StringWithZ(),
      'environment': _environment,
      'appVersion': _appVersion,
    };
  }
}

class AppOpenedEventResponse {
  final String sessionId;

  AppOpenedEventResponse({
    required this.sessionId,
  });

  static AppOpenedEventResponse fromJson(Map<String, dynamic> json) {
    return AppOpenedEventResponse(
      sessionId: json['sessionId'],
    );
  }
}

class PageOpenedEvent extends Event {
  final String _sessionId;
  final DateTime _timestamp;
  final PageData _pageData;

  PageOpenedEvent(this._sessionId, this._timestamp, this._pageData);

  @override
  Map<String, dynamic> toJson() {
    return {
      'sessionId': _sessionId,
      'eventTime': _timestamp.toIso8601StringWithZ(),
      'pageName': _pageData.pageName,
    };
  }
}

extension on DateTime {
  String toIso8601StringWithZ() {
    return '${toIso8601String()}Z';
  }
}
