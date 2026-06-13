// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeSubtitle => 'A strategy game for 2 players';

  @override
  String get homeTagline => 'Capture, Block, Dominate... the Nexus!';

  @override
  String get homePlayLocal => 'PLAY LOCAL';

  @override
  String get homePlayOnline => 'PLAY ONLINE';

  @override
  String get multiplayer => 'Multiplayer';

  @override
  String get createGame => 'Create a game';

  @override
  String get joinGame => 'Join a game';

  @override
  String get homeRulesButton => 'RULES';

  @override
  String get homeNexusButton => 'NEXUS';

  @override
  String get newGame => 'New game';

  @override
  String get gameModeSection => 'Game mode';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get winConditionSection => 'Win condition';

  @override
  String get startsFirst => 'Starts first';

  @override
  String get boardType => 'Board type';

  @override
  String get boardSizeSection => 'Board size';

  @override
  String get vsAI => 'vs AI';

  @override
  String get vsAISubtitle => 'Play against Blob';

  @override
  String get twoPlayers => '2 Players';

  @override
  String get twoPlayersSubtitle => 'Play with a friend';

  @override
  String get boardSquare => 'Square';

  @override
  String get boardSquareSubtitle => '5x5 or 7x7 cells';

  @override
  String get hexagonal => 'Hexagonal';

  @override
  String get boardHexSubtitle => '37 hexagons';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyNormal => 'Advanced';

  @override
  String get difficultyHard => 'Expert';

  @override
  String get boardSize5Desc => '5 pawns per player\nQuick games';

  @override
  String get boardSize7Desc => '7 pawns per player\nLong games';

  @override
  String get winOwnCamp => 'Own camp';

  @override
  String get winOwnCampSubtitle => 'Bring the Nexus back to your camp';

  @override
  String get winOpponentCamp => 'Opponent camp';

  @override
  String get winOpponentCampSubtitle =>
      'Bring the Nexus to the opponent\'s camp';

  @override
  String get teamBlue => 'Blue';

  @override
  String get teamRed => 'Red';

  @override
  String get player1Starts => 'Player 1 starts';

  @override
  String get player2Starts => 'Player 2 starts';

  @override
  String get start => 'START';

  @override
  String get rulesTitle => 'Game rules';

  @override
  String get rulesBoardTitle => 'The board';

  @override
  String get rulesBoardContent =>
      'The game is played on a square board (5x5 or 7x7 cells) or a hexagonal one. Each player has 5 or 7 pawns placed on their starting row. The Nexus is placed at the center of the board.';

  @override
  String get rulesObjectiveTitle => 'Objective';

  @override
  String get rulesObjectiveContent =>
      'A player wins the game if they manage to:\n\n1. Bring the Nexus to the row of their color\n\n2. Immobilize the Nexus by strategic encirclement (inspired by Go)';

  @override
  String get rulesTurnTitle => 'How a turn works';

  @override
  String get rulesTurnContent =>
      'On their turn, a player performs 2 actions in this order:\n\n1. Move the Nexus by a single cell (like the King in chess)\n\n2. Move one of their pawns to the end of the line (like the Queen in chess)';

  @override
  String get rulesImportantTitle => 'Important rules';

  @override
  String get rulesImportantContent =>
      '• The Nexus moves one cell in any direction (King)\n\n• Pawns slide to the end in the chosen direction (Queen)\n\n• No piece can jump over another\n\n• 8 directions on a square board, 6 on a hexagonal board';

  @override
  String get rulesPiecesTitle => 'The pieces';

  @override
  String get nexus => 'Nexus';

  @override
  String get rulesNexusMove => 'Moves like the King in chess';

  @override
  String get rulesPiecesP1 => 'Player 1 pawns';

  @override
  String get rulesPiecesP2 => 'Player 2 pawns';

  @override
  String get rulesPawnMove => 'Move like the Queen in chess';

  @override
  String get you => 'You';

  @override
  String get computer => 'Computer';

  @override
  String get player1 => 'Player 1';

  @override
  String get player2 => 'Player 2';

  @override
  String get moveNexusAction => 'Move the Nexus';

  @override
  String get movePawnAction => 'Move a pawn';

  @override
  String get wins => 'Wins!';

  @override
  String get thinking => 'Thinking...';

  @override
  String get opponent => 'Opponent';

  @override
  String get connectionLost => 'Connection lost';

  @override
  String get back => 'Back';

  @override
  String get leaveGameTitle => 'Leave the game?';

  @override
  String get leaveGameContent => 'You are about to forfeit the current game.';

  @override
  String get cancel => 'Cancel';

  @override
  String get leave => 'Leave';

  @override
  String get yourTurn => 'Your turn';

  @override
  String get waiting => 'Waiting...';

  @override
  String get loading => 'Loading';

  @override
  String multiplayerCodeLabel(String code) {
    return 'Code: $code';
  }

  @override
  String get youPlayBlue => 'You play Blue';

  @override
  String get youPlayRed => 'You play Red';

  @override
  String get enterCodeError => 'Enter a code';

  @override
  String get join => 'Join';

  @override
  String get gameCodeLabel => 'Game code';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get enterCode => 'Enter the code';

  @override
  String get configuration => 'Configuration';

  @override
  String get boardLabel => 'Board';

  @override
  String get victoryLabel => 'Victory';

  @override
  String get startsLabel => 'Starts';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorRed => 'Red';

  @override
  String get players => 'Players';

  @override
  String get youHost => 'You (host)';

  @override
  String get host => 'Host';

  @override
  String get startGameButton => 'Start the game';

  @override
  String get waitingOpponent => 'Waiting for an opponent...';

  @override
  String get waitingHostStart => 'Waiting for the host to start...';

  @override
  String shareMessage(String link) {
    return 'Join my Kaptis game!\n$link';
  }

  @override
  String get customizeNexus => 'Customize the Nexus';

  @override
  String get color => 'Color';

  @override
  String get shape => 'Shape';

  @override
  String get skinCoreTitle => 'Core';

  @override
  String get skinCoreSubtitle => 'Energetic core';

  @override
  String get skinDiamondTitle => 'Diamond';

  @override
  String get skinDiamondSubtitle => 'Diamond shape';

  @override
  String get skinCrystalTitle => 'Crystal';

  @override
  String get skinCrystalSubtitle => 'Hexagonal gem';

  @override
  String get skinOrbTitle => 'Orb';

  @override
  String get skinOrbSubtitle => 'Pulsing sphere';

  @override
  String get skinVortexTitle => 'Vortex';

  @override
  String get skinVortexSubtitle => 'Rotating spiral';

  @override
  String get skinStarTitle => 'Star';

  @override
  String get skinStarSubtitle => 'Shining star';

  @override
  String get skinSunTitle => 'Sun';

  @override
  String get skinSunSubtitle => 'Radiant sun';

  @override
  String get replay => 'Replay';

  @override
  String get menu => 'Menu';

  @override
  String get errorRoomNotFound => 'Game not found';

  @override
  String get errorRoomFull => 'The game is full';

  @override
  String get errorAlreadyStarted => 'The game has already started';
}
