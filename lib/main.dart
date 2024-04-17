import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'api_http_facebook.dart';

const String accessTokens =
    "EAAF3TuYVsJABO5nLrYL7omVEq22GYBgOJLM6T9oNA4Q8SwppoTIQqyzxZA2OMmtWpixusRZAlHYdIa0IKogZAIZA1ZCFzrCkOIbGEUMDp0P29vy5Yn7KiP3fgy3ADivbksb8cDp97ogS0s3ciLGItjuvGyf8tDnYreVDCXslrDNMZA2hPM5Us3uPIGyurFZADVbSS72Q4kyKWY7OObT7vqycn2H";
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
  bool isComment = false;
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
                  isLiked = post['has_liked'] ?? false;
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipOval(
                                          child: Image.network(
                                            post['profile_picture'],
                                            width:
                                                40, // Ajustez la largeur de l'image selon vos besoins
                                            height:
                                                40, // Ajustez la hauteur de l'image selon vos besoins
                                            fit: BoxFit
                                                .cover, // Ajustez le mode de redimensionnement de l'image selon vos besoins
                                          ),
                                        ),
                                        SizedBox(width: 3),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              child: Text(
                                                post['message'] ??
                                                    post['story'],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 60, 60, 60),
                                                    fontSize: 11),
                                                maxLines:
                                                    2, // Limite le nombre de lignes affichées
                                                overflow: TextOverflow
                                                    .ellipsis, // Ajoute des points de suspension en cas de dépassement
                                              ),
                                            ),
                                            Text(
                                              _formatDateTime(
                                                  post['created_time']),
                                              style: const TextStyle(
                                                fontSize: 8,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
                                    icon: const Icon(
                                      Icons.close,
                                      size: 12,
                                    ),
                                    color: Colors.grey, // Couleur de l'icône
                                  ),
                                ],
                              ),
                              // Text(
                              //   _formatDateTime(post['created_time']),
                              //   style: const TextStyle(fontSize: 12),
                              // ),
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
                                  Visibility(
                                    visible: post['likes'] != 0,
                                    child: Row(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          width:
                                              14, // Ajustez la largeur du conteneur
                                          height:
                                              14, // Ajustez la hauteur du conteneur
                                          child: Stack(
                                            children: [
                                              Container(
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              Center(
                                                child: IconButton(
                                                  padding: EdgeInsets.all(1),
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                    Icons.thumb_up_alt,
                                                    size:
                                                        9, // Ajustez la taille de l'icône pour qu'elle soit centrée dans le cercle
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Text(post['likes'].toString(),
                                            style: TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                      visible: post['comments'] != null &&
                                          post['comments'].isNotEmpty,
                                      child: TextButton(
                                        onPressed: () {
                                          isComment = !isComment;
                                        },
                                        child: Text(
                                          '${post['comments'] != null ? post['comments'].length : 0} commentaires',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.blue),
                                        ),
                                      )),
                                ],
                              ),

                              const SizedBox(height: 10),
                              // Ajouter le Divider ici
                              Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                                height: 0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() async {
                                            isLiked = !isLiked;
                                            facebookApi.likePost(
                                                post['id'], isLiked);
                                            initPublish();
                                          });
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize
                                              .min, // Ajuste la taille de la rangée à son contenu
                                          children: [
                                            Icon(
                                              isLiked
                                                  ? Icons.thumb_up
                                                  : Icons.thumb_up_alt_outlined,
                                              color: Colors.grey,
                                              size: 12,
                                            ),
                                            const SizedBox(
                                                width:
                                                    10), // Ajoute un petit espace entre l'icône et le texte
                                            Text(
                                              "J'aime",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .mode_comment_outlined, // icône de commentaire
                                        size:
                                            16, // ajustez la taille de l'icône selon vos besoins
                                        color:
                                            Colors.grey, // couleur de l'icône
                                      ),
                                      SizedBox(
                                          width:
                                              5), // espace entre l'icône et le texte
                                      Text(
                                        'commentaires',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .wifi_protected_setup_outlined, // icône de commentaire
                                        size:
                                            16, // ajustez la taille de l'icône selon vos besoins
                                        color:
                                            Colors.grey, // couleur de l'icône
                                      ),
                                      SizedBox(
                                          width:
                                              5), // espace entre l'icône et le texte
                                      Text(
                                        'partager',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(width: 10)
                                    ],
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                                height: 0,
                              ),
                              const SizedBox(height: 12),
                              // Liste des commentaires

                              // Ajoutez une condition visible basée sur isComment autour du Padding
                              Visibility(
                                visible: isComment,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0),
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
                                              color: Color.fromARGB(
                                                  255, 248, 248, 248),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    comment['from'][
                                                        'name'], // Nom de la personne qui a ajouté le commentaire
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                    _formatDateTime(comment[
                                                        'created_time']),
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
                              ),

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
      // Initialisation de isLiked en fonction de la clé has_liked de chaque publication
    });
    return _posts;
  }
}
