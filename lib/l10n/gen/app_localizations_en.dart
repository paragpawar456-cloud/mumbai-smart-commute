// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mumbai Smart Commute';

  @override
  String get navHome => 'Home';

  @override
  String get navRoutes => 'Routes';

  @override
  String get navMap => 'Live Map';

  @override
  String get navSaved => 'Saved';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGreeting => 'Where are you going?';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get fromHint => 'Current location or station';

  @override
  String get toHint => 'Destination, e.g. Yogidham, Kalyan West';

  @override
  String get findRoutes => 'Find routes';

  @override
  String get nearbyTransport => 'Nearby transport';

  @override
  String get nearbyTransportBody =>
      'Stations, bus stops and auto stands near you';

  @override
  String get savedJourneys => 'Saved journeys';

  @override
  String get noSavedJourneys =>
      'No saved journeys yet. Search a route and tap the star to save it.';

  @override
  String get routesTitle => 'Plan a journey';

  @override
  String get routesComingSoon =>
      'Train, metro and bus timetables arrive in the next update.';

  @override
  String get mapTitle => 'Map';

  @override
  String get mapComingSoon =>
      'The map arrives in the next update. Vehicles are only shown as live when a genuine live feed exists.';

  @override
  String get savedTitle => 'Saved';

  @override
  String get profileTitle => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get reducedMotion => 'Reduce motion';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get register => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get displayName => 'Name';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetEmailSent =>
      'If an account exists for that email, a reset link has been sent.';

  @override
  String get verifyEmailSent => 'We sent a verification link to your email.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueAsGuest => 'Continue without an account';

  @override
  String get guestNote =>
      'You can use timetables and the map without an account. Sign in to save routes and report updates.';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get authUnavailable => 'Sign-in is not configured in this build.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm =>
      'This permanently deletes your account and saved data. Continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Retry';

  @override
  String get offline => 'You are offline. Showing saved information.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'Could not reach the server. Check your connection.';

  @override
  String get backendStatus => 'Server status';

  @override
  String get backendOk => 'Connected';

  @override
  String get backendNotConfigured => 'Server not configured in this build';

  @override
  String get sourceLive => 'Live';

  @override
  String get sourceScheduled => 'Scheduled';

  @override
  String get sourceEstimate => 'Estimate';

  @override
  String get sourceOfficial => 'Official';

  @override
  String get sourceCommunity => 'Community reported';

  @override
  String get sourceUnknown => 'Unknown';

  @override
  String updatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String get about => 'About and data sources';

  @override
  String get aboutBody =>
      'Map data © OpenStreetMap contributors. Fares marked Estimate are calculated from official tariffs and are not live quotes. This app is not an emergency service.';

  @override
  String get selectStation => 'Select station';

  @override
  String get searchStations => 'Search stations';

  @override
  String get noStationFound => 'No station found. Try another spelling.';

  @override
  String get planJourney => 'Plan journey';

  @override
  String get noRouteFound => 'No route found between these stations.';

  @override
  String get chooseBothStations => 'Choose a start and destination station.';

  @override
  String rideLeg(String line) {
    return '$line';
  }

  @override
  String boardAt(String station) {
    return 'Board at $station';
  }

  @override
  String alightAt(String station) {
    return 'Get off at $station';
  }

  @override
  String stopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops',
      one: '1 stop',
    );
    return '$_temp0';
  }

  @override
  String changesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes',
      one: '1 change',
      zero: 'Direct',
    );
    return '$_temp0';
  }

  @override
  String walkTo(String station, int minutes) {
    return 'Walk to $station (about $minutes min)';
  }

  @override
  String get timetableNotLoaded =>
      'Timetable not loaded yet. Train times will appear once the official timetable is added. We never guess train times.';

  @override
  String nextTrain(String dep, String arr) {
    return 'Next train $dep → arrives $arr';
  }

  @override
  String get noMoreTrainsToday =>
      'No more scheduled trains today for this journey.';

  @override
  String get departures => 'Departures';

  @override
  String towards(String station) {
    return 'to $station';
  }

  @override
  String platformShort(String platform) {
    return 'PF $platform';
  }

  @override
  String get fastTrain => 'Fast';

  @override
  String get slowTrain => 'Slow';

  @override
  String get acTrain => 'AC';

  @override
  String get ladiesTrain => 'Ladies';

  @override
  String get saveJourney => 'Save journey';

  @override
  String get removeJourney => 'Remove from saved';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String dataVersion(int version, String origin) {
    return 'Data version $version · $origin';
  }

  @override
  String get originBundled => 'built into the app';

  @override
  String get originCached => 'downloaded earlier';

  @override
  String get originServer => 'just updated';

  @override
  String get showOnMap => 'Show on map';

  @override
  String get myLocation => 'My location';

  @override
  String get layers => 'Layers';

  @override
  String get layerSuburban => 'Local trains';

  @override
  String get layerMetro => 'Metro';

  @override
  String get locationDenied =>
      'Location permission is off. The map still works; turn it on in settings to see where you are.';

  @override
  String get locationServiceOff => 'Location is switched off on this phone.';

  @override
  String get lineGeometryNote =>
      'Lines are drawn straight between stations, not along the exact track.';

  @override
  String get linesAtStation => 'Lines';
}
