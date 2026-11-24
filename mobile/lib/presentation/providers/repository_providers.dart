import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/category_remote_datasource.dart';
import '../../data/datasources/remote/transaction_remote_datasource.dart';
import '../../data/datasources/remote/transfer_remote_datasource.dart';
import '../../data/datasources/remote/wallet_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/transfer_repository_impl.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../domain/repositories/wallet_repository.dart';

final dioProvider = Provider((ref) => DioClient.instance.dio);

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authLocalDataSourceProvider = Provider(
  (ref) => AuthLocalDataSource(ref.watch(secureStorageProvider)),
);

final authRemoteDataSourceProvider = Provider(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);

final categoryRemoteDataSourceProvider = Provider(
  (ref) => CategoryRemoteDataSource(ref.watch(dioProvider)),
);

final walletRemoteDataSourceProvider = Provider(
  (ref) => WalletRemoteDataSource(ref.watch(dioProvider)),
);

final transactionRemoteDataSourceProvider = Provider(
  (ref) => TransactionRemoteDataSource(ref.watch(dioProvider)),
);

final transferRemoteDataSourceProvider = Provider(
  (ref) => TransferRemoteDataSource(ref.watch(dioProvider)),
);

final reportRemoteDataSourceProvider = Provider(
  (ref) => ReportRemoteDataSource(ref.watch(dioProvider)),
);

// Repositories
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  ),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.watch(categoryRemoteDataSourceProvider)),
);

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepositoryImpl(ref.watch(walletRemoteDataSourceProvider)),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(ref.watch(transactionRemoteDataSourceProvider)),
);

final transferRepositoryProvider = Provider<TransferRepository>(
  (ref) => TransferRepositoryImpl(ref.watch(transferRemoteDataSourceProvider)),
);

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepositoryImpl(ref.watch(reportRemoteDataSourceProvider)),
);
