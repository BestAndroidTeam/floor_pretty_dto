// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

@DatabaseView("SELECT blablablablabla")
class DirtyUserDto {
  final List<int> tags;
  final int userId;
  final String userName;
  final int siteId;
  final String siteName;
  final int commentId;
  final String commentContent;

  DirtyUserDto({
    this.tags,
    this.userId,
    this.userName,
    this.siteId,
    this.siteName,
    this.commentId,
    this.commentContent,
  });

  UserDto toPrettyDto() {
    return UserDto(
      tags: tags,
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
