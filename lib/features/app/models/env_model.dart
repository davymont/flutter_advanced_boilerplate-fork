import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_boilerplate/modules/hive/encrypted_hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'env_model.freezed.dart';
part 'env_model.g.dart';

@freezed
@singleton
@preResolve
class EnvModel with _$EnvModel {
  factory EnvModel({
    required String env,
    required bool debug,
    required bool debugShowCheckedModeBanner,
    required bool debugShowMaterialGrid,
    required bool debugApiClient,
    required String restApiUrl,
    required String graphQLApiUrl,
  }) = _EnvModel;

  EnvModel._();

  factory EnvModel.fromJson(Map<String, dynamic> json) => _$EnvModelFromJson(json);

  @factoryMethod
  static Future<EnvModel> create() async {
    var env = const String.fromEnvironment('APP_ENV', defaultValue: 'dev');

    if (env == 'test' || env == 'dev') {
      final encryptedHiveBox = (await EncryptedHive.create<String>('env')).encryptedHiveBox;

      final savedEnv = encryptedHiveBox.get('env');
      if (savedEnv != null) {
        env = savedEnv;
      }
    }

    final rawEnvData = await rootBundle.loadString(
      'assets/configs/$env.json',
    );
    final jsonEnvData = jsonDecode(rawEnvData) as Map<String, dynamic>;

    return EnvModel.fromJson(jsonEnvData);
  }

  bool get isRelease => env.split('_').contains('release');
}
