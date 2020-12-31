import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:stringee_flutter_plugin/stringee_flutter_plugin.dart';

import 'Call.dart';

var user1 =
    'eyJjdHkiOiJzdHJpbmdlZS1hcGk7dj0xIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiJTS0UxUmRVdFVhWXhOYVFRNFdyMTVxRjF6VUp1UWRBYVZULTE2MDg3MTY0ODAiLCJpc3MiOiJTS0UxUmRVdFVhWXhOYVFRNFdyMTVxRjF6VUp1UWRBYVZUIiwiZXhwIjoxNjExMzA4NDgwLCJ1c2VySWQiOiJ1c2VyMSJ9.e5U4nCiHrKDpuqi8oWs0LHTtzcH6_2Q0hP1oqMdNeMw';
var user2 =
    'eyJjdHkiOiJzdHJpbmdlZS1hcGk7dj0xIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiJTS0UxUmRVdFVhWXhOYVFRNFdyMTVxRjF6VUp1UWRBYVZULTE2MDYxMjI4OTkiLCJpc3MiOiJTS0UxUmRVdFVhWXhOYVFRNFdyMTVxRjF6VUp1UWRBYVZUIiwiZXhwIjoxNjA4NzE0ODk5LCJ1c2VySWQiOiJ1c2VyMiJ9.b_tG9wp0zharQV0EHVSGefXyCzUvmGjqTImEVNOg01o';
var token =
    'eyJjdHkiOiJzdHJpbmdlZS1hcGk7dj0xIiwidHlwIjoiSldUIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiJTS3RVaTBMZzNLa0lISkVwRTNiakZmMmd6UGtsNzlsU1otMTYwOTM4Nzc2OSIsImlzcyI6IlNLdFVpMExnM0trSUhKRXBFM2JqRmYyZ3pQa2w3OWxTWiIsImV4cCI6MTYwOTQ3NDE2OSwidXNlcklkIjoiQUNUWFY3QlRBUCIsImljY19hcGkiOnRydWUsImRpc3BsYXlOYW1lIjoiT2t1bXVyYSBSaW4iLCJhdmF0YXJVcmwiOm51bGwsInN1YnNjcmliZSI6IiIsImF0dHJpYnV0ZXMiOiJbe1wiYXR0cmlidXRlXCI6XCJvbmxpbmVTdGF0dXNcIixcInRvcGljXCI6XCJcIn0se1wiYXR0cmlidXRlXCI6XCJjYWxsXCIsXCJ0b3BpY1wiOlwiXCJ9XSJ9.BB3o5EOQorpSyx8PvnDhMABMbSxbhapsxHcgALOFaM0';
var client = StringeeClient();
String strUserId = "";

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: "OneToOneCallSample", home: new MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String myUserId = 'Not connected...';

  @override
  Future<void> initState() {
    // TODO: implement initState
    super.initState();

    requestPermissions();

    // Lắng nghe sự kiện của StringeeClient(kết nối, cuộc gọi đến...)
    client.eventStreamController.stream.listen((event) {
      Map<dynamic, dynamic> map = event;
      if (map['typeEvent'] == StringeeClientEvents) {
        switch (map['eventType']) {
          case StringeeClientEvents.DidConnect:
            handleDidConnectEvent();
            break;
          case StringeeClientEvents.DidDisconnect:
            handleDiddisconnectEvent();
            break;
          case StringeeClientEvents.DidFailWithError:
            handleDidFailWithErrorEvent(map['code'], map['message']);
            break;
          case StringeeClientEvents.RequestAccessToken:
            handleRequestAccessTokenEvent();
            break;
          case StringeeClientEvents.DidReceiveCustomMessage:
            handleDidReceiveCustomMessageEvent(map['body']);
            break;
          case StringeeClientEvents.DidReceiveTopicMessage:
            handleDidReceiveTopicMessageEvent(map['body']);
            break;
          case StringeeClientEvents.IncomingCall:
            StringeeCall call = map['body'];
            handleIncomingCallEvent(call);
            break;
          case StringeeClientEvents.IncomingCall2:
            StringeeCall2 call = map['body'];
            handleIncomingCall2Event(call);
            break;
          case StringeeClientEvents.DidReceiveChange:
            StringeeChange stringeeChange = map['body'];
            print(stringeeChange.objectType.toString() + '\t' + stringeeChange.changeType.toString());
            switch (stringeeChange.objectType) {
              case ObjectType.CONVERSATION:
                Conversation conversation = stringeeChange.object;
                print(conversation.id.toString());
                break;
              case ObjectType.MESSAGE:
                Message message = stringeeChange.object;
                print(message.id.toString() + '\t' + message.type.toString());
            }
            break;
          default:
            break;
        }
      }
    });

    // Connect
    client.connect(token: token);
  }

  requestPermissions() async {
    List<PermissionName> permissionNames = [];
    permissionNames.add(PermissionName.Camera);
    permissionNames.add(PermissionName.Contacts);
    permissionNames.add(PermissionName.Microphone);
    permissionNames.add(PermissionName.Location);
    permissionNames.add(PermissionName.Storage);
    permissionNames.add(PermissionName.State);
    permissionNames.add(PermissionName.Internet);
    var permissions = await Permission.requestPermissions(permissionNames);
    permissions.forEach((permission) {});
  }

  @override
  Widget build(BuildContext context) {
    Widget topText = new Container(
      padding: EdgeInsets.only(left: 10.0, top: 10.0),
      child: new Text(
        'Connected as: $myUserId',
        style: new TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
      ),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("OneToOneCallSample"),
        backgroundColor: Colors.indigo[600],
      ),
      body: new Stack(
        children: <Widget>[topText, new MyForm()],
      ),
    );
  }

  //region Handle Client Event
  void handleDidConnectEvent() {
    setState(() {
      myUserId = client.userId;
    });
  }

  void handleDiddisconnectEvent() {
    setState(() {
      myUserId = 'Not connected...';
    });
  }

  void handleDidFailWithErrorEvent(int code, String message) {
    print('code: ' + code.toString() + '\nmessage: ' + message);
  }

  void handleRequestAccessTokenEvent() {
    print('Request new access token');
  }

  void handleDidReceiveCustomMessageEvent(CustomData msg) {
    print('from: ' + msg.userId + '\nmessage: ' + msg.msg.toString());
  }

  void handleDidReceiveTopicMessageEvent(TopicMessage msg) {
    print('from: ' + msg.userId + '\nmessage: ' + msg.msg.toString());
  }

  void handleIncomingCallEvent(StringeeCall call) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Call(
              fromUserId: call.from,
              toUserId: call.to,
              isVideoCall: call.isVideocall,
              callType: StringeeType.StringeeCall,
              showIncomingUi: true,
              incomingCall: call)),
    );
  }

  void handleIncomingCall2Event(StringeeCall2 call) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Call(
              fromUserId: call.from,
              toUserId: call.to,
              isVideoCall: call.isVideocall,
              callType: StringeeType.StringeeCall2,
              showIncomingUi: true,
              incomingCall2: call)),
    );
  }

