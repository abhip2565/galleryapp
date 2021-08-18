import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: gallery(),
    );
  }
}

class gallery extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _galleryState createState() => _galleryState();
}

class _galleryState extends State<gallery> {
  @override

  Widget build(BuildContext context) {
    return  Scaffold(
          body: Center(
            child: RaisedButton(
                child: Text("open gallery"),
                onPressed: ()  async{
                  final permitted = await PhotoManager.requestPermission();
                  if (!permitted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (BuildContext context) => Photos()));


                }

            ),
          ),

    );

  }}

class Photos extends StatefulWidget {
  // This widget is the root of your application.
  @override
  photoState createState() => photoState();
}
class photoState extends State<Photos> {
  @override
  void initState()  {
    fetch();
    super.initState();
  }

  List assets = [];

  fetch() async {
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList();
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
     final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );
    print(recentAssets);

    // Update the state and notify UI
    setState(()=>assets=recentAssets);
  }
  Future<bool> onback()
  {
    print("back");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => gallery()));

  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("heloo"),),
        body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // A grid view with 3 items per row
        crossAxisCount: 3,
    ),
    itemCount: assets.length,
    itemBuilder: (_, index) {
      return AssetThumbnail(asset: assets[index]);
    },
      ),

    );




  }
}
  class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({
  Key key,
  @required this.asset,
  }) : super(key: key);

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
  // We're using a FutureBuilder since thumbData is a future
  return FutureBuilder(
  future: asset.thumbData,
  builder: (_, snapshot) {
  final bytes = snapshot.data;
  // If we have no data, display a spinner
  if (bytes == null) return CircularProgressIndicator();
  // If there's data, display it as an image
  return InkWell(
    onTap: (){
      if(asset.typeInt==1)
        Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => ImageScreen(imageFile: asset.file,)));
    },
    child: Stack(children: [Positioned.fill(
    child: Image.memory(bytes, fit: BoxFit.cover)),
      if(asset.type==AssetType.video)
        Center(
          child: Container(
            color: Colors.blue,
            child: Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
          ),
        )



    ]

    ),
  );
  },
  );
  }
  }
  class ImageScreen extends StatefulWidget{

    final Future imageFile;
    ImageScreen({this.imageFile});
  @override
  _ImageScreenState createState() => _ImageScreenState(imageFile: imageFile);
}

class _ImageScreenState extends State<ImageScreen> {



   final Future imageFile;
  _ImageScreenState({this.imageFile});
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(title: Text("heloo"),),
        body: Container(
          color:Colors.black,
          alignment: Alignment.center,
          child: FutureBuilder(
            future: imageFile,
            builder:(_, snapshot)
            {
              final file=snapshot.data;
              if(file==null)
                return Container();
              return Image.file(file);
            }
          ),
        ),
      );

  }
}


