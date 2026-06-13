// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get homeSubtitle => 'Juego de estrategia para 2 jugadores';

  @override
  String get homeTagline => '¡Captura, Bloquea, Domina... el Nexus!';

  @override
  String get homePlayLocal => 'JUGAR LOCAL';

  @override
  String get homePlayOnline => 'JUGAR EN LÍNEA';

  @override
  String get multiplayer => 'Multijugador';

  @override
  String get createGame => 'Crear una partida';

  @override
  String get joinGame => 'Unirse a una partida';

  @override
  String get homeRulesButton => 'REGLAS';

  @override
  String get homeNexusButton => 'NEXUS';

  @override
  String get newGame => 'Nueva partida';

  @override
  String get gameModeSection => 'Modo de juego';

  @override
  String get difficulty => 'Dificultad';

  @override
  String get winConditionSection => 'Condición de victoria';

  @override
  String get startsFirst => 'Empieza primero';

  @override
  String get boardType => 'Tipo de tablero';

  @override
  String get boardSizeSection => 'Tamaño del tablero';

  @override
  String get vsAI => 'vs IA';

  @override
  String get vsAISubtitle => 'Jugar contra Blob';

  @override
  String get twoPlayers => '2 Jugadores';

  @override
  String get twoPlayersSubtitle => 'Jugar con un amigo';

  @override
  String get boardSquare => 'Cuadrado';

  @override
  String get boardSquareSubtitle => '5x5 o 7x7 casillas';

  @override
  String get hexagonal => 'Hexagonal';

  @override
  String get boardHexSubtitle => '37 hexágonos';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyNormal => 'Avanzado';

  @override
  String get difficultyHard => 'Experto';

  @override
  String get boardSize5Desc => '5 peones por jugador\nPartidas rápidas';

  @override
  String get boardSize7Desc => '7 peones por jugador\nPartidas largas';

  @override
  String get winOwnCamp => 'Su campo';

  @override
  String get winOwnCampSubtitle => 'Llevar el Nexus a su campo';

  @override
  String get winOpponentCamp => 'Campo rival';

  @override
  String get winOpponentCampSubtitle => 'Llevar el Nexus al campo rival';

  @override
  String get teamBlue => 'Azules';

  @override
  String get teamRed => 'Rojos';

  @override
  String get player1Starts => 'Empieza el Jugador 1';

  @override
  String get player2Starts => 'Empieza el Jugador 2';

  @override
  String get start => 'EMPEZAR';

  @override
  String get rulesTitle => 'Reglas del juego';

  @override
  String get rulesBoardTitle => 'El tablero';

  @override
  String get rulesBoardContent =>
      'El juego se juega en un tablero cuadrado (5x5 o 7x7 casillas) o hexagonal. Cada jugador tiene 5 o 7 peones colocados en su fila de salida. El Nexus se coloca en el centro del tablero.';

  @override
  String get rulesObjectiveTitle => 'Objetivo';

  @override
  String get rulesObjectiveContent =>
      'Un jugador gana la partida si logra:\n\n1. Llevar el Nexus a la fila de su color\n\n2. Inmovilizar el Nexus mediante un cerco estratégico (inspirado en el Go)';

  @override
  String get rulesTurnTitle => 'Desarrollo de un turno';

  @override
  String get rulesTurnContent =>
      'En su turno, un jugador realiza 2 acciones en este orden:\n\n1. Mover el Nexus una sola casilla (como el Rey en ajedrez)\n\n2. Mover uno de sus peones hasta el final de la línea (como la Dama en ajedrez)';

  @override
  String get rulesImportantTitle => 'Reglas importantes';

  @override
  String get rulesImportantContent =>
      '• El Nexus se mueve una casilla en cualquier dirección (Rey)\n\n• Los peones se deslizan hasta el final en la dirección elegida (Dama)\n\n• Ninguna pieza puede saltar por encima de otra\n\n• 8 direcciones en tablero cuadrado, 6 en tablero hexagonal';

  @override
  String get rulesPiecesTitle => 'Las piezas';

  @override
  String get nexus => 'Nexus';

  @override
  String get rulesNexusMove => 'Se mueve como el Rey en ajedrez';

  @override
  String get rulesPiecesP1 => 'Peones del Jugador 1';

  @override
  String get rulesPiecesP2 => 'Peones del Jugador 2';

  @override
  String get rulesPawnMove => 'Se mueven como la Dama en ajedrez';

  @override
  String get you => 'Tú';

  @override
  String get computer => 'Ordenador';

  @override
  String get player1 => 'Jugador 1';

  @override
  String get player2 => 'Jugador 2';

  @override
  String get moveNexusAction => 'Mueve el Nexus';

  @override
  String get movePawnAction => 'Mueve un peón';

  @override
  String get wins => '¡Gana!';

  @override
  String get thinking => 'Pensando...';

  @override
  String get opponent => 'Rival';

  @override
  String get connectionLost => 'Conexión perdida';

  @override
  String get back => 'Volver';

  @override
  String get leaveGameTitle => '¿Salir de la partida?';

  @override
  String get leaveGameContent => 'Vas a abandonar la partida en curso.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get leave => 'Salir';

  @override
  String get yourTurn => 'Tu turno';

  @override
  String get waiting => 'Esperando...';

  @override
  String get loading => 'Cargando';

  @override
  String multiplayerCodeLabel(String code) {
    return 'Código: $code';
  }

  @override
  String get youPlayBlue => 'Juegas con los Azules';

  @override
  String get youPlayRed => 'Juegas con los Rojos';

  @override
  String get enterCodeError => 'Introduce un código';

  @override
  String get join => 'Unirse';

  @override
  String get gameCodeLabel => 'Código de la partida';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartir';

  @override
  String get enterCode => 'Introduce el código';

  @override
  String get configuration => 'Configuración';

  @override
  String get boardLabel => 'Tablero';

  @override
  String get victoryLabel => 'Victoria';

  @override
  String get startsLabel => 'Empieza';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorRed => 'Rojo';

  @override
  String get players => 'Jugadores';

  @override
  String get youHost => 'Tú (anfitrión)';

  @override
  String get host => 'Anfitrión';

  @override
  String get startGameButton => 'Iniciar la partida';

  @override
  String get waitingOpponent => 'Esperando a un rival...';

  @override
  String get waitingHostStart => 'Esperando a que el anfitrión inicie...';

  @override
  String shareMessage(String link) {
    return '¡Únete a mi partida de Kaptis!\n$link';
  }

  @override
  String get customizeNexus => 'Personalizar el Nexus';

  @override
  String get color => 'Color';

  @override
  String get shape => 'Forma';

  @override
  String get skinCoreTitle => 'Núcleo';

  @override
  String get skinCoreSubtitle => 'Núcleo energético';

  @override
  String get skinDiamondTitle => 'Diamante';

  @override
  String get skinDiamondSubtitle => 'Forma de diamante';

  @override
  String get skinCrystalTitle => 'Cristal';

  @override
  String get skinCrystalSubtitle => 'Gema hexagonal';

  @override
  String get skinOrbTitle => 'Orbe';

  @override
  String get skinOrbSubtitle => 'Esfera pulsante';

  @override
  String get skinVortexTitle => 'Vórtice';

  @override
  String get skinVortexSubtitle => 'Espiral giratoria';

  @override
  String get skinStarTitle => 'Estrella';

  @override
  String get skinStarSubtitle => 'Estrella brillante';

  @override
  String get skinSunTitle => 'Sol';

  @override
  String get skinSunSubtitle => 'Sol radiante';

  @override
  String get replay => 'Jugar de nuevo';

  @override
  String get menu => 'Menú';

  @override
  String get errorRoomNotFound => 'Partida no encontrada';

  @override
  String get errorRoomFull => 'La partida está completa';

  @override
  String get errorAlreadyStarted => 'La partida ya ha comenzado';

  @override
  String get soundOn => 'Sonido activado';

  @override
  String get soundOff => 'Sonido desactivado';
}
