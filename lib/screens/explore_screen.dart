import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram/constants/colors.dart';
import 'package:instagram/screens/post_detail_screen.dart';
import 'package:instagram/screens/profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({ Key? key }) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool showSearchResults = false;

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          textInputAction: TextInputAction.search,
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search',
          ),
          onFieldSubmitted: (String _) {      //khoong qtam String nhan dc la gi nen dat ten la _
            setState(() {
              showSearchResults = true;
            });
          },
        ),
        actions: [
          showSearchResults ? IconButton(                                   //tawts phaanf ket qua cua search
            onPressed: () {
              Navigator.of(context).push(    //nếu chỉ dùng push thì bấm back vẫn có thể quay lại screen trc
              MaterialPageRoute(
                builder: (context) => const ExploreScreen(),
                ),
              );
            },
            icon: const Icon(Icons.close)
          ) 
          : const SizedBox()
        ],
      ),
      body: showSearchResults ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('username', isGreaterThanOrEqualTo: _searchController.text.toString(),)
                  .get(), 
            //get the collections, data cua users
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          else{
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,     //sd kiểu này nếu không muốn cast type cho snapshot ở trên
              itemBuilder: (context, index){
                return InkWell(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                  uid: snapshot.data!.docs[index].data()['uid'],
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data!.docs[index].data()['photoUrl'].toString()),
                        ),
                        title: Text(snapshot.data!.docs[index].data()['username'].toString()),
                  ),
                );
              }
            );
          }
        },
      )
      : FutureBuilder(
        future: FirebaseFirestore.instance.collection('posts').get(),
        builder:(context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }
          else{
            return StaggeredGridView.countBuilder(
              crossAxisCount: 3, 
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) => 
                    InkWell(
                      child: Image.network(snapshot.data!.docs[index]['postUrl'], fit: BoxFit.cover,),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('posts').snapshots(),
                              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting){
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return PostDetailScreen(snap: snapshot.data!.docs[index].data());
                              }
                            ),
                            //  PostDetailScreen(snap: snapshot.data!.docs[index].data(),),
                          ),
                        ).then((value) {
                          setState(() {
                            
                          });
                        });
                      },
                    ),
              staggeredTileBuilder: (index) => StaggeredTile.count(
                (index % 7 == 0) ? 2 : 1,     //cross axis cells count
                (index % 7 == 0) ? 2 : 1,     //main axis cells count
              ),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            );
          }
        }
      ),
    );
  }
}