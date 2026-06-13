// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get homeSubtitle => 'Jeu de stratégie pour 2 joueurs';

  @override
  String get homeTagline => 'Capture, Bloque, Domine... le Nexus !';

  @override
  String get homePlayLocal => 'JOUER EN LOCAL';

  @override
  String get homePlayOnline => 'JOUER EN LIGNE';

  @override
  String get multiplayer => 'Multijoueur';

  @override
  String get createGame => 'Créer une partie';

  @override
  String get joinGame => 'Rejoindre une partie';

  @override
  String get homeRulesButton => 'RÈGLES';

  @override
  String get homeNexusButton => 'NEXUS';

  @override
  String get newGame => 'Nouvelle partie';

  @override
  String get gameModeSection => 'Mode de jeu';

  @override
  String get difficulty => 'Difficulté';

  @override
  String get winConditionSection => 'Condition de victoire';

  @override
  String get startsFirst => 'Commence en premier';

  @override
  String get boardType => 'Type de plateau';

  @override
  String get boardSizeSection => 'Taille du plateau';

  @override
  String get vsAI => 'vs IA';

  @override
  String get vsAISubtitle => 'Jouer avec Blob';

  @override
  String get twoPlayers => '2 Joueurs';

  @override
  String get twoPlayersSubtitle => 'Jouer avec un ami';

  @override
  String get boardSquare => 'Carré';

  @override
  String get boardSquareSubtitle => '5x5 ou 7x7 cases';

  @override
  String get hexagonal => 'Hexagonal';

  @override
  String get boardHexSubtitle => '37 hexagones';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyNormal => 'Avancé';

  @override
  String get difficultyHard => 'Expert';

  @override
  String get boardSize5Desc => '5 pions par joueur\nParties rapides';

  @override
  String get boardSize7Desc => '7 pions par joueur\nParties longues';

  @override
  String get winOwnCamp => 'Son camp';

  @override
  String get winOwnCampSubtitle => 'Ramener le Nexus dans son camp';

  @override
  String get winOpponentCamp => 'Camp adverse';

  @override
  String get winOpponentCampSubtitle => 'Amener le Nexus chez l\'adversaire';

  @override
  String get teamBlue => 'Bleus';

  @override
  String get teamRed => 'Rouges';

  @override
  String get player1Starts => 'Joueur 1 commence';

  @override
  String get player2Starts => 'Joueur 2 commence';

  @override
  String get start => 'COMMENCER';

  @override
  String get rulesTitle => 'Règles du jeu';

  @override
  String get rulesBoardTitle => 'Le plateau';

  @override
  String get rulesBoardContent =>
      'Le jeu se joue sur un plateau carré (5x5 ou 7x7 cases) ou hexagonal. Chaque joueur possède 5 ou 7 pions placés sur sa ligne de départ. Le Nexus est placé au centre du plateau.';

  @override
  String get rulesObjectiveTitle => 'Objectif';

  @override
  String get rulesObjectiveContent =>
      'Un joueur gagne la partie s\'il réussit à :\n\n1. Amener le Nexus sur la ligne de sa couleur\n\n2. Immobiliser le Nexus par encerclement stratégique (inspiré du Go)';

  @override
  String get rulesTurnTitle => 'Déroulement d\'un tour';

  @override
  String get rulesTurnContent =>
      'À son tour, un joueur effectue 2 actions dans cet ordre :\n\n1. Déplacer le Nexus d\'une seule case (comme le Roi aux échecs)\n\n2. Déplacer un de ses pions jusqu\'au bout de la ligne (comme la Dame aux échecs)';

  @override
  String get rulesImportantTitle => 'Règles importantes';

  @override
  String get rulesImportantContent =>
      '• Le Nexus se déplace d\'une case dans toutes les directions (Roi)\n\n• Les pions filent jusqu\'au bout dans la direction choisie (Dame)\n\n• Aucune pièce ne peut sauter par-dessus une autre\n\n• 8 directions sur plateau carré, 6 sur plateau hexagonal';

  @override
  String get rulesPiecesTitle => 'Les pièces';

  @override
  String get nexus => 'Nexus';

  @override
  String get rulesNexusMove => 'Se déplace comme le Roi aux échecs';

  @override
  String get rulesPiecesP1 => 'Pions Joueur 1';

  @override
  String get rulesPiecesP2 => 'Pions Joueur 2';

  @override
  String get rulesPawnMove => 'Se déplacent comme la Dame aux échecs';

  @override
  String get you => 'Vous';

  @override
  String get computer => 'Ordinateur';

  @override
  String get player1 => 'Joueur 1';

  @override
  String get player2 => 'Joueur 2';

  @override
  String get moveNexusAction => 'Déplacez le Nexus';

  @override
  String get movePawnAction => 'Déplacez un pion';

  @override
  String get wins => 'Gagne !';

  @override
  String get thinking => 'Reflechit...';

  @override
  String get opponent => 'Adversaire';

  @override
  String get connectionLost => 'Connexion perdue';

  @override
  String get back => 'Retour';

  @override
  String get leaveGameTitle => 'Quitter la partie ?';

  @override
  String get leaveGameContent => 'Vous allez abandonner la partie en cours.';

  @override
  String get cancel => 'Annuler';

  @override
  String get leave => 'Quitter';

  @override
  String get yourTurn => 'Votre tour';

  @override
  String get waiting => 'En attente...';

  @override
  String get loading => 'Chargement';

  @override
  String multiplayerCodeLabel(String code) {
    return 'Code : $code';
  }

  @override
  String get youPlayBlue => 'Vous jouez les Bleus';

  @override
  String get youPlayRed => 'Vous jouez les Rouges';

  @override
  String get enterCodeError => 'Entrez un code';

  @override
  String get join => 'Rejoindre';

  @override
  String get gameCodeLabel => 'Code de la partie';

  @override
  String get copy => 'Copier';

  @override
  String get share => 'Partager';

  @override
  String get enterCode => 'Entrez le code';

  @override
  String get configuration => 'Configuration';

  @override
  String get boardLabel => 'Plateau';

  @override
  String get victoryLabel => 'Victoire';

  @override
  String get startsLabel => 'Commence';

  @override
  String get colorBlue => 'Bleu';

  @override
  String get colorRed => 'Rouge';

  @override
  String get players => 'Joueurs';

  @override
  String get youHost => 'Vous (host)';

  @override
  String get host => 'Host';

  @override
  String get startGameButton => 'Lancer la partie';

  @override
  String get waitingOpponent => 'En attente d\'un adversaire...';

  @override
  String get waitingHostStart => 'En attente du lancement par le host...';

  @override
  String shareMessage(String link) {
    return 'Rejoins ma partie Kaptis!\n$link';
  }

  @override
  String get customizeNexus => 'Personnaliser le Nexus';

  @override
  String get color => 'Couleur';

  @override
  String get shape => 'Forme';

  @override
  String get skinCoreTitle => 'Noyau';

  @override
  String get skinCoreSubtitle => 'Noyau energetique';

  @override
  String get skinDiamondTitle => 'Diamant';

  @override
  String get skinDiamondSubtitle => 'Forme diamant';

  @override
  String get skinCrystalTitle => 'Cristal';

  @override
  String get skinCrystalSubtitle => 'Gemme hexagonale';

  @override
  String get skinOrbTitle => 'Orbe';

  @override
  String get skinOrbSubtitle => 'Sphere pulsante';

  @override
  String get skinVortexTitle => 'Vortex';

  @override
  String get skinVortexSubtitle => 'Spirale rotative';

  @override
  String get skinStarTitle => 'Etoile';

  @override
  String get skinStarSubtitle => 'Etoile brillante';

  @override
  String get skinSunTitle => 'Soleil';

  @override
  String get skinSunSubtitle => 'Soleil rayonnant';

  @override
  String get replay => 'Rejouer';

  @override
  String get menu => 'Menu';

  @override
  String get errorRoomNotFound => 'Partie introuvable';

  @override
  String get errorRoomFull => 'La partie est complète';

  @override
  String get errorAlreadyStarted => 'La partie a déjà commencé';
}
