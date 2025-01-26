// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev')
abstract class Env {
    // @EnviedField(varName: 'KEY1')
    // static const String key1 = _Env.key1;
    // @EnviedField()
    // static const String KEY2 = _Env.KEY2;
    // @EnviedField(defaultValue: 'test_')
    static const String SUPABASE_URL = _Env.SUPABASE_URL;
    static const String SUPABASE_ANON_KEY = _Env.SUPABASE_ANON_KEY;
    static const String GOOGLE_OAUTH_CLIENT_ID_WEB = _Env.GOOGLE_OAUTH_CLIENT_ID_WEB;
}