//endregion
}

class MyForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyFormState();
  }
}

class _MyFormState extends State<MyForm> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Form(
//      key: _formKey,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            padding: EdgeInsets.all(20.0),
            child: new TextField(
              onChanged: (String value) {
                _changeText(value);
              },
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
          new Container(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new RaisedButton(
                      color: Colors.grey[300],
                      textColor: Colors.black,
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      onPressed: () {
                        _CallTapped(false, StringeeType.StringeeCall);
                      },
                      child: Text('CALL'),
                    ),
                    new RaisedButton(
                      color: Colors.grey[300],
                      textColor: Colors.black,
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      onPressed: () {
                        _CallTapped(true, StringeeType.StringeeCall);
                      },
                      child: Text('VIDEOCALL'),
                    ),
                  ],
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new RaisedButton(
                      color: Colors.grey[300],
                      textColor: Colors.black,
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      onPressed: () {
                        _CallTapped(false, StringeeType.StringeeCall2);
                      },
                      child: Text('CALL2'),
                    ),
                    new RaisedButton(
                      color: Colors.grey[300],
                      textColor: Colors.black,
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      onPressed: () {
                        _CallTapped(true, StringeeType.StringeeCall2);
                      },
                      child: Text('VIDEOCALL2'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changeText(String val) {
    setState(() {
      strUserId = val;
    });
  }

  void _CallTapped(bool isVideoCall, StringeeType callType) {
    // if (strUserId.isEmpty || !client.hasConnected) return;
    //
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => Call(
    //           fromUserId: client.userId,
    //           toUserId: strUserId,
    //           isVideoCall: isVideoCall,
    //           callType: callType,
    //           showIncomingUi: false)),
    // );
    List<User> users = [];
    User user = new User(userId: 'a', name: 'a');
    User user2 = new User(userId: 'v');
    users.add(user);
    users.add(user2);
    //
    ConversationOption option = new ConversationOption(isDistinct: false, isGroup: false);
    // final parameters = {
    //   'participants': users,
    //   'option': option,
    // };
    CreateConvParam param = CreateConvParam(participants: users, option: option);
    client.createConversation(param: param).then((value) => {print(value)});
    // client.createConversation(param: param).then((value) => {print(value)});

    // final parameters = {
    //   'convId': 'conv-vn-1-73JJ5R8BMN-1606409934220',
    //   'userId': 'ACTXV7BTAP',
    // };
    //
    // client.getConversationById('conv-vn-1-73JJ5R8BMN-1606409934220').then((result) {
    //   Conversation conversation = result['body'];
    //   print(conversation.id);
    // });

    final parameters = {
      // 'participants': users,
      'convId': 'conv-vn-1-73JJ5R8BMN-1606409965564',
      'msgIds': [
        'msg-vn-1-73JJ5R8BMN-1606412374440',
      ],
      'msgId': 'msg-vn-1-73JJ5R8BMN-1606412374440',
      'count': 3,
      //text
      'text': 'test',
      // //photo
      // 'filePath': '/storage/emulated/0/DCIM/Camera/20201217_192024.jpg',
      // //video
      // 'filePath': '/storage/emulated/0/POC/video/VID_20201230_134232_.mp4',
      // 'duration': 1287,
      // //audio
      // 'filePath': '/storage/emulated/0/POC/other/AUD_20201230_134111_.m4a',
      // 'duration': 2531,
      // //file
      // 'filePath': '/storage/emulated/0/Download/1593595410-HĐLĐ-LêThịGiang.pdf',
      // //contact
      // 'contact': 'BEGIN:VCARD\nVERSION:2.1\nFN:A Huy\nTEL;CELL:090 998 26 68\nEND:VCARD',
      // //location
      // 'latitude': 21.0337827,
      // 'longitude': 105.7703466,
    };
    Conversation conv = new Conversation();
    // conv.delete('conv-vn-1-ON7WXI1BXA-1601060487890').then((result) {
    //   print(result);
    // });

    // conv.addParticipants(parameters).then((result) {
    //   print(result);
    // });

    // Message message = Message(type: MsgType.TYPE_TEXT, data: parameters);
    // conv.sendMessage(message).then((result) {
    //   print(result);
    // });
  }
}
