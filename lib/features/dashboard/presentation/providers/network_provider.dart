import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum NetworkState { 
  normal,
  offline,
  reconnected
}

class NetworkProvider extends ChangeNotifier {
  NetworkState _state = NetworkState.normal;
  bool _isFirstCheck = true; 
  StreamSubscription<InternetStatus>? _subscription;

  NetworkState get state => _state;

  NetworkProvider() {
    _startListening();
  }

  void _startListening() {
    _subscription = InternetConnection().onStatusChange.listen((InternetStatus status) {
      if (status == InternetStatus.disconnected) {
        _state = NetworkState.offline;
        _isFirstCheck = false;
        notifyListeners();
      } 
      else if (status == InternetStatus.connected) {
        if (!_isFirstCheck) {
          _state = NetworkState.reconnected;
          notifyListeners();

          Future.delayed(const Duration(seconds: 3), () {
            _state = NetworkState.normal;
            notifyListeners();
          });
        } else {
          _state = NetworkState.normal;
          _isFirstCheck = false;
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}