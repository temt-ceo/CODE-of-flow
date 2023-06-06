import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:CodeOfFlow/main.dart';
import 'package:CodeOfFlow/models/ModelProvider.dart';

class APIService {
  Future<GameServerProcess?> saveGameServerProcess(
      String type, String message, String playerId) async {
    try {
      GameServerProcess data = GameServerProcess(
        type: type,
        message: message,
        playerId: playerId,
      );
      final request = ModelMutations.create(data);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.data != null) {
        GameServerProcess? createdGameServerProcess = response.data;
        return createdGameServerProcess;
      } else {
        debugPrint('saveGameServerProcess error: $response');
        return null;
      }
    } on Exception catch (e) {
      debugPrint('saveGameServerProcess error: $e');
      return null;
    }
  }

  Future<List<GameServerProcess?>?> getGameServerProcesses() async {
    try {
      final request = ModelQueries.list(GameServerProcess.classType);
      final response = await Amplify.API.query(request: request).response;
      List<GameServerProcess?>? gameServerProcesses = response.data?.items;
      return gameServerProcesses;
    } on Exception catch (e) {
      debugPrint('getGameServerProcesses error: $e');
    }
    return null;
  }

  Future<void> subscribeBCGGameServerProcess() async {
    // const graphQLDocument = r'''
    //     subscription onCreateCommentByPostId($id: ID!) {
    //       onCommentByPostId(postCommentsId: $id) {
    //         content
    //         id
    //         postCommentsId
    //       }
    //     }
    //   ''';
    const graphQLDocument = r'''
      subscription OnCreateBCGGameServerProcess(
        $filter: ModelSubscriptionBCGGameServerProcessFilterInput
      ) {
        onCreateBCGGameServerProcess(filter: $filter) {
          id
          type
          message
          playerId
          createdAt
          updatedAt
        }
      }
      ''';
    final subscriptionRequest =
        ModelSubscriptions.onCreate(GameServerProcess.classType);
    final Stream<GraphQLResponse<GameServerProcess>> operation =
        Amplify.API.subscribe(
      subscriptionRequest,
      onEstablished: () => print('Subscription established'),
    );

    try {
      await for (var event in operation) {
        print('Subscription event data received: ${event.data}');
      }
    } on Exception catch (e) {
      print('Error in subscription stream: $e');
    }
  }
}
