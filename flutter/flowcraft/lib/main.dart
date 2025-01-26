
// import 'src/app.dart';

// TEST INTEGRATION: SUPABASE
// import 'package:flutter/material.dart';
// import 'src/settings/settings_controller.dart';
// import 'src/settings/settings_service.dart';

// import 'package:supabase_flutter/supabase_flutter.dart';

// void main() async {
//   // Set up the SettingsController, which will glue user settings to multiple
//   // Flutter Widgets.
//   final settingsController = SettingsController(SettingsService());

//   // Load the user's preferred theme while the splash screen is displayed.
//   // This prevents a sudden theme change when the app is first displayed.
//   await settingsController.loadSettings();

//   WidgetsFlutterBinding.ensureInitialized();

//   await Supabase.initialize(
//     url: 'https://cqyxglfnwcdaswovbosz.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxeXhnbGZud2NkYXN3b3Zib3N6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU3MjQwNDEsImV4cCI6MjA1MTMwMDA0MX0.gigyrbf42NUqKE2Z-j-TTWraRjm5pwFjraZ4Fbhvnes',
//   );

//   // Run the app and pass in the SettingsController. The app listens to the
//   // SettingsController for changes, then passes it further down to the
//   // SettingsView.
//   // runApp(MyApp(settingsController: settingsController));

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'Countries',
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final _future = Supabase.instance.client
//       .from('countries')
//       .select();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder(
//         future: _future,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final countries = snapshot.data!;
//           return ListView.builder(
//             itemCount: countries.length,
//             itemBuilder: ((context, index) {
//               final country = countries[index];
//               return ListTile(
//                 title: Text(country['name']),
//               );
//             }),
//           );
//         },
//       ),
//     );
//   }
// }

// TEST ENVIRONMENT VARIABLES
import 'package:flowcraft/env/env.dart';

// TEST INTEGRATION: GOOGLE OAUTH YOUTUBE

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

// #docregion Import
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
// #enddocregion Import
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/people/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

final GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  clientId: Env.GOOGLE_OAUTH_CLIENT_ID_WEB, // set for web 
  scopes: <String>[PeopleServiceApi.contactsReadonlyScope],
);

void main() {
  print(Env.SUPABASE_URL);
  print(Env.SUPABASE_ANON_KEY);
  print(Env.GOOGLE_OAUTH_CLIENT_ID_WEB);

  runApp(
    const MaterialApp(
      title: 'Google Sign In + googleapis',
      home: SignInDemo(),
    ),
  );
}

/// The main widget of this demo.
class SignInDemo extends StatefulWidget {
  /// Creates the main widget of this demo.
  const SignInDemo({super.key});

  @override
  State createState() => SignInDemoState();
}

/// The state of the main widget.
class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleGetContact() async {
    setState(() {
      _contactText = 'Loading contact info...';
    });

// #docregion CreateAPIClient
    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();

    assert(client != null, 'Authenticated client missing!');

    // Prepare a People Service authenticated client.
    final PeopleServiceApi peopleApi = PeopleServiceApi(client!);
    // Retrieve a list of the `names` of my `connections`
    final ListConnectionsResponse response =
        await peopleApi.people.connections.list(
      'people/me',
      personFields: 'names',
    );
    // #enddocregion CreateAPIClient

    final String? firstNamedContactName =
        _pickFirstNamedContact(response.connections);

