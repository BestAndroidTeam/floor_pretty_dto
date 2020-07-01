** Pretty Dtos for Floor

The problem : Floor doesn't allow us to fetch clean Dtos like in Room, but offers a DatabaseView instead.

**

For this,

```dart

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

```

The generator will generate this :

```dart

@DatabaseView("SELECT blablablablabla")
class DirtyUserDto {
  final int userId;
  final String userName;
  final int siteId;
  final String siteName;
  final List comments;

  DirtyUserDto({
    this.userId,
    this.userName,
    this.siteId,
    this.siteName,
    this.comments,
  });

  UserDto toPrettyDto() {
    return UserDto(
      user: User(
        userId: userId,
        userName: userName,
        userSite: Site(
          siteId: siteId,
          siteName: siteName,
        ),
      ),
      comments: comments,
    );
  }
}

```