class PageData {
  final String pageName;

  PageData({required this.pageName});
}

abstract class Event {
  Map<String, dynamic> toJson();
}

class UserOpenedAppEvent extends Event {
  final String _sessionId;
  final DateTime _timestamp;
  final String _environment;

  UserOpenedAppEvent(this._sessionId, this._timestamp, this._environment);

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventTime': _timestamp.millisecondsSinceEpoch,
      'sessionId': _sessionId,
      'environment': _environment,
    };
  }
}

class UserOpenedPageEvent extends Event {
  final String _sessionId;
  final DateTime _timestamp;
  final PageData _pageData;

  UserOpenedPageEvent(this._sessionId, this._timestamp, this._pageData);

  @override
  Map<String, dynamic> toJson() {
    return {
      'sessionId': _sessionId,
      'eventTime': '${_timestamp.toIso8601String()}Z',
      'pageName': _pageData.pageName,
    };
  }
}