    setState(() {
      if (firstNamedContactName != null) {
        _contactText = 'I see you know $firstNamedContactName!';
      } else {
        _contactText = 'No contacts to display.';
      }
    });
  }

  String? _pickFirstNamedContact(List<Person>? connections) {
    return connections
        ?.firstWhere(
          (Person person) => person.names != null,
        )
        .names
        ?.firstWhere(
          (Name name) => name.displayName != null,
        )
        .displayName;
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error); // ignore: avoid_print
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text('Signed in successfully.'),
          Text(_contactText),
          ElevatedButton(
            onPressed: _handleSignOut,
            child: const Text('SIGN OUT'),
          ),
          ElevatedButton(
            onPressed: _handleGetContact,
            child: const Text('REFRESH'),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('SIGN IN'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In + googleapis'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}

// TEST INTEGRATION: YOUTUBE PLAYER B - THIS WORKS ON macOS, but need to address auto fullscreen player with desktop aspect ratio

// import 'dart:developer';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// import 'video_list.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.blueAccent,
//     ),
//   );
//   runApp(const YoutubePlayerDemoApp());
// }

// /// Creates [YoutubePlayerDemoApp] widget.
// class YoutubePlayerDemoApp extends StatelessWidget {
//   const YoutubePlayerDemoApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Youtube Player Flutter',
//       theme: ThemeData(
//         colorSchemeSeed: Colors.blue,
//         appBarTheme: const AppBarTheme(
//           color: Colors.blueAccent,
//           titleTextStyle: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w300,
//             fontSize: 20,
//           ),
//         ),
//         iconTheme: const IconThemeData(
//           color: Colors.blueAccent,
//         ),
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// /// Homepage
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late YoutubePlayerController _controller;
//   late TextEditingController _idController;
//   late TextEditingController _seekToController;

//   late PlayerState _playerState;
//   late YoutubeMetaData _videoMetaData;
//   double _volume = 100;
//   bool _muted = false;
//   bool _isPlayerReady = false;

//   final List<String> _ids = [
//     'nPt8bK2gbaU',
//     'gQDByCdjUXw',
//     'iLnmTe5Q2Qw',
//     '_WoCV4c6XOE',
//     'KmzdUe0RSJo',
//     '6jZDSSZZxjQ',
//     'p2lYr3vM_1w',
//     '7QUtEmBT_-w',
//     '34_PXCzGw1M',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _controller = YoutubePlayerController(
//       initialVideoId: _ids.first,
//       flags: const YoutubePlayerFlags(
//         mute: false,
//         autoPlay: false,
//         disableDragSeek: false,
//         loop: false,
//         isLive: false,
//         forceHD: false,
//         enableCaption: true,
//       ),
//     )..addListener(listener);
//     _idController = TextEditingController();
//     _seekToController = TextEditingController();
//     _videoMetaData = const YoutubeMetaData();
//     _playerState = PlayerState.unknown;
//   }

//   void listener() {
//     if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
//       setState(() {
//         _playerState = _controller.value.playerState;
//         _videoMetaData = _controller.metadata;
//       });
//     }
//   }

//   @override
//   void deactivate() {
//     // Pauses video while navigating to next page.
//     _controller.pause();
//     super.deactivate();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _idController.dispose();
//     _seekToController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return YoutubePlayerBuilder(
//       onExitFullScreen: () {
//         // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
//         SystemChrome.setPreferredOrientations(DeviceOrientation.values);
//       },
//       player: YoutubePlayer(
//         controller: _controller,
//         showVideoProgressIndicator: true,
//         progressIndicatorColor: Colors.blueAccent,
//         topActions: <Widget>[
//           const SizedBox(width: 8.0),
//           Expanded(
//             child: Text(
//               _controller.metadata.title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18.0,
//               ),
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(
//               Icons.settings,
//               color: Colors.white,
//               size: 25.0,
//             ),
//             onPressed: () {
//               log('Settings Tapped!');
//             },
//           ),
//         ],
//         onReady: () {
//           _isPlayerReady = true;
//         },
//         onEnded: (data) {
//           _controller
//               .load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
//           _showSnackBar('Next Video Started!');
//         },
//       ),
//       builder: (context, player) => Scaffold(
//         appBar: AppBar(
//           leading: Padding(
//             padding: const EdgeInsets.only(left: 12.0),
//             child: Image.asset(
//               'assets/ypf.png',
//               fit: BoxFit.fitWidth,
//             ),
//           ),
//           title: const Text(
//             'Youtube Player Flutter',
//             style: TextStyle(color: Colors.white),
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.video_library),
//               onPressed: () => Navigator.push(
//                 context,
//                 CupertinoPageRoute(
//                   builder: (context) => const VideoList(),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         body: ListView(
//           children: [
//             player,
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _space,
//                   _text('Title', _videoMetaData.title),
//                   _space,
//                   _text('Channel', _videoMetaData.author),
//                   _space,
//                   _text('Video Id', _videoMetaData.videoId),
//                   _space,
//                   Row(
//                     children: [
//                       _text(
//                         'Playback Quality',
//                         _controller.value.playbackQuality ?? '',
//                       ),
//                       const Spacer(),
//                       _text(
//                         'Playback Rate',
//                         '${_controller.value.playbackRate}x  ',
//                       ),
//                     ],
//                   ),
//                   _space,
//                   TextField(
//                     enabled: _isPlayerReady,
//                     controller: _idController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       hintText: 'Enter youtube <video id> or <link>',
//                       fillColor: Colors.blueAccent.withAlpha(20),
//                       filled: true,
//                       hintStyle: const TextStyle(
//                         fontWeight: FontWeight.w300,
//                         color: Colors.blueAccent,
//                       ),
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () => _idController.clear(),
//                       ),
//                     ),
//                   ),
//                   _space,
//                   Row(
//                     children: [
//                       _loadCueButton('LOAD'),
//                       const SizedBox(width: 10.0),
//                       _loadCueButton('CUE'),
//                     ],
//                   ),
//                   _space,
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.skip_previous),
//                         onPressed: _isPlayerReady
//                             ? () => _controller.load(_ids[
//                                 (_ids.indexOf(_controller.metadata.videoId) -
//                                         1) %
//                                     _ids.length])
//                             : null,
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           _controller.value.isPlaying
//                               ? Icons.pause
//                               : Icons.play_arrow,
//                         ),
//                         onPressed: _isPlayerReady
//                             ? () {
//                                 _controller.value.isPlaying
//                                     ? _controller.pause()
//                                     : _controller.play();
//                                 setState(() {});
//                               }
//                             : null,
//                       ),
//                       IconButton(
//                         icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
//                         onPressed: _isPlayerReady
//                             ? () {
//                                 _muted
//                                     ? _controller.unMute()
//                                     : _controller.mute();
//                                 setState(() {
//                                   _muted = !_muted;
//                                 });
//                               }
//                             : null,
//                       ),
//                       FullScreenButton(
//                         controller: _controller,
//                         color: Colors.blueAccent,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.skip_next),
//                         onPressed: _isPlayerReady
//                             ? () => _controller.load(_ids[
//                                 (_ids.indexOf(_controller.metadata.videoId) +
//                                         1) %
//                                     _ids.length])
//                             : null,
//                       ),
//                     ],
//                   ),
//                   _space,
//                   Row(
//                     children: <Widget>[
//                       const Text(
//                         "Volume",
//                         style: TextStyle(fontWeight: FontWeight.w300),
//                       ),
//                       Expanded(
//                         child: Slider(
//                           inactiveColor: Colors.transparent,
//                           value: _volume,
//                           min: 0.0,
//                           max: 100.0,
//                           divisions: 10,
//                           label: '${(_volume).round()}',
//                           onChanged: _isPlayerReady
//                               ? (value) {
//                                   setState(() {
//                                     _volume = value;
//                                   });
//                                   _controller.setVolume(_volume.round());
//                                 }
//                               : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                   _space,
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 800),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20.0),
//                       color: _getStateColor(_playerState),
//                     ),
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       _playerState.toString(),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w300,
//                         color: Colors.white,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _text(String title, String value) {
//     return RichText(
//       text: TextSpan(
//         text: '$title : ',
//         style: const TextStyle(
//           color: Colors.blueAccent,
//           fontWeight: FontWeight.bold,
//         ),
//         children: [
//           TextSpan(
//             text: value,
//             style: const TextStyle(
//               color: Colors.blueAccent,
//               fontWeight: FontWeight.w300,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStateColor(PlayerState state) {
//     switch (state) {
//       case PlayerState.unknown:
//         return Colors.grey[700]!;
//       case PlayerState.unStarted:
//         return Colors.pink;
//       case PlayerState.ended:
//         return Colors.red;
//       case PlayerState.playing:
//         return Colors.blueAccent;
//       case PlayerState.paused:
//         return Colors.orange;
//       case PlayerState.buffering:
//         return Colors.yellow;
//       case PlayerState.cued:
//         return Colors.blue[900]!;
//       default:
//         return Colors.blue;
//     }
//   }

