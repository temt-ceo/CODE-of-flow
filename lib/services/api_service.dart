import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:CodeOfFlow/main.dart';
import 'package:CodeOfFlow/models/ModelProvider.dart';

class APIService {
  Future<void> saveGameServerProcess(
      String type, String message, String playerId) async {
    try {
      GameServerProcess data = GameServerProcess(
        type: type,
        message: message,
        playerId: playerId,
      );
      final request = ModelMutations.create(data);
      print(request);
      final response = await Amplify.API.mutate(request: request).response;
      print(response);

      GameServerProcess? createdGameServerProcess = response.data;
      if (createdGameServerProcess == null) {
        return;
      }
    } on Exception catch (e) {
      debugPrint('saveGameServerProcess error: $e');
    }
  }

  Future<List<GameServerProcess?>?> getGameServerProcesses() async {
    try {
      final request = ModelQueries.list(GameServerProcess.classType);
      final response = await Amplify.API.query(request: request).response;
      List<GameServerProcess?>? expenseCategories = response.data?.items;
      return expenseCategories;
    } on Exception catch (e) {
      debugPrint('getGameServerProcesses error: $e');
    }
    return null;
  }
}
