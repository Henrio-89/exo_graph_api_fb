// import 'dart:ffi';
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

          // Récupération des commentaires de chaque publication
          // final commentsUrl =
          //     'https://graph.facebook.com/v19.0/${postData['id']}/comments';
          // final commentsResponse = await http.get(
          //   Uri.parse(
          //       '$commentsUrl?fields=from,message,created_time&access_token=$accessToken'),
          // );

          // if (commentsResponse.statusCode == 200) {
          //   final commentsData = json.decode(commentsResponse.body);
          //   final List<dynamic> comments = commentsData['data'];

          //   // Pour chaque commentaire, récupérez également les informations sur l'utilisateur
          //   for (final comment in comments) {
          //     final userId = comment['from']['id'];
          //     final userUrl =
          //         'https://graph.facebook.com/v19.0/$userId?fields=picture';
          //     final userResponse = await http
          //         .get(Uri.parse('$userUrl&access_token=$accessToken'));
          //     if (userResponse.statusCode == 200) {
          //       final userData = json.decode(userResponse.body);
          //       final profilePictureUrl = userData['picture']['data']['url'];
          //       comment['profile_comment'] = profilePictureUrl;
          //     } else {
          //       comment['profile_comment'] =
          //           null; // ou '' selon votre préférence
          //     }
          //   }
          //   postData['comments'] = comments;
          // } else {
          //   postData['comments'] = null;
          // }

          // print( postData['comments']);

          // Récupération des likes pour chaque publication
          final likesUrl =
              'https://graph.facebook.com/v19.0/${postData['id']}?fields=likes.summary(true)';
          final likesResponse =
              await http.get(Uri.parse('$likesUrl&access_token=$accessToken'));

          if (likesResponse.statusCode == 200) {
            final likesData = json.decode(likesResponse.body);
            postData['likes'] = likesData['likes']['summary']['total_count'];
            postData['has_liked'] = likesData['likes']['summary']['has_liked'];
          } else {
            postData['likes'] = 0; // ou null si vous préférez
            postData['has_liked'] = false;
          }

          // Récupération des informations sur l'utilisateur qui a publié
          final userUrl =
              'https://graph.facebook.com/v19.0/${pageId}?fields=picture';
          final userResponse =
              await http.get(Uri.parse('$userUrl&access_token=$accessToken'));
          if (userResponse.statusCode == 200) {
            final userData = json.decode(userResponse.body);
            final profilePictureUrl = userData['picture']['data']['url'];
            postData['profile_picture'] = profilePictureUrl;
          } else {
            // Gérer l'erreur de récupération de l'image de profil
            postData['profile_picture'] = null; // ou '' selon votre préférence
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
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
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

  Future<void> likePost(String postId, bool likes) async {
    final graphApiUrl =
        Uri.parse('https://graph.facebook.com/v19.0/$postId/likes');

    final response = likes
        ? await http.post(
            graphApiUrl,
            headers: {
              HttpHeaders.authorizationHeader: accessToken,
              HttpHeaders.acceptHeader: 'application/json',
              HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
            },
            body: {'access_token': accessToken},
          )
        : await http.delete(
            graphApiUrl,
            headers: {
              HttpHeaders.authorizationHeader: accessToken,
              HttpHeaders.acceptHeader: 'application/json',
              HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
            },
            body: {'access_token': accessToken},
          );

    if (response.statusCode == 200) {
      if (likes) {
        print('Publication likée avec succès sur Facebook.');
      } else {
        print('Publication dislikée avec succès sur Facebook.');
      }
    } else {
      print(
          'Erreur lors de la manipulation de la publication sur Facebook: ${response.body}');
    }
  }
}
