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
  final UserComment comment;

  UserDto({this.user, this.comment});
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
  final int commentId;
  final String commentContent;

  DirtyUserDto({
    this.userId,
    this.userName,
    this.siteId,
    this.siteName,
    this.commentId,
    this.commentContent,
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
      comment: UserComment(
        commentId: commentId,
        commentContent: commentContent,
      ),
    );
  }
}

```