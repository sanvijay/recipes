import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingService {
  late SharedPreferences pref;
  final InAppReview inAppReview = InAppReview.instance;

  Future<bool> readyToShowRating() async {
    pref = await SharedPreferences.getInstance();

    try {
      int? appFirstOpenDate = pref.getInt("app:first_open_date");
      bool? ratingShown = pref.getBool("app:rating_shown");

      if (ratingShown == null || appFirstOpenDate == null) {
        int timestamp = DateTime.now().millisecondsSinceEpoch;
        pref.setInt("app:first_open_date", timestamp);
        pref.setBool("app:rating_shown", false);

        return false;
      }
      else if (ratingShown) {
        return false;
      }
      else {
        int? timestamp = pref.getInt('app:first_open_date');
        DateTime firstOpen = DateTime.fromMillisecondsSinceEpoch(timestamp!);
        DateTime now = DateTime.now();
        Duration timeDifference = now.difference(firstOpen);

        int hours = timeDifference.inHours;

        return hours > 48;
      }
    }
    catch (e) {
      return false;
    }
  }

  Future<bool> showRating() async {
    try {
      final available = await inAppReview.isAvailable();
      if (available) {
        inAppReview.requestReview();
      }
      else {
        inAppReview.openStoreListing();
      }

      return true;
    } catch(e) {
      return false;
    }
  }

  bool openRating() {
    try {
      inAppReview.openStoreListing();

      return true;
    } catch(e) {
      return false;
    }
  }
}
