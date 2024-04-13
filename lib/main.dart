import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_http_facebook.dart';

const String accessTokens =
    "EAAF3TuYVsJABO2TbwN4hcpKGHOKGA0ZCZAs3uWHjigFiN0X1MfQ93LLA7pGGzLYpTqQ3xSeTZAnOaI00gbh0VOIBAlMvEicDCiOuH5qwnZAhfJYqfII9crewaZAxMZAfNnQIXwoHyAClNftbE4ZA2ZBrTGZBKZCMUZBeof1oxYLPjaFn6HZAMcyB2BHCZBXZB8GyZClRAzZAekh8fWUN1jwfpU837CuiX2ipBQZDZD";
const String pageId = '309241738930334';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion de Page Facebook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final ApiHttpFacebook facebookApi = ApiHttpFacebook(accessTokens, pageId);
  List<Map<String, dynamic>> _posts = [];
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    initPublish();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Image.asset(
              "web/images/facebook.png",
              width: 70,
              height: 70,
            ),
            const SizedBox(width: 8),
            const Text(
              'Publishing Facebook',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      post['message'] ?? post['story'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await facebookApi.deletePost(
                                          post['id'], context);
                                      final posts =
                                          await facebookApi.fetchPosts(context);
                                      setState(() {
                                        _posts = posts;
                                        _textEditingController.text = "";
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                    color: Colors.grey, // Couleur de l'icône
                                  ),
                                ],
                              ),
                              Text(
                                _formatDateTime(post['created_time']),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              if (post['attachments'] != null &&
                                  post['attachments'].isNotEmpty)
                                Image.network(
                                  post['attachments'][0]['media']['image']
                                      ['src'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              const SizedBox(height: 7),
                            ],
                          ),

                          subtitle: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isLiked = !isLiked;
                                          });
                                        },
                                        icon: Icon(
                                          isLiked
                                              ? Icons.thumb_up_alt_outlined
                                              : Icons.thumb_up,
                                          color: isLiked
                                              ? Colors.blue
                                              : Colors.blue,
                                        ),
                                      ),
                                      const Text(
                                        "J'aime",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: post['comments'] != null &&
                                        post['comments'].isNotEmpty,
                                    child: Text(
                                      '${post['comments'] != null ? post['comments'].length : 0} commentaires',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Liste des commentaires
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 0.2,
                                        blurRadius: 12,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: post['comments'] != null
                                        ? post['comments'].length
                                        : 0,
                                    itemBuilder: (context, commentIndex) {
                                      final comment =
                                          post['comments'][commentIndex];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(255, 248, 248, 248),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  comment['from'][
                                                      'name'], // Nom de la personne qui a ajouté le commentaire
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  comment['message'],
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _formatDateTime(
                                                      comment['created_time']),
                                                  style: const TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0.0, vertical: 10.0),
                                child: TextFormField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Ajouter un commentaire...',
                                    hintStyle: const TextStyle(fontSize: 10),
                                    filled: true,
                                    fillColor: Colors.white70,
                                    border: OutlineInputBorder(
                                      // Suppression de l'underline
                                      borderSide:
                                          BorderSide.none, // Aucune bordure
                                      borderRadius: BorderRadius.circular(
                                          1.0), // Border radius
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.send),
                                      iconSize: 17,
                                      color: Colors.grey,
                                      onPressed: () {
                                        final comment = _commentController.text;
                                        final postId = post['id'];
                                        facebookApi.createComment(
                                            postId, comment);
                                        // Efface le texte du contrôleur après l'envoi du commentaire
                                        _commentController.clear();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isThreeLine:
                              true, // Permettre à la tuile d'avoir trois lignes de contenu
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: _textEditingController,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                labelText: 'Nouvelle publication',
                labelStyle: TextStyle(color: Colors.blue),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                final message = _textEditingController.text;
                await facebookApi.createPost(message);
                await initPublish();
                setState(() {
                  _textEditingController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Publier sur Facebook',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  // Méthode pour formater la date et l'heure
  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) {
      return 'Date de création inconnue';
    }
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDateTime = DateFormat.yMd().add_Hm().format(dateTime);
    return formattedDateTime;
  }

  initPublish() async {
    final posts = await facebookApi.fetchPosts(context);
    setState(() {
      _posts = posts;
    });
    return _posts;
  }
}
