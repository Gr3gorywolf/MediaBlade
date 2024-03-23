import 'package:dio/dio.dart';
import 'package:media_blade/models/github_release.dart';
import 'package:media_blade/utils/assets_helper.dart';

class UpdatesHelper {
  /// Fetches a new release, if its the current built release it will return null
  Future<GithubRelease?> fetchNewRelease() async {
    try {
      var res = await Dio()
          .get("https://api.github.com/repos/Gr3gorywolf/MediaBlade/releases");
      var data = GithubRelease.fromJson(res.data.first);
      var currentRelease =
          await AssetsHelper.getText('release-number', extension: '.txt');
      if (!currentRelease.toString().contains(data.name ?? '')) {
        return data;
      }
      return null;
    } catch (err) {
      print(err);
    }
    return null;
  }
}
