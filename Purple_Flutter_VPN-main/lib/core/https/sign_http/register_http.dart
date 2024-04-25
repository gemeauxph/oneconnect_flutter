import 'package:ndvpn/core/https/http_connection.dart';
import 'package:ndvpn/core/models/vpn_config.dart';

final class RegisterHttp extends HttpConnection {
  RegisterHttp(super.context);

  Future<dynamic> verifyEmail({
    required dynamic body,
  }) async {
    ApiResponse<dynamic> resp = await post<dynamic>('', body: body);
    if (resp.success ?? false) {
      return resp.data!.map<VpnConfig>((e) => VpnConfig.fromJson(e)).toList();
    }
    return [];
  }
}
