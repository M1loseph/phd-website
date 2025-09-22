import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_status/http_status.dart';

class HttpTimeoutClient implements Client {
  static const Duration requestsTimeout = Duration(seconds: 5);
  static final Response timeoutResponse = Response(
    '',
    HttpStatusCode.requestTimeout,
  );

  final Client delegate;
  final Duration requestTimeout;

  HttpTimeoutClient(this.delegate, this.requestTimeout);

  @override
  void close() {
    delegate.close();
  }

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return delegate
        .delete(url, headers: headers, body: body, encoding: encoding)
        .timeout(requestTimeout, onTimeout: () => timeoutResponse);
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) {
    return delegate
        .get(url, headers: headers)
        .timeout(requestTimeout, onTimeout: () => timeoutResponse);
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    return delegate
        .head(url, headers: headers)
        .timeout(requestTimeout, onTimeout: () => timeoutResponse);
  }

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return delegate
        .patch(url, headers: headers, body: body, encoding: encoding)
        .timeout(requestTimeout, onTimeout: () => timeoutResponse);
  }

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return delegate
        .post(url, headers: headers, body: body, encoding: encoding)
        .timeout(requestTimeout, onTimeout: () => timeoutResponse);
  }

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return delegate
        .put(url, headers: headers, body: body, encoding: encoding)
        .timeout(requestTimeout, onTimeout: () => timeoutResponse);
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    return delegate.read(url, headers: headers).timeout(requestTimeout);
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    return delegate.readBytes(url, headers: headers).timeout(requestTimeout);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return delegate.send(request).timeout(requestTimeout);
  }
}
