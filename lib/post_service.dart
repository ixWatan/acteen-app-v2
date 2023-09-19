import 'package:cloud_firestore/cloud_firestore.dart';
import 'post.dart';

class PostService {
  Future<List<Post>> fetchPosts() async {
    List<Post> posts = [];

    // Step 1: Fetch all organizations
    QuerySnapshot organizationsSnapshot = await FirebaseFirestore.instance.collection('organizations').get();

    // Step 2: For each organization, fetch all events and add them to the posts list
    for (QueryDocumentSnapshot organizationDocument in organizationsSnapshot.docs) {
      QuerySnapshot eventsSnapshot = await organizationDocument.reference.collection('events').get();
      posts.addAll(eventsSnapshot.docs.map((eventDoc) => Post.fromJson(eventDoc.data() as Map<String, dynamic>)).toList());
    }

    return posts;
  }
}

