import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mumbai Smart Commute'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get navRoutes;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Live Map'**
  String get navMap;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get homeGreeting;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @fromHint.
  ///
  /// In en, this message translates to:
  /// **'Your location, a station or an area'**
  String get fromHint;

  /// No description provided for @toHint.
  ///
  /// In en, this message translates to:
  /// **'Station, area or building, e.g. Yogidham'**
  String get toHint;

  /// No description provided for @findRoutes.
  ///
  /// In en, this message translates to:
  /// **'Find routes'**
  String get findRoutes;

  /// No description provided for @nearbyTransport.
  ///
  /// In en, this message translates to:
  /// **'Nearby transport'**
  String get nearbyTransport;

  /// No description provided for @nearbyTransportBody.
  ///
  /// In en, this message translates to:
  /// **'Stations, bus stops and auto stands near you'**
  String get nearbyTransportBody;

  /// No description provided for @savedJourneys.
  ///
  /// In en, this message translates to:
  /// **'Saved journeys'**
  String get savedJourneys;

  /// No description provided for @noSavedJourneys.
  ///
  /// In en, this message translates to:
  /// **'No saved journeys yet. Search a route and tap the star to save it.'**
  String get noSavedJourneys;

  /// No description provided for @routesTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan a journey'**
  String get routesTitle;

  /// No description provided for @routesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Train, metro and bus timetables arrive in the next update.'**
  String get routesComingSoon;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @mapComingSoon.
  ///
  /// In en, this message translates to:
  /// **'The map arrives in the next update. Vehicles are only shown as live when a genuine live feed exists.'**
  String get mapComingSoon;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @reducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reducedMotion;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get displayName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, a reset link has been sent.'**
  String get resetEmailSent;

  /// No description provided for @verifyEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your email.'**
  String get verifyEmailSent;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get continueAsGuest;

  /// No description provided for @guestNote.
  ///
  /// In en, this message translates to:
  /// **'You can use timetables and the map without an account. Sign in to save routes and report updates.'**
  String get guestNote;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @authUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is not configured in this build.'**
  String get authUnavailable;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and saved data. Continue?'**
  String get deleteAccountConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Showing saved information.'**
  String get offline;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @backendStatus.
  ///
  /// In en, this message translates to:
  /// **'Server status'**
  String get backendStatus;

  /// No description provided for @backendOk.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get backendOk;

  /// No description provided for @backendNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Server not configured in this build'**
  String get backendNotConfigured;

  /// No description provided for @sourceLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get sourceLive;

  /// No description provided for @sourceScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get sourceScheduled;

  /// No description provided for @sourceEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get sourceEstimate;

  /// No description provided for @sourceOfficial.
  ///
  /// In en, this message translates to:
  /// **'Official'**
  String get sourceOfficial;

  /// No description provided for @sourceCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community reported'**
  String get sourceCommunity;

  /// No description provided for @sourceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get sourceUnknown;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updatedAt(String time);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About and data sources'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Map data © OpenStreetMap contributors. Fares marked Estimate are calculated from official tariffs and are not live quotes. This app is not an emergency service.'**
  String get aboutBody;

  /// No description provided for @selectStation.
  ///
  /// In en, this message translates to:
  /// **'Select station'**
  String get selectStation;

  /// No description provided for @searchStations.
  ///
  /// In en, this message translates to:
  /// **'Search stations'**
  String get searchStations;

  /// No description provided for @noStationFound.
  ///
  /// In en, this message translates to:
  /// **'No station found. Try another spelling.'**
  String get noStationFound;

  /// No description provided for @planJourney.
  ///
  /// In en, this message translates to:
  /// **'Plan journey'**
  String get planJourney;

  /// No description provided for @noRouteFound.
  ///
  /// In en, this message translates to:
  /// **'No route found between these stations.'**
  String get noRouteFound;

  /// No description provided for @chooseBothStations.
  ///
  /// In en, this message translates to:
  /// **'Choose a start and destination station.'**
  String get chooseBothStations;

  /// No description provided for @rideLeg.
  ///
  /// In en, this message translates to:
  /// **'{line}'**
  String rideLeg(String line);

  /// No description provided for @boardAt.
  ///
  /// In en, this message translates to:
  /// **'Board at {station}'**
  String boardAt(String station);

  /// No description provided for @alightAt.
  ///
  /// In en, this message translates to:
  /// **'Get off at {station}'**
  String alightAt(String station);

  /// No description provided for @stopsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stop} other{{count} stops}}'**
  String stopsCount(int count);

  /// No description provided for @changesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Direct} =1{1 change} other{{count} changes}}'**
  String changesCount(int count);

  /// No description provided for @walkTo.
  ///
  /// In en, this message translates to:
  /// **'Walk to {station} (about {minutes} min)'**
  String walkTo(String station, int minutes);

  /// No description provided for @timetableNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Timetable not loaded yet. Train times will appear once the official timetable is added. We never guess train times.'**
  String get timetableNotLoaded;

  /// No description provided for @nextTrain.
  ///
  /// In en, this message translates to:
  /// **'Next train {dep} → arrives {arr}'**
  String nextTrain(String dep, String arr);

  /// No description provided for @noMoreTrainsToday.
  ///
  /// In en, this message translates to:
  /// **'No more scheduled trains today for this journey.'**
  String get noMoreTrainsToday;

  /// No description provided for @departures.
  ///
  /// In en, this message translates to:
  /// **'Departures'**
  String get departures;

  /// No description provided for @towards.
  ///
  /// In en, this message translates to:
  /// **'to {station}'**
  String towards(String station);

  /// No description provided for @platformShort.
  ///
  /// In en, this message translates to:
  /// **'PF {platform}'**
  String platformShort(String platform);

  /// No description provided for @fastTrain.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fastTrain;

  /// No description provided for @slowTrain.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slowTrain;

  /// No description provided for @acTrain.
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get acTrain;

  /// No description provided for @ladiesTrain.
  ///
  /// In en, this message translates to:
  /// **'Ladies'**
  String get ladiesTrain;

  /// No description provided for @saveJourney.
  ///
  /// In en, this message translates to:
  /// **'Save journey'**
  String get saveJourney;

  /// No description provided for @removeJourney.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeJourney;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @dataVersion.
  ///
  /// In en, this message translates to:
  /// **'Data version {version} · {origin}'**
  String dataVersion(int version, String origin);

  /// No description provided for @originBundled.
  ///
  /// In en, this message translates to:
  /// **'built into the app'**
  String get originBundled;

  /// No description provided for @originCached.
  ///
  /// In en, this message translates to:
  /// **'downloaded earlier'**
  String get originCached;

  /// No description provided for @originServer.
  ///
  /// In en, this message translates to:
  /// **'just updated'**
  String get originServer;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get showOnMap;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @layers.
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get layers;

  /// No description provided for @layerSuburban.
  ///
  /// In en, this message translates to:
  /// **'Local trains'**
  String get layerSuburban;

  /// No description provided for @layerMetro.
  ///
  /// In en, this message translates to:
  /// **'Metro'**
  String get layerMetro;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is off. The map still works; turn it on in settings to see where you are.'**
  String get locationDenied;

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location is switched off on this phone.'**
  String get locationServiceOff;

  /// No description provided for @lineGeometryNote.
  ///
  /// In en, this message translates to:
  /// **'Lines are drawn straight between stations, not along the exact track.'**
  String get lineGeometryNote;

  /// No description provided for @linesAtStation.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get linesAtStation;

  /// No description provided for @lastMileTitle.
  ///
  /// In en, this message translates to:
  /// **'Station to doorstep'**
  String get lastMileTitle;

  /// No description provided for @lastMileHomeBody.
  ///
  /// In en, this message translates to:
  /// **'Walk, auto, shared auto, bus or cab from the station to where you are going'**
  String get lastMileHomeBody;

  /// No description provided for @lastMileFromStation.
  ///
  /// In en, this message translates to:
  /// **'From station'**
  String get lastMileFromStation;

  /// No description provided for @lastMileTo.
  ///
  /// In en, this message translates to:
  /// **'Going to'**
  String get lastMileTo;

  /// No description provided for @lastMileToHint.
  ///
  /// In en, this message translates to:
  /// **'Search a place or pick on the map'**
  String get lastMileToHint;

  /// No description provided for @lastMilePickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on the map'**
  String get lastMilePickOnMap;

  /// No description provided for @lastMileUseThisPoint.
  ///
  /// In en, this message translates to:
  /// **'Use this point'**
  String get lastMileUseThisPoint;

  /// No description provided for @lastMileDroppedPin.
  ///
  /// In en, this message translates to:
  /// **'Point on the map'**
  String get lastMileDroppedPin;

  /// No description provided for @lastMileChooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose where you are going to see your options.'**
  String get lastMileChooseDestination;

  /// No description provided for @lastMileFromHere.
  ///
  /// In en, this message translates to:
  /// **'Last mile from here'**
  String get lastMileFromHere;

  /// No description provided for @searchPlaces.
  ///
  /// In en, this message translates to:
  /// **'Search places'**
  String get searchPlaces;

  /// No description provided for @noPlaceFound.
  ///
  /// In en, this message translates to:
  /// **'No matching place yet. Try picking the point on the map.'**
  String get noPlaceFound;

  /// No description provided for @sortCheapest.
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get sortCheapest;

  /// No description provided for @sortFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get sortFastest;

  /// No description provided for @sortLeastWalking.
  ///
  /// In en, this message translates to:
  /// **'Least walking'**
  String get sortLeastWalking;

  /// No description provided for @distanceStraight.
  ///
  /// In en, this message translates to:
  /// **'{km} km in a straight line'**
  String distanceStraight(String km);

  /// No description provided for @distanceRoadEstimate.
  ///
  /// In en, this message translates to:
  /// **'About {km} km by road (estimated)'**
  String distanceRoadEstimate(String km);

  /// No description provided for @distanceRoad.
  ///
  /// In en, this message translates to:
  /// **'{km} km by road'**
  String distanceRoad(String km);

  /// No description provided for @optWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get optWalk;

  /// No description provided for @optAutoMeter.
  ///
  /// In en, this message translates to:
  /// **'Auto (by meter)'**
  String get optAutoMeter;

  /// No description provided for @optTaxiMeter.
  ///
  /// In en, this message translates to:
  /// **'Kaali-peeli taxi (by meter)'**
  String get optTaxiMeter;

  /// No description provided for @optSharedAuto.
  ///
  /// In en, this message translates to:
  /// **'Shared auto'**
  String get optSharedAuto;

  /// No description provided for @optBus.
  ///
  /// In en, this message translates to:
  /// **'{operator} bus {number}'**
  String optBus(String operator, String number);

  /// No description provided for @fareFrom.
  ///
  /// In en, this message translates to:
  /// **'from ₹{amount}'**
  String fareFrom(int amount);

  /// No description provided for @fareAbout.
  ///
  /// In en, this message translates to:
  /// **'≈ ₹{amount}'**
  String fareAbout(int amount);

  /// No description provided for @fareShared.
  ///
  /// In en, this message translates to:
  /// **'₹{amount} per seat'**
  String fareShared(int amount);

  /// No description provided for @fareUnknown.
  ///
  /// In en, this message translates to:
  /// **'Fare not known'**
  String get fareUnknown;

  /// No description provided for @fareInApp.
  ///
  /// In en, this message translates to:
  /// **'Price in their app'**
  String get fareInApp;

  /// No description provided for @minutesAbout.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min without traffic'**
  String minutesAbout(int minutes);

  /// No description provided for @walkMeters.
  ///
  /// In en, this message translates to:
  /// **'{meters} m walk'**
  String walkMeters(int meters);

  /// No description provided for @nightFareApplied.
  ///
  /// In en, this message translates to:
  /// **'Includes the night charge'**
  String get nightFareApplied;

  /// No description provided for @nearestStand.
  ///
  /// In en, this message translates to:
  /// **'Nearest stand: {name}, {meters} m'**
  String nearestStand(String name, int meters);

  /// No description provided for @noStandKnown.
  ///
  /// In en, this message translates to:
  /// **'No stand mapped near the station yet'**
  String get noStandKnown;

  /// No description provided for @busBoardAlight.
  ///
  /// In en, this message translates to:
  /// **'Board at {board}, get off at {alight}'**
  String busBoardAlight(String board, String alight);

  /// No description provided for @availabilityUnknown.
  ///
  /// In en, this message translates to:
  /// **'We cannot see whether a vehicle is there right now.'**
  String get availabilityUnknown;

  /// No description provided for @openApp.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String openApp(String name);

  /// No description provided for @couldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open the app.'**
  String get couldNotOpen;

  /// No description provided for @howWeEstimate.
  ///
  /// In en, this message translates to:
  /// **'How these numbers are worked out'**
  String get howWeEstimate;

  /// No description provided for @assumptionsBody.
  ///
  /// In en, this message translates to:
  /// **'Road distance is the straight line × 1.3 unless a road route is available. Times assume walking at 4.5 km/h, autos at 18 km/h and taxis at 20 km/h, with no traffic or waiting. Meter fares use the published rate; the meter decides the real fare.'**
  String get assumptionsBody;

  /// No description provided for @fareRuleSource.
  ///
  /// In en, this message translates to:
  /// **'{mode}: rates from {source}, effective {date}'**
  String fareRuleSource(String mode, String source, String date);

  /// No description provided for @noFareRules.
  ///
  /// In en, this message translates to:
  /// **'No fare rates entered yet, so meter fares cannot be estimated.'**
  String get noFareRules;

  /// No description provided for @nearbyPickups.
  ///
  /// In en, this message translates to:
  /// **'Stands near the station'**
  String get nearbyPickups;

  /// No description provided for @nearbyPickupsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stands recorded near this station yet.'**
  String get nearbyPickupsEmpty;

  /// No description provided for @verificationAdmin.
  ///
  /// In en, this message translates to:
  /// **'Checked by us'**
  String get verificationAdmin;

  /// No description provided for @verificationOsm.
  ///
  /// In en, this message translates to:
  /// **'From OpenStreetMap'**
  String get verificationOsm;

  /// No description provided for @verificationCommunity.
  ///
  /// In en, this message translates to:
  /// **'Reported by commuters'**
  String get verificationCommunity;

  /// No description provided for @communityReports.
  ///
  /// In en, this message translates to:
  /// **'Commuter reports'**
  String get communityReports;

  /// No description provided for @communityReportsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reports near this station right now.'**
  String get communityReportsEmpty;

  /// No description provided for @communityReportsOffline.
  ///
  /// In en, this message translates to:
  /// **'Reports need the server, which is not set up yet.'**
  String get communityReportsOffline;

  /// No description provided for @reportSomething.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportSomething;

  /// No description provided for @reportWhere.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get reportWhere;

  /// No description provided for @reportTypeQueue.
  ///
  /// In en, this message translates to:
  /// **'Long queue'**
  String get reportTypeQueue;

  /// No description provided for @reportTypeNoVehicles.
  ///
  /// In en, this message translates to:
  /// **'No autos or taxis'**
  String get reportTypeNoVehicles;

  /// No description provided for @reportTypeStandMoved.
  ///
  /// In en, this message translates to:
  /// **'Stand has moved'**
  String get reportTypeStandMoved;

  /// No description provided for @reportTypeStopIssue.
  ///
  /// In en, this message translates to:
  /// **'Bus stop problem'**
  String get reportTypeStopIssue;

  /// No description provided for @reportTypeClosure.
  ///
  /// In en, this message translates to:
  /// **'Road closed'**
  String get reportTypeClosure;

  /// No description provided for @reportTypeDisruption.
  ///
  /// In en, this message translates to:
  /// **'Disruption'**
  String get reportTypeDisruption;

  /// No description provided for @reportNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Short note (optional)'**
  String get reportNoteHint;

  /// No description provided for @reportPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Others see the report and its place, never your name or account.'**
  String get reportPrivacy;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get reportSubmit;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks. Others will see your report until it expires.'**
  String get reportSent;

  /// No description provided for @reportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Still true'**
  String get reportConfirm;

  /// No description provided for @reportConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by {count}'**
  String reportConfirmed(int count);

  /// No description provided for @reportAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String reportAgo(int minutes);

  /// No description provided for @alertSource.
  ///
  /// In en, this message translates to:
  /// **'Official source'**
  String get alertSource;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminTitle;

  /// No description provided for @adminNoAccess.
  ///
  /// In en, this message translates to:
  /// **'This section is for admins and moderators.'**
  String get adminNoAccess;

  /// No description provided for @adminOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get adminOverview;

  /// No description provided for @adminReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get adminReports;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsers;

  /// No description provided for @adminAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get adminAlerts;

  /// No description provided for @adminAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get adminAudit;

  /// No description provided for @adminSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get adminSaved;

  /// No description provided for @adminUsersActive.
  ///
  /// In en, this message translates to:
  /// **'Active users'**
  String get adminUsersActive;

  /// No description provided for @adminUsersDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get adminUsersDisabled;

  /// No description provided for @adminUsersDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted accounts'**
  String get adminUsersDeleted;

  /// No description provided for @adminAdmins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get adminAdmins;

  /// No description provided for @adminModerators.
  ///
  /// In en, this message translates to:
  /// **'Moderators'**
  String get adminModerators;

  /// No description provided for @adminReportsPending.
  ///
  /// In en, this message translates to:
  /// **'Reports waiting for review'**
  String get adminReportsPending;

  /// No description provided for @adminReportsLive.
  ///
  /// In en, this message translates to:
  /// **'Reports visible now'**
  String get adminReportsLive;

  /// No description provided for @adminAlertsActive.
  ///
  /// In en, this message translates to:
  /// **'Alerts in force'**
  String get adminAlertsActive;

  /// No description provided for @adminDataPackVersion.
  ///
  /// In en, this message translates to:
  /// **'Data pack version'**
  String get adminDataPackVersion;

  /// No description provided for @adminDataPackPublished.
  ///
  /// In en, this message translates to:
  /// **'Last published'**
  String get adminDataPackPublished;

  /// No description provided for @adminRoadDistance.
  ///
  /// In en, this message translates to:
  /// **'Road distances (openrouteservice)'**
  String get adminRoadDistance;

  /// No description provided for @adminOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get adminOn;

  /// No description provided for @adminOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get adminOff;

  /// No description provided for @adminDataHealth.
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get adminDataHealth;

  /// No description provided for @adminNoSync.
  ///
  /// In en, this message translates to:
  /// **'Nothing published from the Sheet yet.'**
  String get adminNoSync;

  /// No description provided for @adminLastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Last success: {when}'**
  String adminLastSuccess(String when);

  /// No description provided for @adminAcceptedRejected.
  ///
  /// In en, this message translates to:
  /// **'{accepted} rows accepted, {rejected} rejected'**
  String adminAcceptedRejected(int accepted, int rejected);

  /// No description provided for @adminNoPending.
  ///
  /// In en, this message translates to:
  /// **'No reports waiting for review.'**
  String get adminNoPending;

  /// No description provided for @adminReporter.
  ///
  /// In en, this message translates to:
  /// **'Sent by account {uid}'**
  String adminReporter(String uid);

  /// No description provided for @adminApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminApprove;

  /// No description provided for @adminReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminReject;

  /// No description provided for @adminSearchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search by email or name'**
  String get adminSearchUsers;

  /// No description provided for @adminDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable account'**
  String get adminDisable;

  /// No description provided for @adminEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable account'**
  String get adminEnable;

  /// No description provided for @adminMakeRole.
  ///
  /// In en, this message translates to:
  /// **'Make {role}'**
  String adminMakeRole(String role);

  /// No description provided for @adminNewAlert.
  ///
  /// In en, this message translates to:
  /// **'New alert'**
  String get adminNewAlert;

  /// No description provided for @adminNoAlerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts yet.'**
  String get adminNoAlerts;

  /// No description provided for @adminEndAlert.
  ///
  /// In en, this message translates to:
  /// **'End now'**
  String get adminEndAlert;

  /// No description provided for @adminEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get adminEnded;

  /// No description provided for @adminRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get adminRequired;

  /// No description provided for @adminAlertScope.
  ///
  /// In en, this message translates to:
  /// **'Applies to'**
  String get adminAlertScope;

  /// No description provided for @adminAlertScopeHelp.
  ///
  /// In en, this message translates to:
  /// **'ALL, a line code (CR-MAIN) or a station code (KYN)'**
  String get adminAlertScopeHelp;

  /// No description provided for @adminAlertTitleEn.
  ///
  /// In en, this message translates to:
  /// **'Title (English)'**
  String get adminAlertTitleEn;

  /// No description provided for @adminAlertTitleMr.
  ///
  /// In en, this message translates to:
  /// **'Title (Marathi, optional)'**
  String get adminAlertTitleMr;

  /// No description provided for @adminAlertTitleHi.
  ///
  /// In en, this message translates to:
  /// **'Title (Hindi, optional)'**
  String get adminAlertTitleHi;

  /// No description provided for @adminAlertBody.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get adminAlertBody;

  /// No description provided for @adminAlertSource.
  ///
  /// In en, this message translates to:
  /// **'Official announcement link'**
  String get adminAlertSource;

  /// No description provided for @adminAlertSourceHelp.
  ///
  /// In en, this message translates to:
  /// **'Must start with https:// and point to the official notice'**
  String get adminAlertSourceHelp;

  /// No description provided for @adminAlertStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get adminAlertStarts;

  /// No description provided for @adminAlertEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get adminAlertEnds;

  /// No description provided for @adminAlertUntilEnded.
  ///
  /// In en, this message translates to:
  /// **'Until ended'**
  String get adminAlertUntilEnded;

  /// No description provided for @adminPublishAlert.
  ///
  /// In en, this message translates to:
  /// **'Publish alert'**
  String get adminPublishAlert;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'You are an admin'**
  String get roleAdmin;

  /// No description provided for @roleModerator.
  ///
  /// In en, this message translates to:
  /// **'You are a moderator'**
  String get roleModerator;

  /// No description provided for @consentPrompt.
  ///
  /// In en, this message translates to:
  /// **'We have a privacy notice that explains what this app keeps about you. Please read it and accept.'**
  String get consentPrompt;

  /// No description provided for @consentRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get consentRead;

  /// No description provided for @consentAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get consentAccept;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice'**
  String get privacyTitle;

  /// No description provided for @privacyVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String privacyVersion(String version);

  /// No description provided for @privacyCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'What we keep'**
  String get privacyCollectTitle;

  /// No description provided for @privacyCollectBody.
  ///
  /// In en, this message translates to:
  /// **'If you sign in: your email and name from your sign-in, your language, saved routes, the reports you send, when your account was created and the last day you used it. Without an account, nothing about you is kept on our server.'**
  String get privacyCollectBody;

  /// No description provided for @privacyNotCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'What we never keep'**
  String get privacyNotCollectTitle;

  /// No description provided for @privacyNotCollectBody.
  ///
  /// In en, this message translates to:
  /// **'Your password (Google Firebase handles sign-in), your location history, contacts or phone number. There are no ads, no tracking and we never sell data.'**
  String get privacyNotCollectBody;

  /// No description provided for @privacyLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get privacyLocationTitle;

  /// No description provided for @privacyLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Your phone\'s location is read only when you tap \"My location\" and stays on the phone. When you choose a destination in the last-mile finder while signed in, the station and destination points are sent to our server to look up the road distance.'**
  String get privacyLocationBody;

  /// No description provided for @privacyReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports you send'**
  String get privacyReportsTitle;

  /// No description provided for @privacyReportsBody.
  ///
  /// In en, this message translates to:
  /// **'Other people see the report, its place (to about 10 metres) and its time, never your name or account. Moderators can see which account sent a report, only to deal with abuse. Reports disappear when they expire.'**
  String get privacyReportsBody;

  /// No description provided for @privacyRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your choices'**
  String get privacyRightsTitle;

  /// No description provided for @privacyRightsBody.
  ///
  /// In en, this message translates to:
  /// **'Delete account (Profile) removes your email, name and saved routes and closes your sign-in. Reports you sent stay for other commuters but are no longer linked to you. You can use the app without an account.'**
  String get privacyRightsBody;

  /// No description provided for @privacyThirdPartyTitle.
  ///
  /// In en, this message translates to:
  /// **'Services we rely on'**
  String get privacyThirdPartyTitle;

  /// No description provided for @privacyThirdPartyBody.
  ///
  /// In en, this message translates to:
  /// **'Google Firebase (sign-in) and Google Apps Script and Sheets (our server and storage); OpenStreetMap tile servers when the map loads; openrouteservice for road distances if enabled; and Uber, Ola or Rapido only when you tap their button. Place search sends only the words you type to Photon (OpenStreetMap data).'**
  String get privacyThirdPartyBody;

  /// No description provided for @searchAnyPlace.
  ///
  /// In en, this message translates to:
  /// **'Search a station, area or building'**
  String get searchAnyPlace;

  /// No description provided for @stationLabel.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get stationLabel;

  /// No description provided for @typeMoreToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type at least 3 letters to search more places.'**
  String get typeMoreToSearch;

  /// No description provided for @moreFromOsm.
  ///
  /// In en, this message translates to:
  /// **'More places (OpenStreetMap)'**
  String get moreFromOsm;

  /// No description provided for @onlineSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t search online. Check your internet, or pick the place on the map.'**
  String get onlineSearchFailed;

  /// No description provided for @osmSearchCredit.
  ///
  /// In en, this message translates to:
  /// **'Place search uses OpenStreetMap data via Photon. Only the words you type are sent.'**
  String get osmSearchCredit;

  /// No description provided for @tripTitle.
  ///
  /// In en, this message translates to:
  /// **'Your journey'**
  String get tripTitle;

  /// No description provided for @tripRoadOnlyClose.
  ///
  /// In en, this message translates to:
  /// **'These places are close, so going by road is simplest.'**
  String get tripRoadOnlyClose;

  /// No description provided for @tripNoStationNear.
  ///
  /// In en, this message translates to:
  /// **'No station in the app is near one of these places yet, so only road options are shown.'**
  String get tripNoStationNear;

  /// No description provided for @tripByRoad.
  ///
  /// In en, this message translates to:
  /// **'Direct by road'**
  String get tripByRoad;

  /// No description provided for @tripByTrain.
  ///
  /// In en, this message translates to:
  /// **'By train'**
  String get tripByTrain;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'about {minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @tripLegToStation.
  ///
  /// In en, this message translates to:
  /// **'Get to {station} station'**
  String tripLegToStation(String station);

  /// No description provided for @tripLegFromStation.
  ///
  /// In en, this message translates to:
  /// **'{station} station to {place}'**
  String tripLegFromStation(String station, String place);

  /// No description provided for @autoStand.
  ///
  /// In en, this message translates to:
  /// **'Auto stand'**
  String get autoStand;

  /// No description provided for @bookInApp.
  ///
  /// In en, this message translates to:
  /// **'Book a ride'**
  String get bookInApp;

  /// No description provided for @bookInAppNote.
  ///
  /// In en, this message translates to:
  /// **'Opens the app; the app shows the real price and whether a vehicle is free.'**
  String get bookInAppNote;

  /// No description provided for @departingNow.
  ///
  /// In en, this message translates to:
  /// **'Leaving now'**
  String get departingNow;

  /// No description provided for @fareTrainTicketOnly.
  ///
  /// In en, this message translates to:
  /// **'Train ticket only'**
  String get fareTrainTicketOnly;

  /// No description provided for @noBusData.
  ///
  /// In en, this message translates to:
  /// **'No bus stops for this area are in the app yet.'**
  String get noBusData;

  /// No description provided for @noLiveAutos.
  ///
  /// In en, this message translates to:
  /// **'Autos have no live tracking anywhere, so the app shows the stands where autos usually wait, not moving vehicles.'**
  String get noLiveAutos;

  /// No description provided for @noLiveBuses.
  ///
  /// In en, this message translates to:
  /// **'Local buses here share no live location, so the app shows the stops and how often buses come, not moving buses.'**
  String get noLiveBuses;

  /// No description provided for @optionAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto all the way'**
  String get optionAuto;

  /// No description provided for @optionBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get optionBus;

  /// No description provided for @optionCab.
  ///
  /// In en, this message translates to:
  /// **'Taxi or cab'**
  String get optionCab;

  /// No description provided for @optionTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get optionTrain;

  /// No description provided for @optionTrainAuto.
  ///
  /// In en, this message translates to:
  /// **'Train + auto'**
  String get optionTrainAuto;

  /// No description provided for @optionsTimeNote.
  ///
  /// In en, this message translates to:
  /// **'Times are estimates without traffic or waiting. Fares use the official meter rate; the meter decides the real fare.'**
  String get optionsTimeNote;

  /// No description provided for @scheduledNotLive.
  ///
  /// In en, this message translates to:
  /// **'Position from the timetable, not live GPS. Trains can run late.'**
  String get scheduledNotLive;

  /// No description provided for @seeDetails.
  ///
  /// In en, this message translates to:
  /// **'See details'**
  String get seeDetails;

  /// No description provided for @tagCheapest.
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get tagCheapest;

  /// No description provided for @tagEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get tagEstimate;

  /// No description provided for @tagFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get tagFastest;

  /// No description provided for @tagScheduled.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get tagScheduled;

  /// No description provided for @whereIsMyAuto.
  ///
  /// In en, this message translates to:
  /// **'Where is my auto'**
  String get whereIsMyAuto;

  /// No description provided for @whereIsMyBus.
  ///
  /// In en, this message translates to:
  /// **'Where is my bus'**
  String get whereIsMyBus;

  /// No description provided for @whereIsMyTrain.
  ///
  /// In en, this message translates to:
  /// **'Where is my train'**
  String get whereIsMyTrain;

  /// No description provided for @whereShort.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get whereShort;

  /// No description provided for @youBoardHere.
  ///
  /// In en, this message translates to:
  /// **'You board here'**
  String get youBoardHere;

  /// No description provided for @youGetOffHere.
  ///
  /// In en, this message translates to:
  /// **'You get off here'**
  String get youGetOffHere;

  /// No description provided for @farePlusTicket.
  ///
  /// In en, this message translates to:
  /// **'≈ ₹{amount} + train ticket'**
  String farePlusTicket(int amount);

  /// No description provided for @inMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {minutes} min'**
  String inMinutes(int minutes);

  /// No description provided for @minutesBig.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesBig(int minutes);

  /// No description provided for @reachesAt.
  ///
  /// In en, this message translates to:
  /// **'reaches at {time}'**
  String reachesAt(String time);

  /// No description provided for @standsNear.
  ///
  /// In en, this message translates to:
  /// **'Auto stands near {place}'**
  String standsNear(String place);

  /// No description provided for @stopsNear.
  ///
  /// In en, this message translates to:
  /// **'Bus stops near {place}'**
  String stopsNear(String place);

  /// No description provided for @stepAutoTo.
  ///
  /// In en, this message translates to:
  /// **'Auto to {place}'**
  String stepAutoTo(String place);

  /// No description provided for @stepWalkTo.
  ///
  /// In en, this message translates to:
  /// **'Walk to {place}'**
  String stepWalkTo(String place);

  /// No description provided for @timetableComingFor.
  ///
  /// In en, this message translates to:
  /// **'Train times aren\'t loaded yet. Once the official Central Railway timetable is added, trains from {from} to {to} appear here, each with \"Where is my train\".'**
  String timetableComingFor(String from, String to);

  /// No description provided for @trainArrivingNow.
  ///
  /// In en, this message translates to:
  /// **'Arriving at {station} now'**
  String trainArrivingNow(String station);

  /// No description provided for @trainAtNow.
  ///
  /// In en, this message translates to:
  /// **'At {station} now'**
  String trainAtNow(String station);

  /// No description provided for @trainFinished.
  ///
  /// In en, this message translates to:
  /// **'Reached {station}, journey over'**
  String trainFinished(String station);

  /// No description provided for @trainLeftAgo.
  ///
  /// In en, this message translates to:
  /// **'Left {station} {minutes} min ago'**
  String trainLeftAgo(String station, int minutes);

  /// No description provided for @trainNowAt.
  ///
  /// In en, this message translates to:
  /// **'Now at {station}'**
  String trainNowAt(String station);

  /// No description provided for @trainNowBetween.
  ///
  /// In en, this message translates to:
  /// **'Between {a} and {b}'**
  String trainNowBetween(String a, String b);

  /// No description provided for @trainReached.
  ///
  /// In en, this message translates to:
  /// **'Reached {station}'**
  String trainReached(String station);

  /// No description provided for @trainReachesIn.
  ///
  /// In en, this message translates to:
  /// **'Reaches {station} in {minutes} min'**
  String trainReachesIn(String station, int minutes);

  /// No description provided for @trainStartsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts from {station} at {time}'**
  String trainStartsAt(String station, String time);

  /// No description provided for @trainsBetween.
  ///
  /// In en, this message translates to:
  /// **'Trains {from} → {to}'**
  String trainsBetween(String from, String to);

  /// No description provided for @waysToGo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 way to go} other{{count} ways to go}}'**
  String waysToGo(int count);

  /// No description provided for @boardAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Board at:'**
  String get boardAtLabel;

  /// No description provided for @getOffAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Get off at:'**
  String get getOffAtLabel;

  /// No description provided for @trainComingFrom.
  ///
  /// In en, this message translates to:
  /// **'Coming from {origin}; reaches {station} at {time}'**
  String trainComingFrom(String origin, String station, String time);

  /// No description provided for @timetableSourceNote.
  ///
  /// In en, this message translates to:
  /// **'Times from Central Railway\'s official timetable (from {date}). Some trains have changed since, so check the station display before you travel.'**
  String timetableSourceNote(String date);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trains, autos, buses and cabs in one place'**
  String get homeSubtitle;

  /// No description provided for @trackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your ride'**
  String get trackTitle;

  /// No description provided for @whereIsMyCab.
  ///
  /// In en, this message translates to:
  /// **'Where is my cab'**
  String get whereIsMyCab;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @nextTrainsFrom.
  ///
  /// In en, this message translates to:
  /// **'Next trains from {station}'**
  String nextTrainsFrom(String station);

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @allTrains.
  ///
  /// In en, this message translates to:
  /// **'All trains'**
  String get allTrains;

  /// No description provided for @checkStationDisplay.
  ///
  /// In en, this message translates to:
  /// **'Check the station display before you travel'**
  String get checkStationDisplay;

  /// No description provided for @buildLabel.
  ///
  /// In en, this message translates to:
  /// **'Build {number} · {sha}'**
  String buildLabel(String number, String sha);

  /// No description provided for @buildLabelLocal.
  ///
  /// In en, this message translates to:
  /// **'Local build'**
  String get buildLabelLocal;

  /// No description provided for @whereIsMyCabTitle.
  ///
  /// In en, this message translates to:
  /// **'Where is my cab'**
  String get whereIsMyCabTitle;

  /// No description provided for @liveCabsInApps.
  ///
  /// In en, this message translates to:
  /// **'Live cars and autos near you are shown only inside the Uber, Ola and Rapido apps. Tap one to see them there.'**
  String get liveCabsInApps;

  /// No description provided for @seeLiveInApp.
  ///
  /// In en, this message translates to:
  /// **'See live cars in the app'**
  String get seeLiveInApp;

  /// No description provided for @taxiStandsNear.
  ///
  /// In en, this message translates to:
  /// **'Taxi stands near {place}'**
  String taxiStandsNear(String place);

  /// No description provided for @nearestFarAway.
  ///
  /// In en, this message translates to:
  /// **'Nearest ones, a bit farther away'**
  String get nearestFarAway;

  /// No description provided for @noTaxiStands.
  ///
  /// In en, this message translates to:
  /// **'No taxi stands mapped near here yet.'**
  String get noTaxiStands;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String kmAway(String km);

  /// No description provided for @fromPlace.
  ///
  /// In en, this message translates to:
  /// **'from {place}'**
  String fromPlace(String place);

  /// No description provided for @addedByYou.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get addedByYou;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @addAutoStand.
  ///
  /// In en, this message translates to:
  /// **'Add an auto stand you know'**
  String get addAutoStand;

  /// No description provided for @addTaxiStand.
  ///
  /// In en, this message translates to:
  /// **'Add a taxi stand you know'**
  String get addTaxiStand;

  /// No description provided for @addStandNote.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone, so next time it shows right here.'**
  String get addStandNote;

  /// No description provided for @standNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name, e.g. Station Road stand'**
  String get standNameLabel;

  /// No description provided for @taxiStand.
  ///
  /// In en, this message translates to:
  /// **'Taxi stand'**
  String get taxiStand;

  /// No description provided for @openShort.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openShort;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
