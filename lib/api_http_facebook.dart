import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiHttpFacebook {
  final String accessToken;
  final String pageId;

  ApiHttpFacebook(this.accessToken, this.pageId);
  bool _errorDialogShown = false;

  Future<void> createPost(String message) async {
    final graphApiUrl =
        Uri.parse('https://graph.facebook.com/v19.0/$pageId/feed');
    final response = await http.post(
      graphApiUrl,
      headers: {
        HttpHeaders.authorizationHeader: accessToken,
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
      },
      body: {'message': message, 'access_token': accessToken},
    );

    if (response.statusCode == 200) {
      print('Publication créée avec succès sur Facebook.');
    } else {
      print(
          'Erreur lors de la création de la publication sur Facebook: ${response.body}');
    }
  }

  Future<void> createComment(String postId, String comment) async {
    final graphApiUrl =
        Uri.parse('https://graph.facebook.com/v19.0/$postId/comments');
    final response = await http.post(
      graphApiUrl,
      headers: {
        HttpHeaders.authorizationHeader: accessToken,
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
      },
      body: {
        'message': comment,
        'access_token': accessToken,
      },
    );

    if (response.statusCode == 200) {
      print('Commentaire créé avec succès sur Facebook.');
    } else {
      print(
          'Erreur lors de la création du commentaire sur Facebook: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPosts(BuildContext context) async {
    final graphApiUrl =
        Uri.parse('https://graph.facebook.com/v19.0/$pageId/feed');
    final response =
        await http.get(Uri.parse('$graphApiUrl?access_token=$accessToken'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final posts = jsonData['data'] as List<dynamic>?;

      if (posts != null) {
        return Future.wait(posts.map((post) async {
          final Map<String, dynamic> postData = Map<String, dynamic>.from(post);
          final attachmentsUrl =
              'https://graph.facebook.com/v19.0/${postData['id']}/attachments';
          final attachmentsResponse = await http
              .get(Uri.parse('$attachmentsUrl?access_token=$accessToken'));

          if (attachmentsResponse.statusCode == 200) {
            final attachmentsData = json.decode(attachmentsResponse.body);
            postData['attachments'] = attachmentsData['data'];
          } else {
            postData['attachments'] = null;
          }

          // Récupération des commentaires de chaque publication
          final commentsUrl =
              'https://graph.facebook.com/v19.0/${postData['id']}/comments';
          final commentsResponse = await http
              .get(Uri.parse('$commentsUrl?access_token=$accessToken'));

          if (commentsResponse.statusCode == 200) {
            final commentsData = json.decode(commentsResponse.body);
            postData['comments'] = commentsData['data'];
          } else {
            postData['comments'] = null;
          }

          return postData;
        }).toList());
      }
    }
    if (response.statusCode == 400) {
      // Vérifie si la boîte de dialogue n'a pas déjà été affichée
      if (!_errorDialogShown) {
        // Affiche une boîte de dialogue pour informer de l'erreur de token
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "HTTP 401 - Unauthorized",
                style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),
              ),
              content: const Text(
                "Erreur d'authentification, le token d'accès est expiré ou invalide.",
                style: TextStyle(color: Colors.grey),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            );
          },
        );
        _errorDialogShown = true;
      }
    }
    return [];
  }

  Future<void> deletePost(String postId, BuildContext context) async {
    final graphApiUrl = Uri.parse('https://graph.facebook.com/v19.0/$postId');
    final response =
        await http.delete(Uri.parse('$graphApiUrl?access_token=$accessToken'));
    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Succès', style: TextStyle(color: Colors.green)),
            content: const Text('Publication est supprimé avec succès.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    } else {
      throw Exception('Échec de la suppression du post.');
    }
  }
}
