/*
 * @Author: Levi Li
 * @Date: 2024-03-20 11:42:48
 * @description: 
 */
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

import 'package:cart/helper/env.dart';

class HttpClient {
  static final dio = Dio();
  static final cacheStore = MemCacheStore();

  static init() {
    Config config = getEnv();
    // 设置基础参数
    dio.options = BaseOptions(
      baseUrl: '${config.apiUrl}/${config.apiKey}',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // 添加缓存拦截器
    dio.interceptors.add(DioCacheInterceptor(
      options: CacheOptions(
        store: cacheStore,
        policy: CachePolicy.request, // 缓存策略，这里选择先请求网络，如果请求失败则返回缓存数据
        hitCacheOnErrorExcept: [401, 403], // 在除了401和403错误外的错误时，返回缓存数据
        priority: CachePriority.normal, // 缓存优先级
        maxStale: const Duration(days: 1), // 缓存的最长有效期
      ),
    ));

    // 添加请求重试拦截器
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: print, // 打印日志，用于调试
      retries: 3, // 重试次数
      retryDelays: const [
        Duration(seconds: 1), // 第一次重试延迟
        Duration(seconds: 2), // 第二次重试延迟
        Duration(seconds: 3), // 第三次重试延迟
      ],
    ));
  }

  // get请求
  static Future<Response> get(String url,
      {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(url, queryParameters: queryParameters);
  }

  // post json请求
  static Future<Response> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  }) async {
    final resp = await dio.post(
      url,
      queryParameters: queryParameters,
      data: data,
    );
    return resp;
  }

  // post FormData请求
  static Future<Response> postFormData(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
  }) async {
    final resp = await dio.post(
      url,
      queryParameters: queryParameters,
      data: formData != null ? FormData.fromMap(formData) : null,
    );
    return resp;
  }

  // put json请求
  static Future<Response> put(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  }) async {
    final resp = await dio.put(
      url,
      queryParameters: queryParameters,
      data: data,
    );
    return resp;
  }

  // put FormData请求
  static Future<Response> putFormData(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
  }) async {
    final resp = await dio.put(
      url,
      queryParameters: queryParameters,
      data: formData != null ? FormData.fromMap(formData) : null,
    );
    return resp;
  }

  // delete请求
  static Future<Response> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
  }) async {
    final resp = await dio.delete(
      url,
      queryParameters: queryParameters,
      data: formData != null ? FormData.fromMap(formData) : null,
    );

    return resp;
  }

  // 清除缓存方法
  Future<void> clearHttpCache() async {
    await cacheStore.clean();
  }

  // 关闭dio和清理缓存
  void dispose() {
    dio.close();
    cacheStore.clean();
  }
}
