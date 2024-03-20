/*
 * @Author: Levi Li
 * @Date: 2024-03-20 13:18:58
 * @description: 
 */
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:cart/helper/http.dart';

class Fetch {
  // 单例
  static final Fetch _instance = Fetch._internal();
  Fetch._internal();

  factory Fetch() {
    return _instance;
  }

  // 请求方法
  // Future<T> request<T>(
  //     Future<Response<dynamic>> respFuture, T Function(dynamic) parser,
  //     {VoidCallback? finallyCallback}) async {}
}
