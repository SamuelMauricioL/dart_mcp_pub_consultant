import 'dart:convert';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:http/http.dart' as http;

class MCPPubConsultant {
  final McpServer server;

  MCPPubConsultant()
      : server = McpServer(
          Implementation(
            name: "Dart-Pub-Consultant",
            version: "1.0.0",
          ),
          options: ServerOptions(
            capabilities: ServerCapabilities(
              resources: ServerCapabilitiesResources(),
              tools: ServerCapabilitiesTools(),
            ),
          ),
        ) {
    registerGetLastPackageVersionInfoHandler();
    registerGetPackageInfoByVersionHandler();
    registerReturnSamePackageHandler();
  }

  void registerGetLastPackageVersionInfoHandler() {
    server.tool(
      "getLastPackageVersionInfo",
      description: 'Get last dart/flutter package version info',
      inputSchemaProperties: {
        'packageName': {'type': 'string'},
      },
      callback: ({args, extra}) async {
        try {
          final packageName = args?['packageName'];
          final packageInfo = await _requestPackageInfo(packageName);

          return CallToolResult.fromContent(
            content: [
              TextContent(
                text: "packageName $packageName exists",
              ),
              TextContent(
                text: "latest version info: ${packageInfo["latest"]}",
              ),
            ],
          );
        } catch (e) {
          return CallToolResult.fromContent(
            content: [
              TextContent(
                text: "packageName ${args?['packageName']} does not exist",
              ),
            ],
          );
        }
      },
    );
  }

  void registerGetPackageInfoByVersionHandler() {
    server.tool(
      "getPackageInfoByVersion",
      description: 'Get dart/flutter package info by version',
      inputSchemaProperties: {
        'packageName': {'type': 'string'},
        'version': {'type': 'string'},
      },
      callback: ({args, extra}) async {
        try {
          final packageName = args?['packageName'];
          final version = args?['version'];
          final packageInfo = await _requestPackageInfo(
            packageName,
            version: version,
          );

          return CallToolResult.fromContent(
            content: [
              TextContent(
                text: "packageName $packageName exists",
              ),
              TextContent(
                text: "version info: $packageInfo",
              ),
            ],
          );
        } catch (e) {
          return CallToolResult.fromContent(
            content: [
              TextContent(
                text: "packageName ${args?['packageName']} does not exist",
              ),
            ],
          );
        }
      },
    );
  }

  void registerReturnSamePackageHandler() {
    server.tool(
      "returnSamePackage",
      description: 'Return same dart/flutter package',
      inputSchemaProperties: {
        'packageName': {'type': 'string'},
      },
      callback: ({args, extra}) async {
        return CallToolResult.fromContent(
          content: [
            TextContent(
              text: "packageName ${args?['packageName']}",
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _requestPackageInfo(
    String packageName, {
    String? version,
  }) async {
    late final Uri url;
    if (version != null) {
      url = Uri.parse('https://pub.dev/api/packages/$packageName/$version');
    } else {
      url = Uri.parse('https://pub.dev/api/packages/$packageName');
    }

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as Map<String, dynamic>;
    } else if (response.statusCode == 404) {
      throw Exception('Package $packageName does not exist');
    } else {
      throw Exception('Error checking package: ${response.statusCode}');
    }
  }

  Future<void> start() async {
    await server.connect(StdioServerTransport());
  }
}
