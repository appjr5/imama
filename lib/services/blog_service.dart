import '../data/tips_data.dart';
import '../models/blog_post.dart';

class BlogService {
  static List<BlogPost> getPosts() => TipsData.getTodaysTips(count: 3);
}
