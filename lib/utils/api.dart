import 'dart:io';
import 'package:dio/dio.dart';

///http请求
class Api {
  Api._();

  static Dio dio = init();

  static Dio init() {
    Dio dio = Dio(BaseOptions(
//        baseUrl: 'http://192.168.0.110:8080/',
      baseUrl: 'http://qbt.qubaotang.cn/api/',
        connectTimeout: 10000,
        receiveTimeout: 10000
    ));
    //打印请求日志和结果
//    dio.interceptors.add(LogInterceptor(responseBody: false));
    return dio;
  }

  ///get请求
  static Future<T> get<T>(String url, {Map<String, dynamic> params, Options options}) async {
    return _send<T>(url, params: params, options: options, method: 'get');
  }

  ///post请求
  static Future<T> post<T>(String url, {Map<String, dynamic> params, Options options}) async {
    return _send<T>(url, params: params, options: options, method: 'post');
  }

  ///发起请求
  static Future<T> _send<T>(String url, {Map<String, dynamic> params, Options options, String method = 'get'}) async {
    if(options==null){
      options = Options(
          headers: {"AUTHORIZATION":"1"},
          contentType: ContentType.parse("application/x-www-form-urlencoded")
      );
    }
    Response<Map<String,dynamic>> response;
    try {
      if (method == 'get') {
        response = await dio.get<Map<String,dynamic>>(url, queryParameters: params, options: options);
      } else {
        response = await dio.post<Map<String,dynamic>>(url, queryParameters: params, options: options);
      }
    } on DioError catch (e) {
      if(e.type==DioErrorType.DEFAULT){
        if (e.error is SocketException) {
          return Future.error('远程计算机拒绝网络连接');
        } else if (e.error is HandshakeException) {
          return Future.error('请检查服务器是否支持http或者https');
        } else if (e.error is RangeError){
          return Future.error('请求url不合法，请以http://或者https://作为前缀');
        }else{
          return Future.error(e.error);
        }
      }else if(e.type==DioErrorType.RESPONSE){
        String message;
        switch(e.response.statusCode){
          case 400:
            message='请求异常';
            break;
          case 404:
            message='请求地址不存在';
            break;
          case 500:
            message='服务器错误';
            break;
          case 502:
            message='服务器未启动';
            break;
          case 504:
            message='服务器没有响应';
            break;
          default:
            message='未知异常:${e.response.statusCode}';
            break;
        }
        return Future.error(message);
      }
    } catch(e){
      Future.error("接口请求出错");
    }
    if(response==null||response.data==null){
      return Future.error('请求超时');
    }else {
      if(response.data['status']){
        return Future.value(response.data['data']);
      }else{
        return Future.error(response.data['error']);
      }
    }
  }
}