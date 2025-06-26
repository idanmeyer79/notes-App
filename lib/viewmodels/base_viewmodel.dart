import 'package:flutter/foundation.dart';

enum ViewState { idle, loading, success, error }

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  bool _disposed = false;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get hasError => _state == ViewState.error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  void setLoading() {
    setState(ViewState.loading);
  }

  void setSuccess() {
    setState(ViewState.success);
  }

  void setError(String message) {
    _errorMessage = message;
    setState(ViewState.error);
  }

  void clearError() {
    _errorMessage = null;
    if (_state == ViewState.error) {
      setState(ViewState.idle);
    }
  }

  Future<T> executeAsync<T>(Future<T> Function() operation) async {
    try {
      setLoading();
      clearError();

      final result = await operation();

      setSuccess();
      return result;
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }
}
