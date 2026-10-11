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
  String get fromHint => 'Your location, a station or an area';

  @override
  String get toHint => 'Station, area or building, e.g. Yogidham';

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

  @override
  String get lastMileTitle => 'Station to doorstep';

  @override
  String get lastMileHomeBody =>
      'Walk, auto, shared auto, bus or cab from the station to where you are going';

  @override
  String get lastMileFromStation => 'From station';

  @override
  String get lastMileTo => 'Going to';

  @override
  String get lastMileToHint => 'Search a place or pick on the map';

  @override
  String get lastMilePickOnMap => 'Pick on the map';

  @override
  String get lastMileUseThisPoint => 'Use this point';

  @override
  String get lastMileDroppedPin => 'Point on the map';

  @override
  String get lastMileChooseDestination =>
      'Choose where you are going to see your options.';

  @override
  String get lastMileFromHere => 'Last mile from here';

  @override
  String get searchPlaces => 'Search places';

  @override
  String get noPlaceFound =>
      'No matching place yet. Try picking the point on the map.';

  @override
  String get sortCheapest => 'Cheapest';

  @override
  String get sortFastest => 'Fastest';

  @override
  String get sortLeastWalking => 'Least walking';

  @override
  String distanceStraight(String km) {
    return '$km km in a straight line';
  }

  @override
  String distanceRoadEstimate(String km) {
    return 'About $km km by road (estimated)';
  }

  @override
  String distanceRoad(String km) {
    return '$km km by road';
  }

  @override
  String get optWalk => 'Walk';

  @override
  String get optAutoMeter => 'Auto (by meter)';

  @override
  String get optTaxiMeter => 'Kaali-peeli taxi (by meter)';

  @override
  String get optSharedAuto => 'Shared auto';

  @override
  String optBus(String operator, String number) {
    return '$operator bus $number';
  }

  @override
  String fareFrom(int amount) {
    return 'from ₹$amount';
  }

  @override
  String fareAbout(int amount) {
    return '≈ ₹$amount';
  }

  @override
  String fareShared(int amount) {
    return '₹$amount per seat';
  }

  @override
  String get fareUnknown => 'Fare not known';

  @override
  String get fareInApp => 'Price in their app';

  @override
  String minutesAbout(int minutes) {
    return 'About $minutes min without traffic';
  }

  @override
  String walkMeters(int meters) {
    return '$meters m walk';
  }

  @override
  String get nightFareApplied => 'Includes the night charge';

  @override
  String nearestStand(String name, int meters) {
    return 'Nearest stand: $name, $meters m';
  }

  @override
  String get noStandKnown => 'No stand mapped near the station yet';

  @override
  String busBoardAlight(String board, String alight) {
    return 'Board at $board, get off at $alight';
  }

  @override
  String get availabilityUnknown =>
      'We cannot see whether a vehicle is there right now.';

  @override
  String openApp(String name) {
    return 'Open $name';
  }

  @override
  String get couldNotOpen => 'Could not open the app.';

  @override
  String get howWeEstimate => 'How these numbers are worked out';

  @override
  String get assumptionsBody =>
      'Road distance is the straight line × 1.3 unless a road route is available. Times assume walking at 4.5 km/h, autos at 18 km/h and taxis at 20 km/h, with no traffic or waiting. Meter fares use the published rate; the meter decides the real fare.';

  @override
  String fareRuleSource(String mode, String source, String date) {
    return '$mode: rates from $source, effective $date';
  }

  @override
  String get noFareRules =>
      'No fare rates entered yet, so meter fares cannot be estimated.';

  @override
  String get nearbyPickups => 'Stands near the station';

  @override
  String get nearbyPickupsEmpty => 'No stands recorded near this station yet.';

  @override
  String get verificationAdmin => 'Checked by us';

  @override
  String get verificationOsm => 'From OpenStreetMap';

  @override
  String get verificationCommunity => 'Reported by commuters';

  @override
  String get communityReports => 'Commuter reports';

  @override
  String get communityReportsEmpty => 'No reports near this station right now.';

  @override
  String get communityReportsOffline =>
      'Reports need the server, which is not set up yet.';

  @override
  String get reportSomething => 'Report';

  @override
  String get reportWhere => 'Where';

  @override
  String get reportTypeQueue => 'Long queue';

  @override
  String get reportTypeNoVehicles => 'No autos or taxis';

  @override
  String get reportTypeStandMoved => 'Stand has moved';

  @override
  String get reportTypeStopIssue => 'Bus stop problem';

  @override
  String get reportTypeClosure => 'Road closed';

  @override
  String get reportTypeDisruption => 'Disruption';

  @override
  String get reportNoteHint => 'Short note (optional)';

  @override
  String get reportPrivacy =>
      'Others see the report and its place, never your name or account.';

  @override
  String get reportSubmit => 'Send report';

  @override
  String get reportSent =>
      'Thanks. Others will see your report until it expires.';

  @override
  String get reportConfirm => 'Still true';

  @override
  String reportConfirmed(int count) {
    return 'Confirmed by $count';
  }

  @override
  String reportAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String get alertSource => 'Official source';

  @override
  String get adminTitle => 'Admin';

  @override
  String get adminNoAccess => 'This section is for admins and moderators.';

  @override
  String get adminOverview => 'Overview';

  @override
  String get adminReports => 'Reports';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminAlerts => 'Alerts';

  @override
  String get adminAudit => 'Audit log';

  @override
  String get adminSaved => 'Saved';

  @override
  String get adminUsersActive => 'Active users';

  @override
  String get adminUsersDisabled => 'Disabled';

  @override
  String get adminUsersDeleted => 'Deleted accounts';

  @override
  String get adminAdmins => 'Admins';

  @override
  String get adminModerators => 'Moderators';

  @override
  String get adminReportsPending => 'Reports waiting for review';

  @override
  String get adminReportsLive => 'Reports visible now';

  @override
  String get adminAlertsActive => 'Alerts in force';

  @override
  String get adminDataPackVersion => 'Data pack version';

  @override
  String get adminDataPackPublished => 'Last published';

  @override
  String get adminRoadDistance => 'Road distances (openrouteservice)';

  @override
  String get adminOn => 'On';

  @override
  String get adminOff => 'Off';

  @override
  String get adminDataHealth => 'Data sources';

  @override
  String get adminNoSync => 'Nothing published from the Sheet yet.';

  @override
  String adminLastSuccess(String when) {
    return 'Last success: $when';
  }

  @override
  String adminAcceptedRejected(int accepted, int rejected) {
    return '$accepted rows accepted, $rejected rejected';
  }

  @override
  String get adminNoPending => 'No reports waiting for review.';

  @override
  String adminReporter(String uid) {
    return 'Sent by account $uid';
  }

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminReject => 'Reject';

  @override
  String get adminSearchUsers => 'Search by email or name';

  @override
  String get adminDisable => 'Disable account';

  @override
  String get adminEnable => 'Enable account';

  @override
  String adminMakeRole(String role) {
    return 'Make $role';
  }

  @override
  String get adminNewAlert => 'New alert';

  @override
  String get adminNoAlerts => 'No alerts yet.';

  @override
  String get adminEndAlert => 'End now';

  @override
  String get adminEnded => 'Ended';

  @override
  String get adminRequired => 'Required';

  @override
  String get adminAlertScope => 'Applies to';

  @override
  String get adminAlertScopeHelp =>
      'ALL, a line code (CR-MAIN) or a station code (KYN)';

  @override
  String get adminAlertTitleEn => 'Title (English)';

  @override
  String get adminAlertTitleMr => 'Title (Marathi, optional)';

  @override
  String get adminAlertTitleHi => 'Title (Hindi, optional)';

  @override
  String get adminAlertBody => 'Details (optional)';

  @override
  String get adminAlertSource => 'Official announcement link';

  @override
  String get adminAlertSourceHelp =>
      'Must start with https:// and point to the official notice';

  @override
  String get adminAlertStarts => 'Starts';

  @override
  String get adminAlertEnds => 'Ends';

  @override
  String get adminAlertUntilEnded => 'Until ended';

  @override
  String get adminPublishAlert => 'Publish alert';

  @override
  String get roleAdmin => 'You are an admin';

  @override
  String get roleModerator => 'You are a moderator';

  @override
  String get consentPrompt =>
      'We have a privacy notice that explains what this app keeps about you. Please read it and accept.';

  @override
  String get consentRead => 'Read';

  @override
  String get consentAccept => 'Accept';

  @override
  String get privacyTitle => 'Privacy notice';

  @override
  String privacyVersion(String version) {
    return 'Version $version';
  }

  @override
  String get privacyCollectTitle => 'What we keep';

  @override
  String get privacyCollectBody =>
      'If you sign in: your email and name from your sign-in, your language, saved routes, the reports you send, when your account was created and the last day you used it. Without an account, nothing about you is kept on our server.';

  @override
  String get privacyNotCollectTitle => 'What we never keep';

  @override
  String get privacyNotCollectBody =>
      'Your password (Google Firebase handles sign-in), your location history, contacts or phone number. There are no ads, no tracking and we never sell data.';

  @override
  String get privacyLocationTitle => 'Location';

  @override
  String get privacyLocationBody =>
      'Your phone\'s location is read only when you tap \"My location\" and stays on the phone. When you choose a destination in the last-mile finder while signed in, the station and destination points are sent to our server to look up the road distance.';

  @override
  String get privacyReportsTitle => 'Reports you send';

  @override
  String get privacyReportsBody =>
      'Other people see the report, its place (to about 10 metres) and its time, never your name or account. Moderators can see which account sent a report, only to deal with abuse. Reports disappear when they expire.';

  @override
  String get privacyRightsTitle => 'Your choices';

  @override
  String get privacyRightsBody =>
      'Delete account (Profile) removes your email, name and saved routes and closes your sign-in. Reports you sent stay for other commuters but are no longer linked to you. You can use the app without an account.';

  @override
  String get privacyThirdPartyTitle => 'Services we rely on';

  @override
  String get privacyThirdPartyBody =>
      'Google Firebase (sign-in) and Google Apps Script and Sheets (our server and storage); OpenStreetMap tile servers when the map loads; openrouteservice for road distances if enabled; and Uber, Ola or Rapido only when you tap their button. Place search sends only the words you type to Photon (OpenStreetMap data).';

  @override
  String get searchAnyPlace => 'Search a station, area or building';

  @override
  String get stationLabel => 'Station';

  @override
  String get typeMoreToSearch =>
      'Type at least 3 letters to search more places.';

  @override
  String get moreFromOsm => 'More places (OpenStreetMap)';

  @override
  String get onlineSearchFailed =>
      'Couldn\'t search online. Check your internet, or pick the place on the map.';

  @override
  String get osmSearchCredit =>
      'Place search uses OpenStreetMap data via Photon. Only the words you type are sent.';

  @override
  String get tripTitle => 'Your journey';

  @override
  String get tripRoadOnlyClose =>
      'These places are close, so going by road is simplest.';

  @override
  String get tripNoStationNear =>
      'No station in the app is near one of these places yet, so only road options are shown.';

  @override
  String get tripByRoad => 'Direct by road';

  @override
  String get tripByTrain => 'By train';

  @override
  String minutesShort(int minutes) {
    return 'about $minutes min';
  }

  @override
  String tripLegToStation(String station) {
    return 'Get to $station station';
  }

  @override
  String tripLegFromStation(String station, String place) {
    return '$station station to $place';
  }

  @override
  String get autoStand => 'Auto stand';

  @override
  String get bookInApp => 'Book a ride';

  @override
  String get bookInAppNote =>
      'Opens the app; the app shows the real price and whether a vehicle is free.';

  @override
  String get departingNow => 'Leaving now';

  @override
  String get fareTrainTicketOnly => 'Train ticket only';

  @override
  String get noBusData => 'No bus stops for this area are in the app yet.';

  @override
  String get noLiveAutos =>
      'Autos have no live tracking anywhere, so the app shows the stands where autos usually wait, not moving vehicles.';

  @override
  String get noLiveBuses =>
      'Local buses here share no live location, so the app shows the stops and how often buses come, not moving buses.';

  @override
  String get optionAuto => 'Auto all the way';

  @override
  String get optionBus => 'Bus';

  @override
  String get optionCab => 'Taxi or cab';

  @override
  String get optionTrain => 'Train';

  @override
  String get optionTrainAuto => 'Train + auto';

  @override
  String get optionsTimeNote =>
      'Times are estimates without traffic or waiting. Fares use the official meter rate; the meter decides the real fare.';

  @override
  String get scheduledNotLive =>
      'Position from the timetable, not live GPS. Trains can run late.';

  @override
  String get seeDetails => 'See details';

  @override
  String get tagCheapest => 'Cheapest';

  @override
  String get tagEstimate => 'Estimate';

  @override
  String get tagFastest => 'Fastest';

  @override
  String get tagScheduled => 'Timetable';

  @override
  String get whereIsMyAuto => 'Where is my auto';

  @override
  String get whereIsMyBus => 'Where is my bus';

  @override
  String get whereIsMyTrain => 'Where is my train';

  @override
  String get whereShort => 'Where';

  @override
  String get youBoardHere => 'You board here';

  @override
  String get youGetOffHere => 'You get off here';

  @override
  String farePlusTicket(int amount) {
    return '≈ ₹$amount + train ticket';
  }

  @override
  String inMinutes(int minutes) {
    return 'in $minutes min';
  }

  @override
  String minutesBig(int minutes) {
    return '$minutes min';
  }

  @override
  String reachesAt(String time) {
    return 'reaches at $time';
  }

  @override
  String standsNear(String place) {
    return 'Auto stands near $place';
  }

  @override
  String stopsNear(String place) {
    return 'Bus stops near $place';
  }

  @override
  String stepAutoTo(String place) {
    return 'Auto to $place';
  }

  @override
  String stepWalkTo(String place) {
    return 'Walk to $place';
  }

  @override
  String timetableComingFor(String from, String to) {
    return 'Train times aren\'t loaded yet. Once the official Central Railway timetable is added, trains from $from to $to appear here, each with \"Where is my train\".';
  }

  @override
  String trainArrivingNow(String station) {
    return 'Arriving at $station now';
  }

  @override
  String trainAtNow(String station) {
    return 'At $station now';
  }

  @override
  String trainFinished(String station) {
    return 'Reached $station, journey over';
  }

  @override
  String trainLeftAgo(String station, int minutes) {
    return 'Left $station $minutes min ago';
  }

  @override
  String trainNowAt(String station) {
    return 'Now at $station';
  }

  @override
  String trainNowBetween(String a, String b) {
    return 'Between $a and $b';
  }

  @override
  String trainReached(String station) {
    return 'Reached $station';
  }

  @override
  String trainReachesIn(String station, int minutes) {
    return 'Reaches $station in $minutes min';
  }

  @override
  String trainStartsAt(String station, String time) {
    return 'Starts from $station at $time';
  }

  @override
  String trainsBetween(String from, String to) {
    return 'Trains $from → $to';
  }

  @override
  String waysToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ways to go',
      one: '1 way to go',
    );
    return '$_temp0';
  }

  @override
  String get boardAtLabel => 'Board at:';

  @override
  String get getOffAtLabel => 'Get off at:';
}
