import 'content_category.dart';

class BlogPost {
  final String date;
  final String title;
  final String body;
  final ContentCategory category;

  BlogPost({
    required this.date,
    required this.title,
    required this.body,
    this.category = ContentCategory.jumla,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) => BlogPost(
        date: json['date'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        category: ContentCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => ContentCategory.fromKeywords('${json['title']} ${json['body']}'),
        ),
      );
}
