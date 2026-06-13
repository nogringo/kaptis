import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
    Locale('fr'),
  ];

  /// Home screen subtitle under the title
  ///
  /// In en, this message translates to:
  /// **'A strategy game for 2 players'**
  String get homeSubtitle;

  /// Home screen tagline
  ///
  /// In en, this message translates to:
  /// **'Capture, Block, Dominate... the Nexus!'**
  String get homeTagline;

  /// Home button to start a local game
  ///
  /// In en, this message translates to:
  /// **'PLAY LOCAL'**
  String get homePlayLocal;

  /// Home button to start an online game
  ///
  /// In en, this message translates to:
  /// **'PLAY ONLINE'**
  String get homePlayOnline;

  /// Title of the multiplayer options dialog
  ///
  /// In en, this message translates to:
  /// **'Multiplayer'**
  String get multiplayer;

  /// Option/title to create a multiplayer game
  ///
  /// In en, this message translates to:
  /// **'Create a game'**
  String get createGame;

  /// Option to join an existing multiplayer game
  ///
  /// In en, this message translates to:
  /// **'Join a game'**
  String get joinGame;

  /// Home button opening the rules screen
  ///
  /// In en, this message translates to:
  /// **'RULES'**
  String get homeRulesButton;

  /// Home button opening the Nexus customization screen
  ///
  /// In en, this message translates to:
  /// **'NEXUS'**
  String get homeNexusButton;

  /// Setup screen title / restart action for a new game
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGame;

  /// Setup section title: choose game mode
  ///
  /// In en, this message translates to:
  /// **'Game mode'**
  String get gameModeSection;

  /// Setup section title: AI difficulty
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Setup section title: win condition
  ///
  /// In en, this message translates to:
  /// **'Win condition'**
  String get winConditionSection;

  /// Setup section title: who plays first
  ///
  /// In en, this message translates to:
  /// **'Starts first'**
  String get startsFirst;

  /// Setup section title: board type (square/hex)
  ///
  /// In en, this message translates to:
  /// **'Board type'**
  String get boardType;

  /// Setup section title: board size
  ///
  /// In en, this message translates to:
  /// **'Board size'**
  String get boardSizeSection;

  /// Setup card title: play against the computer
  ///
  /// In en, this message translates to:
  /// **'vs AI'**
  String get vsAI;

  /// Setup card subtitle for vs AI mode (Blob is the AI name)
  ///
  /// In en, this message translates to:
  /// **'Play against Blob'**
  String get vsAISubtitle;

  /// Setup card title: two local players
  ///
  /// In en, this message translates to:
  /// **'2 Players'**
  String get twoPlayers;

  /// Setup card subtitle for two-player mode
  ///
  /// In en, this message translates to:
  /// **'Play with a friend'**
  String get twoPlayersSubtitle;

  /// Setup card title: square board
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get boardSquare;

  /// Setup card subtitle for the square board
  ///
  /// In en, this message translates to:
  /// **'5x5 or 7x7 cells'**
  String get boardSquareSubtitle;

  /// Hexagonal board type label
  ///
  /// In en, this message translates to:
  /// **'Hexagonal'**
  String get hexagonal;

  /// Setup card subtitle for the hexagonal board
  ///
  /// In en, this message translates to:
  /// **'37 hexagons'**
  String get boardHexSubtitle;

  /// AI difficulty: easy
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// AI difficulty: normal/advanced
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get difficultyNormal;

  /// AI difficulty: hard/expert
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get difficultyHard;

  /// Description of the 5x5 board option (two lines)
  ///
  /// In en, this message translates to:
  /// **'5 pawns per player\nQuick games'**
  String get boardSize5Desc;

  /// Description of the 7x7 board option (two lines)
  ///
  /// In en, this message translates to:
  /// **'7 pawns per player\nLong games'**
  String get boardSize7Desc;

  /// Win condition: bring the Nexus to your own camp
  ///
  /// In en, this message translates to:
  /// **'Own camp'**
  String get winOwnCamp;

  /// Subtitle for the own-camp win condition
  ///
  /// In en, this message translates to:
  /// **'Bring the Nexus back to your camp'**
  String get winOwnCampSubtitle;

  /// Win condition: bring the Nexus to the opponent camp
  ///
  /// In en, this message translates to:
  /// **'Opponent camp'**
  String get winOpponentCamp;

  /// Subtitle for the opponent-camp win condition
  ///
  /// In en, this message translates to:
  /// **'Bring the Nexus to the opponent\'s camp'**
  String get winOpponentCampSubtitle;

  /// Blue team label (plural in some languages, e.g. setup starting-player card)
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get teamBlue;

  /// Red team label (plural in some languages, e.g. setup starting-player card)
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get teamRed;

  /// Subtitle: player 1 starts first
  ///
  /// In en, this message translates to:
  /// **'Player 1 starts'**
  String get player1Starts;

  /// Subtitle: player 2 starts first
  ///
  /// In en, this message translates to:
  /// **'Player 2 starts'**
  String get player2Starts;

  /// Button to start the configured game
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// Rules screen app bar title
  ///
  /// In en, this message translates to:
  /// **'Game rules'**
  String get rulesTitle;

  /// Rules section title: the board
  ///
  /// In en, this message translates to:
  /// **'The board'**
  String get rulesBoardTitle;

  /// Rules section content: the board
  ///
  /// In en, this message translates to:
  /// **'The game is played on a square board (5x5 or 7x7 cells) or a hexagonal one. Each player has 5 or 7 pawns placed on their starting row. The Nexus is placed at the center of the board.'**
  String get rulesBoardContent;

  /// Rules section title: objective
  ///
  /// In en, this message translates to:
  /// **'Objective'**
  String get rulesObjectiveTitle;

  /// Rules section content: objective (multi-line)
  ///
  /// In en, this message translates to:
  /// **'A player wins the game if they manage to:\n\n1. Bring the Nexus to the row of their color\n\n2. Immobilize the Nexus by strategic encirclement (inspired by Go)'**
  String get rulesObjectiveContent;

  /// Rules section title: turn flow
  ///
  /// In en, this message translates to:
  /// **'How a turn works'**
  String get rulesTurnTitle;

  /// Rules section content: turn flow (multi-line)
  ///
  /// In en, this message translates to:
  /// **'On their turn, a player performs 2 actions in this order:\n\n1. Move the Nexus by a single cell (like the King in chess)\n\n2. Move one of their pawns to the end of the line (like the Queen in chess)'**
  String get rulesTurnContent;

  /// Rules section title: important rules
  ///
  /// In en, this message translates to:
  /// **'Important rules'**
  String get rulesImportantTitle;

  /// Rules section content: important rules (multi-line, bullet list)
  ///
  /// In en, this message translates to:
  /// **'• The Nexus moves one cell in any direction (King)\n\n• Pawns slide to the end in the chosen direction (Queen)\n\n• No piece can jump over another\n\n• 8 directions on a square board, 6 on a hexagonal board'**
  String get rulesImportantContent;

  /// Rules section title: the pieces legend
  ///
  /// In en, this message translates to:
  /// **'The pieces'**
  String get rulesPiecesTitle;

  /// Name of the central Nexus piece
  ///
  /// In en, this message translates to:
  /// **'Nexus'**
  String get nexus;

  /// Legend description of how the Nexus moves
  ///
  /// In en, this message translates to:
  /// **'Moves like the King in chess'**
  String get rulesNexusMove;

  /// Legend label for player 1 pawns
  ///
  /// In en, this message translates to:
  /// **'Player 1 pawns'**
  String get rulesPiecesP1;

  /// Legend label for player 2 pawns
  ///
  /// In en, this message translates to:
  /// **'Player 2 pawns'**
  String get rulesPiecesP2;

  /// Legend description of how pawns move
  ///
  /// In en, this message translates to:
  /// **'Move like the Queen in chess'**
  String get rulesPawnMove;

  /// Status label referring to the local player
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Status label referring to the AI player
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get computer;

  /// Status label for player 1 in local two-player mode
  ///
  /// In en, this message translates to:
  /// **'Player 1'**
  String get player1;

  /// Status label for player 2 in local two-player mode
  ///
  /// In en, this message translates to:
  /// **'Player 2'**
  String get player2;

  /// Status prompt: it is time to move the Nexus
  ///
  /// In en, this message translates to:
  /// **'Move the Nexus'**
  String get moveNexusAction;

  /// Status prompt: it is time to move a pawn
  ///
  /// In en, this message translates to:
  /// **'Move a pawn'**
  String get movePawnAction;

  /// Status/victory text shown after a player name (e.g. 'You Wins!')
  ///
  /// In en, this message translates to:
  /// **'Wins!'**
  String get wins;

  /// Status text while the AI computes its move
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// Status label referring to the remote opponent
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get opponent;

  /// Shown when the multiplayer room is no longer available
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get connectionLost;

  /// Generic back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Confirmation dialog title when leaving a game
  ///
  /// In en, this message translates to:
  /// **'Leave the game?'**
  String get leaveGameTitle;

  /// Confirmation dialog body when leaving a game
  ///
  /// In en, this message translates to:
  /// **'You are about to forfeit the current game.'**
  String get leaveGameContent;

  /// Cancel button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm-leave button in the leave-game dialog
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// Connection status badge: it is the local player's turn
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get yourTurn;

  /// Status: waiting (for opponent's turn or for a player to join)
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get waiting;

  /// Status label while the board state is loading
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// Room code shown in the multiplayer game sidebar
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String multiplayerCodeLabel(String code);

  /// Sidebar info: the local player controls the blue team
  ///
  /// In en, this message translates to:
  /// **'You play Blue'**
  String get youPlayBlue;

  /// Sidebar info: the local player controls the red team
  ///
  /// In en, this message translates to:
  /// **'You play Red'**
  String get youPlayRed;

  /// Validation error when the room code field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a code'**
  String get enterCodeError;

  /// Join button / app bar title when joining a room
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// Label above the displayed room code
  ///
  /// In en, this message translates to:
  /// **'Game code'**
  String get gameCodeLabel;

  /// Button to copy the room code
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Button to share the room invite link
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Prompt above the room code input field
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get enterCode;

  /// Lobby section title: game configuration
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// Lobby config row label: board
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get boardLabel;

  /// Lobby config row label: victory/win condition
  ///
  /// In en, this message translates to:
  /// **'Victory'**
  String get victoryLabel;

  /// Lobby config row label: who starts
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get startsLabel;

  /// Blue color label (singular, lobby dropdown/readout)
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// Red color label (singular, lobby dropdown/readout)
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// Lobby section title: players list
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// Lobby player row label for the local host
  ///
  /// In en, this message translates to:
  /// **'You (host)'**
  String get youHost;

  /// Lobby player row label for the remote host
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// Host button to launch the game once an opponent joined
  ///
  /// In en, this message translates to:
  /// **'Start the game'**
  String get startGameButton;

  /// Host status while no opponent has joined yet
  ///
  /// In en, this message translates to:
  /// **'Waiting for an opponent...'**
  String get waitingOpponent;

  /// Guest status while waiting for the host to launch the game
  ///
  /// In en, this message translates to:
  /// **'Waiting for the host to start...'**
  String get waitingHostStart;

  /// Text shared via the system share sheet to invite a player
  ///
  /// In en, this message translates to:
  /// **'Join my Kaptis game!\n{link}'**
  String shareMessage(String link);

  /// Nexus customization screen app bar title
  ///
  /// In en, this message translates to:
  /// **'Customize the Nexus'**
  String get customizeNexus;

  /// Section title: Nexus color
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Section title: Nexus shape
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get shape;

  /// Nexus skin name: core
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get skinCoreTitle;

  /// Nexus skin description: core
  ///
  /// In en, this message translates to:
  /// **'Energetic core'**
  String get skinCoreSubtitle;

  /// Nexus skin name: diamond
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get skinDiamondTitle;

  /// Nexus skin description: diamond
  ///
  /// In en, this message translates to:
  /// **'Diamond shape'**
  String get skinDiamondSubtitle;

  /// Nexus skin name: crystal
  ///
  /// In en, this message translates to:
  /// **'Crystal'**
  String get skinCrystalTitle;

  /// Nexus skin description: crystal
  ///
  /// In en, this message translates to:
  /// **'Hexagonal gem'**
  String get skinCrystalSubtitle;

  /// Nexus skin name: orb
  ///
  /// In en, this message translates to:
  /// **'Orb'**
  String get skinOrbTitle;

  /// Nexus skin description: orb
  ///
  /// In en, this message translates to:
  /// **'Pulsing sphere'**
  String get skinOrbSubtitle;

  /// Nexus skin name: vortex
  ///
  /// In en, this message translates to:
  /// **'Vortex'**
  String get skinVortexTitle;

  /// Nexus skin description: vortex
  ///
  /// In en, this message translates to:
  /// **'Rotating spiral'**
  String get skinVortexSubtitle;

  /// Nexus skin name: star
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get skinStarTitle;

  /// Nexus skin description: star
  ///
  /// In en, this message translates to:
  /// **'Shining star'**
  String get skinStarSubtitle;

  /// Nexus skin name: sun
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get skinSunTitle;

  /// Nexus skin description: sun
  ///
  /// In en, this message translates to:
  /// **'Radiant sun'**
  String get skinSunSubtitle;

  /// Victory dialog button to play again
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// Victory dialog button to return to the menu
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Multiplayer error: the room code does not exist
  ///
  /// In en, this message translates to:
  /// **'Game not found'**
  String get errorRoomNotFound;

  /// Multiplayer error: the room already has two players
  ///
  /// In en, this message translates to:
  /// **'The game is full'**
  String get errorRoomFull;

  /// Multiplayer error: the room is no longer joinable
  ///
  /// In en, this message translates to:
  /// **'The game has already started'**
  String get errorAlreadyStarted;
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
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
