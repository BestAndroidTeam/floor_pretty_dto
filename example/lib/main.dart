import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:floor_pretty_dto/floor_pretty_dto.dart';

part 'main.g.dart';

@Entity()
class User {
  final int userId;
  final String userName;
  final Site userSite;

  User({this.userId, this.userName, this.userSite});
}

@Entity()
class Site {
  final int siteId;
  final String siteName;

  Site({this.siteId, this.siteName});
}

@Entity()
class UserComment {
  final int commentId;
  final String commentContent;

  UserComment({this.commentId, this.commentContent});
}

@PrettyDto("SELECT blablablablabla")
class UserDto {
  final User user;
  final List<UserComment> comments;

  UserDto({this.user, this.comments});
}

class App extends StatelessWidget {
  static const TITLE = 'Model builder example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TITLE,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Text('Hello'),
    );
  }
}

void main() => runApp(App());