//   Widget get _space => const SizedBox(height: 10);

//   Widget _loadCueButton(String action) {
//     return Expanded(
//       child: MaterialButton(
//         color: Colors.blueAccent,
//         onPressed: _isPlayerReady
//             ? () {
//                 if (_idController.text.isNotEmpty) {
//                   var id = YoutubePlayer.convertUrlToId(
//                         _idController.text,
//                       ) ??
//                       '';
//                   if (action == 'LOAD') _controller.load(id);
//                   if (action == 'CUE') _controller.cue(id);
//                   FocusScope.of(context).requestFocus(FocusNode());
//                 } else {
//                   _showSnackBar('Source can\'t be empty!');
//                 }
//               }
//             : null,
//         disabledColor: Colors.grey,
//         disabledTextColor: Colors.black,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 14.0),
//           child: Text(
//             action,
//             style: const TextStyle(
//               fontSize: 18.0,
//               color: Colors.white,
//               fontWeight: FontWeight.w300,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontWeight: FontWeight.w300,
//             fontSize: 16.0,
//           ),
//         ),
//         backgroundColor: Colors.blueAccent,
//         behavior: SnackBarBehavior.floating,
//         elevation: 1.0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(50.0),
//         ),
//       ),
//     );
//   }
// }

// TEST INTEGRATION: YOUTUBE PLAYER A

// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// const List<String> _videoIds = [
//   'tcodrIK2P_I',
//   'H5v3kku4y6Q',
//   'nPt8bK2gbaU',
//   'K18cpp_-gP8',
//   'iLnmTe5Q2Qw',
//   '_WoCV4c6XOE',
//   'KmzdUe0RSJo',
//   '6jZDSSZZxjQ',
//   'p2lYr3vM_1w',
//   '7QUtEmBT_-w',
//   '34_PXCzGw1M'
// ];

// void main() async {

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'YouTube',
//       home: HomePage(),
//     );
//   }
// }

// ///
// class HomePage extends StatefulWidget {
//   const HomePage({super.key, this.videoId});

//   final String? videoId;

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = YoutubePlayerController(
//       params: const YoutubePlayerParams(
//         showControls: true,
//         mute: false,
//         showFullscreenButton: true,
//         loop: false,
//       ),
//     );

//     _controller.setFullScreenListener(
//       (isFullScreen) {
//         log('${isFullScreen ? 'Entered' : 'Exited'} Fullscreen.');
//       },
//     );

//     if (widget.videoId != null) {
//       _controller.loadVideoById(videoId: widget.videoId!);
//     } else {
//       _controller.loadPlaylist(
//         list: _videoIds,
//         listType: ListType.playlist,
//         startSeconds: 136,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return YoutubePlayerScaffold(
//       controller: _controller,
//       builder: (context, player) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Youtube Player IFrame Demo'),
//             actions: const [VideoPlaylistIconButton()],
//           ),
//           body: LayoutBuilder(
//             builder: (context, constraints) {
//               if (kIsWeb && constraints.maxWidth > 750) {
//                 return Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       flex: 3,
//                       child: Column(
//                         children: [
//                           player,
//                           const VideoPositionIndicator(),
//                         ],
//                       ),
//                     ),
//                     const Expanded(
//                       flex: 2,
//                       child: SingleChildScrollView(
//                         child: Controls(),
//                       ),
//                     ),
//                   ],
//                 );
//               }

//               return ListView(
//                 children: [
//                   player,
//                   const VideoPositionIndicator(),
//                   const Controls(),
//                 ],
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _controller.close();
//     super.dispose();
//   }
// }

// ///
// class Controls extends StatelessWidget {
//   ///
//   const Controls({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // const MetaDataSection(),
//           // _space,
//           // const SourceInputSection(),
//           // _space,
//           // PlayPauseButtonBar(),
//           // _space,
//           // const VideoPositionSeeker(),
//           // _space,
//           // const PlayerStateSection(),
//         ],
//       ),
//     );
//   }

//   Widget get _space => const SizedBox(height: 10);
// }

// ///
// class VideoPlaylistIconButton extends StatelessWidget {
//   ///
//   const VideoPlaylistIconButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.ytController;

//     return IconButton(
//       onPressed: () async {
//         controller.pauseVideo();
//         // router.go('/playlist');
//       },
//       icon: const Icon(Icons.playlist_play_sharp),
//     );
//   }
// }

// ///
// class VideoPositionIndicator extends StatelessWidget {
//   ///
//   const VideoPositionIndicator({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.ytController;

//     return StreamBuilder<YoutubeVideoState>(
//       stream: controller.videoStateStream,
//       initialData: const YoutubeVideoState(),
//       builder: (context, snapshot) {
//         final position = snapshot.data?.position.inMilliseconds ?? 0;
//         final duration = controller.metadata.duration.inMilliseconds;

//         return LinearProgressIndicator(
//           value: duration == 0 ? 0 : position / duration,
//           minHeight: 1,
//         );
//       },
//     );
//   }
// }

// ///
// class VideoPositionSeeker extends StatelessWidget {
//   ///
//   const VideoPositionSeeker({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var value = 0.0;

//     return Row(
//       children: [
//         const Text(
//           'Seek',
//           style: TextStyle(fontWeight: FontWeight.w300),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: StreamBuilder<YoutubeVideoState>(
//             stream: context.ytController.videoStateStream,
//             initialData: const YoutubeVideoState(),
//             builder: (context, snapshot) {
//               final position = snapshot.data?.position.inSeconds ?? 0;
//               final duration = context.ytController.metadata.duration.inSeconds;

//               value = position == 0 || duration == 0 ? 0 : position / duration;

//               return StatefulBuilder(
//                 builder: (context, setState) {
//                   return Slider(
//                     value: value,
//                     onChanged: (positionFraction) {
//                       value = positionFraction;
//                       setState(() {});

//                       context.ytController.seekTo(
//                         seconds: (value * duration).toDouble(),
//                         allowSeekAhead: true,
//                       );
//                     },
//                     min: 0,
//                     max: 1,
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// TEST INTEGRATION: INAPP WEBVIEW

// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:url_launcher/url_launcher.dart';

// WebViewEnvironment? webViewEnvironment;

// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
//     final availableVersion = await WebViewEnvironment.getAvailableVersion();
//     assert(availableVersion != null,
//         'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.');

//     webViewEnvironment = await WebViewEnvironment.create(
//         settings: WebViewEnvironmentSettings(userDataFolder: 'YOUR_CUSTOM_PATH'));
//   }

//   if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
//     await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
//   }

//   runApp(const MaterialApp(home: MyApp()));
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final GlobalKey webViewKey = GlobalKey();

//   InAppWebViewController? webViewController;
//   InAppWebViewSettings settings = InAppWebViewSettings(
//       isInspectable: kDebugMode,
//       mediaPlaybackRequiresUserGesture: false,
//       allowsInlineMediaPlayback: true,
//       iframeAllow: "camera; microphone",
//       iframeAllowFullscreen: true);

//   PullToRefreshController? pullToRefreshController;
//   String url = "";
//   double progress = 0;
//   final urlController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     pullToRefreshController = kIsWeb ||
//             ![TargetPlatform.iOS, TargetPlatform.android]
//                 .contains(defaultTargetPlatform)
//         ? null
//         : PullToRefreshController(
//             settings: PullToRefreshSettings(
//               color: Colors.blue,
//             ),
//             onRefresh: () async {
//               if (defaultTargetPlatform == TargetPlatform.android) {
//                 webViewController?.reload();
//               } else if (defaultTargetPlatform == TargetPlatform.iOS) {
//                 webViewController?.loadUrl(
//                     urlRequest:
//                         URLRequest(url: await webViewController?.getUrl()));
//               }
//             },
//           );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         // appBar: AppBar(title: const Text("Official InAppWebView website")),
//         body: SafeArea(
//             child: Column(children: <Widget>[
//           // TextField(
//           //   decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
//           //   controller: urlController,
//           //   keyboardType: TextInputType.url,
//           //   onSubmitted: (value) {
//           //     var url = WebUri(value);
//           //     if (url.scheme.isEmpty) {
//           //       url = WebUri("https://www.google.com/search?q=$value");
//           //     }
//           //     webViewController?.loadUrl(urlRequest: URLRequest(url: url));
//           //   },
//           // ),
//           Expanded(
//             child: Stack(
//               children: [
//                 InAppWebView(
//                   key: webViewKey,
//                   webViewEnvironment: webViewEnvironment,
//                   initialUrlRequest:
//                       URLRequest(url: WebUri("https://inappwebview.dev/")),
//                   initialSettings: settings,
//                   pullToRefreshController: pullToRefreshController,
//                   onWebViewCreated: (controller) {
//                     webViewController = controller;
//                   },
//                   onLoadStart: (controller, url) {
//                     setState(() {
//                       this.url = url.toString();
//                       urlController.text = this.url;
//                     });
//                   },
//                   onPermissionRequest: (controller, request) async {
//                     return PermissionResponse(
//                         resources: request.resources,
//                         action: PermissionResponseAction.GRANT);
//                   },
//                   shouldOverrideUrlLoading:
//                       (controller, navigationAction) async {
//                     var uri = navigationAction.request.url!;

//                     if (![
//                       "http",
//                       "https",
//                       "file",
//                       "chrome",
//                       "data",
//                       "javascript",
//                       "about"
//                     ].contains(uri.scheme)) {
//                       if (await canLaunchUrl(uri)) {
//                         // Launch the App
//                         await launchUrl(
//                           uri,
//                         );
//                         // and cancel the request
//                         return NavigationActionPolicy.CANCEL;
//                       }
//                     }

//                     return NavigationActionPolicy.ALLOW;
//                   },
//                   onLoadStop: (controller, url) async {
//                     pullToRefreshController?.endRefreshing();
//                     setState(() {
//                       this.url = url.toString();
//                       urlController.text = this.url;
//                     });
//                   },
//                   onReceivedError: (controller, request, error) {
//                     pullToRefreshController?.endRefreshing();
//                   },
//                   onProgressChanged: (controller, progress) {
//                     if (progress == 100) {
//                       pullToRefreshController?.endRefreshing();
//                     }
//                     setState(() {
//                       this.progress = progress / 100;
//                       urlController.text = url;
//                     });
//                   },
//                   onUpdateVisitedHistory: (controller, url, androidIsReload) {
//                     setState(() {
//                       this.url = url.toString();
//                       urlController.text = this.url;
//                     });
//                   },
//                   onConsoleMessage: (controller, consoleMessage) {
//                     if (kDebugMode) {
//                       print(consoleMessage);
//                     }
//                   },
//                 ),
//                 progress < 1.0
//                     ? LinearProgressIndicator(value: progress)
//                     : Container(),
//               ],
//             ),
//           ),
//           // OverflowBar(
//           //   alignment: MainAxisAlignment.center,
//           //   children: <Widget>[
//           //     ElevatedButton(
//           //       child: const Icon(Icons.arrow_back),
//           //       onPressed: () {
//           //         webViewController?.goBack();
//           //       },
//           //     ),
//           //     ElevatedButton(
//           //       child: const Icon(Icons.arrow_forward),
//           //       onPressed: () {
//           //         webViewController?.goForward();
//           //       },
//           //     ),
//           //     ElevatedButton(
//           //       child: const Icon(Icons.refresh),
//           //       onPressed: () {
//           //         webViewController?.reload();
//           //       },
//           //     ),
//           //   ],
//           // ),
//         ])));
//   }
// }