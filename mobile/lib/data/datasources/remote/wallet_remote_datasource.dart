import 'package:dio/dio.dart';
import '../../models/wallet_model.dart';

class WalletRemoteDataSource {
  final Dio _dio;
  const WalletRemoteDataSource(this._dio);

  Future<List<WalletModel>> getWallets() async {
    final response = await _dio.get('/wallets');
    return (response.data as List)
        .map((e) => WalletModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WalletSummaryModel> getWalletSummary() async {
    final response = await _dio.get('/wallets/summary');
    return WalletSummaryModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WalletModel> getWallet(String id) async {
    final response = await _dio.get('/wallets/$id');
    return WalletModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WalletModel> createWallet({
    required String name,
    required String type,
    required double initialBalance,
    String currency = 'IDR',
    String color = '#4A90E2',
    String icon = 'wallet',
  }) async {
    final response = await _dio.post('/wallets', data: {
      'name': name,
      'type': type,
      'initial_balance': initialBalance,
      'currency': currency,
      'color': color,
      'icon': icon,
    });
    return WalletModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WalletModel> updateWallet({
    required String id,
    String? name,
    String? color,
    String? icon,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (color != null) data['color'] = color;
    if (icon != null) data['icon'] = icon;
    final response = await _dio.put('/wallets/$id', data: data);
    return WalletModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deactivateWallet(String id) async {
    await _dio.delete('/wallets/$id');
  }
}
