import 'package:dart_mcp_pub_consultant/dart_mcp_pub_consultant.dart';

void main() {
  MCPPubConsultant server = MCPPubConsultant();
  server.start().then(
    (_) async {
      print("[MCPPubConsultant] server started");
    },
  ).catchError(
    (error) {
      print(
          '[MCPPubConsultant] Failed to start Dart PubConsultant MCP Server: $error');
    },
  );
}
