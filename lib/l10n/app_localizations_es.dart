// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcomeTo => 'Bienvenido a';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get termsAndPrivacy => 'Al continuar, aceptas nuestros Términos de servicio y Política de privacidad';

  @override
  String get language => 'Idioma';

  @override
  String get skip => 'Saltar';

  @override
  String get next => 'Siguiente';

  @override
  String get prev => 'Anterior';

  @override
  String get takePicture => 'Tomar una foto';

  @override
  String get readGuide => 'Leer guía';

  @override
  String stepXofY(Object current, Object total) {
    return 'Paso $current de $total';
  }

  @override
  String percentComplete(Object percent) {
    return '$percent%';
  }

  @override
  String get onboardingCoverSubtitle => 'La aplicación de análisis de moho con IA para una identificación rápida y confiable.';

  @override
  String get scanMold => 'Escanear el moho';

  @override
  String get scanMoldDescription => 'Captura fácilmente una foto del moho en tu entorno. Nuestra aplicación te guía en un proceso rápido y sencillo de escaneo para comenzar el análisis.';

  @override
  String get aiAnalysis => 'Análisis con IA';

  @override
  String get aiAnalysisDescription => 'Aprovecha el poder de la inteligencia artificial avanzada. Tu muestra de moho es analizada con algoritmos de última generación que ofrecen información detallada, garantizando resultados precisos y confiables.';

  @override
  String get fastResults => 'Resultados rápidos y detallados';

  @override
  String get fastResultsDescription => 'Recibe resultados detallados y de alta precisión en segundos. Nuestro sistema proporciona informes claros y prácticos diseñados para ayudarte a comprender y gestionar los problemas de moho de manera eficaz.';

  @override
  String get getStartedTitle => 'Comenzar';

  @override
  String get getStartedDescription => 'Lee nuestra guía de buenas prácticas o empieza directamente a proteger tu entorno con un solo toque.';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get auto => 'Automático';

  @override
  String get system => 'Sistema';

  @override
  String get changeTheme => 'Cambiar tema';

  @override
  String get completeVerificationToContinue => 'Completa la verificación para continuar';

  @override
  String get noSignedInUser => 'No se encontró ningún usuario conectado. Por favor, inicia sesión primero.';

  @override
  String get googleAccountLinkedSuccess => 'Cuenta de Google vinculada correctamente.';

  @override
  String get providerAlreadyLinked => 'Esta cuenta ya tiene Google vinculado.';

  @override
  String get credentialAlreadyInUse => 'Esa cuenta de Google ya está siendo utilizada por otra cuenta.';

  @override
  String get googleEmailAlreadyInUse => 'El correo de Google ya está asociado a otra cuenta.';

  @override
  String get failedToLinkGoogleAccount => 'Error al vincular la cuenta de Google.';

  @override
  String get linking => 'Vinculando...';

  @override
  String get emailMismatch => 'Email mismatch';

  @override
  String get currentAccount => 'Cuenta actual';

  @override
  String get tryAgain => 'Intenta de nuevo';

  @override
  String get networkError => 'Error de red. Verifica tu conexión.';

  @override
  String get requestTimedOut => 'Tiempo de espera agotado. Compruebe su conexión.';

  @override
  String get kitNotFound => 'Kit no encontrado o código inválido.';

  @override
  String get invalidQr => 'Código QR inválido (posible manipulación).';

  @override
  String get kitAlreadyReserved => 'El kit ya está reservado por otro dispositivo.';

  @override
  String get kitAlreadyUsed => 'El kit ya fue usado o la sesión expiró.';

  @override
  String get signupFailed => 'Error al completar el registro.';

  @override
  String get linkFailed => 'Error al vincular';

  @override
  String get serverError => 'Error del servidor. Inténtelo de nuevo.';

  @override
  String get serverErrorShort => 'Error del servidor';

  @override
  String get unexpectedError => 'Error inesperado. Inténtelo de nuevo.';

  @override
  String get theEmailAddress => 'La dirección de correo electrónico:';

  @override
  String get accountAlreadyRegistered => 'ya está registrada. Por favor, inicia sesión con esta cuenta o elige una cuenta de Google diferente.';

  @override
  String get chooseDifferentAccount => 'Elegir Cuenta Diferente';

  @override
  String get linkingCancelled => 'Vinculación cancelada';

  @override
  String get welcomeBack => 'Bienvenido  ';

  @override
  String get signInToAccount => 'Inicia sesión en tu cuenta';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get enterYourEmail => 'Introduce tu correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu Contraseña?';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta? ';

  @override
  String get signUp => 'Regístrate';

  @override
  String get pleaseEnterEmail => 'Por favor introduce tu correo electrónico';

  @override
  String get pleaseEnterValidEmail => 'Por favor introduce un correo electrónico válido';

  @override
  String get pleaseEnterPassword => 'Por favor introduce una contraseña';

  @override
  String get signInFailed => 'Error al iniciar sesión. Por favor, inténtalo de nuevo.';

  @override
  String get or => 'O';

  @override
  String get invalidCredentials => 'Correo electrónico o contraseña no válidos. Por favor, inténtalo de nuevo.';

  @override
  String get noUserFound => 'No se encontró ningún usuario con esta dirección de correo electrónico.';

  @override
  String get incorrectPassword => 'Contraseña incorrecta.';

  @override
  String get invalidEmailAddress => 'Dirección de correo electrónico no válida.';

  @override
  String get accountDisabled => 'Esta cuenta ha sido deshabilitada.';

  @override
  String get tooManyFailedAttempts => 'Demasiados intentos fallidos. Inténtalo más tarde.';

  @override
  String get googleSignInNotPermitted => 'El inicio de sesión con Google no está permitido para esta cuenta.';

  @override
  String get googleSignInServerError => 'Error del servidor al verificar el inicio de sesión. Por favor, inténtalo más tarde.';

  @override
  String passwordTooShort(Object min) {
    return 'La contraseña debe tener al menos $min caracteres';
  }

  @override
  String get passwordRequiresUpper => 'La contraseña debe contener una letra mayúscula';

  @override
  String get passwordRequiresLower => 'La contraseña debe contener una letra minúscula';

  @override
  String get passwordRequiresDigit => 'La contraseña debe contener un número';

  @override
  String get passwordRequiresSpecial => 'La contraseña debe contener un carácter especial';

  @override
  String get googleSignInFailed => 'Error al iniciar sesión con Google. Por favor, inténtalo de nuevo.';

  @override
  String get verificationEmailResent => 'Correo electrónico de verificación reenviado a';

  @override
  String get failedToResendEmail => 'Error al reenviar el correo electrónico';

  @override
  String get failedToGetEmailFromGoogle => 'Error al obtener el correo electrónico de Google';

  @override
  String get emailChangePendingVerification => 'Cambio de correo electrónico pendiente de verificación';

  @override
  String get yourEmailChangeTo => 'Tu cambio de correo electrónico a:';

  @override
  String get isStillPendingVerification => 'está pendiente de verificación. Por favor, revisa tu bandeja de entrada y haz clic en el enlace de verificación.';

  @override
  String pendingEmailVerification(Object email) {
    return 'Verificación de correo electrónico pendiente para $email';
  }

  @override
  String get accountmismatchError => 'Account mismatch detected. Please contact support.';

  @override
  String get createAnAccount => 'Crea una cuenta';

  @override
  String get joinUsToStartYourJourney => 'Únete a nosotros para comenzar tu camino';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get pleaseConfirmPassword => 'Por favor confirma tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordMinLength => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get iAgreeToThe => 'Acepto los ';

  @override
  String get termsAndConditions => 'Términos y Condiciones';

  @override
  String get pleaseAcceptTerms => 'Por favor acepta los Términos y Condiciones';

  @override
  String get accountCreatedSuccessfully => '¡Cuenta creada con éxito!';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String emailAlreadyRegistered(Object email) {
    return 'El correo electrónico $email ya está registrado. Por favor, inicia sesión con tu cuenta existente o utiliza una cuenta de Google diferente.';
  }

  @override
  String get googleAuthNoIdToken => 'La autenticación de Google falló. Por favor, inténtalo de nuevo.';

  @override
  String get googleSignUpFailed => 'Error al registrarse con Google. Por favor, inténtalo de nuevo.';

  @override
  String get signUpFailed => 'Error al registrarse. Por favor, inténtalo de nuevo.';

  @override
  String get googleSignInNotLinked => 'Este correo electrónico está registrado con una contraseña. Por favor, inicia sesión con correo electrónico y contraseña, o crea una nueva cuenta.';

  @override
  String get termsAndConditionsLong => 'Bienvenido a Tesia.\n\nEstos Términos y Condiciones rigen el uso de la aplicación móvil Tesia y los servicios relacionados. Al crear una cuenta y usar la aplicación, aceptas cumplir estos términos.\n\nElegibilidad\nDebes tener al menos 13 años para registrarte y usar el servicio.\n\nResponsabilidades del usuario\nEres responsable de mantener la confidencialidad de tus credenciales y de toda actividad que ocurra bajo tu cuenta. No uses la aplicación con fines ilegales, intentes ingeniería inversa sobre el servicio ni subas contenido que infrinja derechos de terceros.\n\nCambios en el servicio y acceso\nTesia puede suspender, modificar o terminar el acceso a funcionalidades en cualquier momento.\n\nDatos y privacidad\nRecopilamos y procesamos ciertos datos personales según se describe en nuestra Política de Privacidad. Al usar la aplicación consientes dicha recopilación y tratamiento.\n\nRenuncia y limitación de responsabilidad\nTodo el contenido se ofrece \"tal cual\" sin garantías. En la máxima medida permitida por la ley, Tesia excluye garantías y no será responsable por daños indirectos, incidentales, especiales o consecuentes.\n\nTerminación de cuenta y conservación de datos\nPuedes cerrar tu cuenta en cualquier momento. Tras la terminación, ciertos datos pueden conservarse por motivos legales o comerciales legítimos.\n\nCambios en estos términos\nPodemos actualizar estos términos ocasionalmente. Cuando sea necesario publicaremos los cambios y, si procede, solicitaremos tu consentimiento.\n\nPreguntas\nSi tienes dudas o necesitas ayuda, contacta con support@tesia.com.\n\nAl pulsar \"Aceptar\" confirmas que has leído, entendido y aceptas estos Términos y Condiciones.';

  @override
  String get userDisabled => 'La cuenta de usuario está deshabilitada.';

  @override
  String get forgotPasswordSubtitle => 'Ingresa tu dirección de correo y te enviaremos un enlace para restablecer tu contraseña';

  @override
  String get sendResetLink => 'Enviar Enlace de Restablecimiento';

  @override
  String get resetLinkSent => '¡Enlace de restablecimiento enviado exitosamente!';

  @override
  String get emailSent => '¡Correo Enviado!';

  @override
  String get checkYourEmail => 'Hemos enviado un enlace de restablecimiento de contraseña a:';

  @override
  String get resetInstructions => 'Haz clic en el enlace de tu correo para restablecer tu contraseña. El enlace expirará en 24 horas.';

  @override
  String get resendEmail => ' Reenviar';

  @override
  String get backToSignIn => 'Volver al Inicio de Sesión';

  @override
  String get resetFailed => 'Error al enviar el enlace de restablecimiento. Por favor, inténtalo de nuevo.';

  @override
  String tryAgainInSeconds(Object seconds) {
    return 'Por favor espera $seconds segundos antes de volver a intentar.';
  }

  @override
  String get tooManyRequests => 'Demasiados intentos — intenta de nuevo más tarde.';

  @override
  String get guideTitle => 'Guía de Moho TESIA';

  @override
  String get guideDescription => 'Guía completa para la detección y eliminación de moho';

  @override
  String get export => 'Exportar';

  @override
  String get previous => 'Anterior';

  @override
  String pageXofY(Object current, Object total) {
    return 'Página $current de $total';
  }

  @override
  String get account => 'Cuenta';

  @override
  String get advancedAiAnalysis => 'Análisis avanzado de IA';

  @override
  String percentCompleted(Object percent) {
    return '$percent% completado';
  }

  @override
  String get unknown => 'Desconocido';

  @override
  String scansCompleted(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get yourLatestScans => 'Tus últimos escaneos';

  @override
  String get seeMore => 'Ver más';

  @override
  String get aspergillus => 'Aspergillus';

  @override
  String get canCauseAllergies => 'Puede causar alergias';

  @override
  String get cladosporium => 'Cladosporium';

  @override
  String get commonIndoorMold => 'Moho común en interiores';

  @override
  String get alternaria => 'Alternaria';

  @override
  String get respiratoryIssues => 'Problemas respiratorios';

  @override
  String get stachybotrys => 'Stachybotrys';

  @override
  String get severeHealthEffects => 'Efectos graves para la salud';

  @override
  String get noRecentScans => 'No hay exploraciones recientes';

  @override
  String get getStartedByScanningMold => 'Comienza escaneando el moho en tu hogar';

  @override
  String get fullname => 'Nombre completo';

  @override
  String get email => 'Correo electrónico';

  @override
  String get freePlan => 'Plan gratuito';

  @override
  String get modifyPassword => 'Modificar contraseña';

  @override
  String get modifyPasswordDescription => 'Para cambiar tu contraseña rellena AMBOS campos abajo.';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get pleaseEnterNewPassword => 'Por favor, introduce una nueva contraseña';

  @override
  String get passwordMustBe6Chars => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get pleaseConfirmYourPassword => 'Por favor, confirma tu contraseña';

  @override
  String get dangerZone => 'Zona de peligro';

  @override
  String get dangerZoneExpanded => 'Eliminar tu cuenta es permanente y no se puede deshacer.';

  @override
  String get dangerZoneCollapsed => 'Toca para ver la opción de eliminar';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirmTitle => '¿Eliminar cuenta?';

  @override
  String get deleteAccountConfirmMessage => 'Esto eliminará permanentemente tu cuenta y todos los datos. ¿Seguro que deseas continuar?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get accountDeleted => 'Cuenta eliminada';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get removePhoto => 'Eliminar foto';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutConfirmMessage => '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get signedOut => 'Sesión cerrada';

  @override
  String get signOutFailed => 'Error al cerrar sesión';

  @override
  String get deleteAccountFailed => 'Error al eliminar la cuenta';

  @override
  String get reauthenticateToDeleteAccount => 'Por favor, vuelve a autenticarte para eliminar tu cuenta.';

  @override
  String get refreshfailed => 'Error al actualizar la autenticación. Cierra sesión y vuelve a iniciar sesión.';

  @override
  String get imageStored => 'Imagen de perfil guardada correctamente.';

  @override
  String get uploadFailed => 'Error al subir la imagen. Por favor, inténtalo de nuevo.';

  @override
  String get removeFailed => 'No se pudo eliminar la imagen de perfil. Por favor, inténtalo de nuevo.';

  @override
  String get failedToPickImage => 'No se pudo seleccionar la imagen. Por favor, inténtalo de nuevo.';

  @override
  String get profilePictureUpdated => 'Imagen de perfil actualizada correctamente.';

  @override
  String get profilePictureRemoved => 'Imagen de perfil eliminada correctamente.';

  @override
  String get verifyIdentity => 'Verificar identidad';

  @override
  String get verifyIdentityContent => '¿Cómo te gustaría verificar tu identidad?';

  @override
  String get google => 'Google';

  @override
  String reenterPasswordFor(Object email) {
    return 'Vuelve a introducir la contraseña para $email';
  }

  @override
  String get passwordRequired => 'Se requiere la contraseña';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get emailChangeGoogleProvider => 'El cambio de correo electrónico no está permitido para cuentas solo de Google.\nPara cambiar tu correo electrónico: actualiza el correo electrónico de tu cuenta de Google o vincula una credencial de correo electrónico/contraseña en la cuenta.';

  @override
  String get emailchangecanceled => 'Cambio de correo electrónico cancelado';

  @override
  String emailChangePending(Object newEmail) {
    return 'Se ha enviado un correo electrónico de verificación a $newEmail.\nTu correo electrónico de cuenta se actualizará después de que confirmes el enlace.';
  }

  @override
  String get updatedfailed => 'Error al actualizar';

  @override
  String verifemailsent(Object email) {
    return 'Correo de verificación enviado a $email. Por favor, revisa tu bandeja de entrada.';
  }

  @override
  String get googlePasswordChangeNotAvailable => 'El cambio de contraseña no está disponible para cuentas vinculadas a Google.\nPara cambiar tu contraseña, utiliza la configuración de tu cuenta de Google.';

  @override
  String get passwordUpdatedSuccessfully => 'Contraseña actualizada con éxito';

  @override
  String get reauthCancelled => 'Re-autenticación cancelada';

  @override
  String get reauthFailed => 'Re-autenticación fallida';

  @override
  String get passwordTooWeak => 'La contraseña es demasiado débil';

  @override
  String get authError => 'Error de autenticación';

  @override
  String get passwordUpdateFailed => 'Error al actualizar la contraseña';

  @override
  String get accountDeletedFallback => 'Cuenta eliminada por defecto';

  @override
  String get recentSignInRequiredDelete => 'Se requiere un inicio de sesión reciente para eliminar la cuenta';

  @override
  String get accountDeletionFailed => 'Error al eliminar la cuenta';

  @override
  String get emailAlreadyInUse => 'El correo electrónico ya está en uso';

  @override
  String get failedToUpdateEmail => 'Error al actualizar el correo electrónico';

  @override
  String get emailVerifiedSuccessfully => 'Correo verificado exitosamente';

  @override
  String get recentSignInRequiredEmail => 'Se requiere un inicio de sesión reciente para actualizar el correo';

  @override
  String get googleAccountNotLinked => 'Cuenta de Google no vinculada';

  @override
  String get recentSignInRequiredLink => 'Se requiere un inicio de sesión reciente para vincular la cuenta';

  @override
  String get checkingPasswordRequirement => 'Verificando requisitos de contraseña...';

  @override
  String get unlinkingGoogleAccount => 'Desvinculando cuenta de Google...';

  @override
  String get googleAccountAlreadyLinkedToYou => 'Cuenta de Google ya vinculada a ti.';

  @override
  String get invalidGoogleCredential => 'Credencial de Google inválida.';

  @override
  String get googleAccountAlreadyLinked => 'Cuenta de Google ya vinculada.';

  @override
  String get unlinkingAccount => 'Desvinculando cuenta...';

  @override
  String get linkingAccount => 'Vinculando cuenta...';

  @override
  String get accountNotFound => 'Cuenta no encontrada.';

  @override
  String get resend => 'Reenviar';

  @override
  String verificationEmailSent(Object email) {
    return 'Correo de verificación enviado a $email. Por favor, revisa tu bandeja de entrada.';
  }

  @override
  String get emailChangeTimedOut => 'El cambio de correo electrónico ha caducado. Por favor, inténtalo de nuevo.';

  @override
  String get waitingForEmailVerification => 'Esperando la verificación del correo electrónico... Revisa tu bandeja de entrada.';

  @override
  String get verifyBeforeUpdateEmailTitle => 'Verifica electrónico';

  @override
  String get emailVerificationStepsTitle => 'Próximos pasos:';

  @override
  String get checkYourInbox => 'Revisa tu bandeja de entrada';

  @override
  String get clickTheVerificationLink => 'Haz clic en el enlace de verificación';

  @override
  String get signInAgainWithNewEmail => 'Inicia sesión nuevamente con tu nuevo correo electrónico';

  @override
  String get understood => 'Entendido';

  @override
  String get latestScans => 'Escaneos recientes';

  @override
  String get highRisk => 'Alto riesgo';

  @override
  String get mediumRisk => 'Medio';

  @override
  String get lowRisk => 'Bajo riesgo';

  @override
  String get scanHistory => 'Historial de escaneos';

  @override
  String get searchByMoldOrNotes => 'Buscar por moho ';

  @override
  String get all => 'Todos';

  @override
  String get noScansYet => 'Aún no hay escaneos';

  @override
  String get noScansDescription => 'Intenta escanear una muestra o cambia los filtros. Tus escaneos recientes aparecerán aquí.';

  @override
  String get danger => 'Peligro';

  @override
  String get low => 'Bajo';

  @override
  String get medium => 'Medio';

  @override
  String get high => 'Alto';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String daysAgo(Object days) {
    return 'Hace $days días';
  }

  @override
  String get aspergillusDescription => 'Moho común en interiores, encontrado en baños';

  @override
  String get penicilliumDescription => 'Moho azul-verde, típicamente encontrado en áreas con daños por agua';

  @override
  String get stachybotryDescription => 'Moho negro - altamente tóxico y peligroso';

  @override
  String get cladosporiumDescription => 'Moho verde oscuro, comúnmente encontrado al aire libre';

  @override
  String get alternariaDescription => 'Moho marrón que provoca reacciones alérgicas';

  @override
  String get filterBy => 'Filtrar por';

  @override
  String get moldType => 'Tipo de moho';

  @override
  String get dangerLevel => 'Nivel de peligro';

  @override
  String get certainty => 'Certeza';

  @override
  String get any => 'Cualquiera';

  @override
  String get moldScanner => 'Escáner de moho';

  @override
  String get scansLeft => 'Escaneos restantes';

  @override
  String get readyToScan => 'Listo para escanear';

  @override
  String get getInstantMoldIdentification => 'Obtén resultados de identificación de moho al instante';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get photoGuidelines => 'Guía para fotos';

  @override
  String get goodLighting => 'Buena iluminación';

  @override
  String get goodLightingDescription => 'Usa luz natural o iluminación interior brillante';

  @override
  String get optimalDistance => 'Distancia óptima';

  @override
  String get optimalDistanceDescription => 'Mantén 20-30 cm de distancia de la muestra';

  @override
  String get staySteady => 'Mantente estable';

  @override
  String get staySteadyDescription => 'Sostén quieto para una imagen clara y enfocada';

  @override
  String get aiPoweredAnalysis => 'El análisis impulsado por IA proporciona identificación instantánea con puntuaciones de confianza';

  @override
  String get planLimitReached => 'Límite del plan alcanzado';

  @override
  String get planLimitReachedMessage => 'Has alcanzado el límite de escaneos de este plan. Actualiza para continuar escaneando.';

  @override
  String get ok => 'OK';

  @override
  String get analyzingImage => 'Analizando imagen';

  @override
  String get processingWithAI => 'Procesando con detección de IA...';

  @override
  String get scansRemaining => 'escaneos restantes';

  @override
  String failedToProcessImage(Object error) {
    return 'No se pudo procesar la imagen: $error';
  }

  @override
  String get scanQrCode => 'Escanear código QR';

  @override
  String get positionTheQrWithinFrame => 'Coloca el código QR dentro del marco para escanear';

  @override
  String get pleaseSignIn => 'Por favor, inicia sesión para usar el escáner';

  @override
  String get authenticationExpired => 'La autenticación ha expirado. Por favor, inicia sesión nuevamente.';

  @override
  String get apiKeyNotConfigured => 'Servicio de IA no configurado en el servidor. Por favor, contacta con soporte.';

  @override
  String get failedToAnalyzeImage => 'No se pudo analizar la imagen. Inténtalo de nuevo más tarde.';

  @override
  String get scanResults => 'Resultados del escaneo';

  @override
  String get viewOnWeb => 'Ver en la web';

  @override
  String get typeOfMold => 'Tipo de moho';

  @override
  String get healthRisks => 'Riesgos para la salud';

  @override
  String get prevention => 'Prevención';

  @override
  String get detectionStatistics => 'Estadísticas de detección';

  @override
  String get users => 'usuarios';

  @override
  String get detectionAccuracy => 'Precisión de la detección';

  @override
  String get commonInHomes => 'Común en hogares';

  @override
  String get severityLevel => 'Nivel de gravedad';

  @override
  String get quickFactsAboutMold => 'Datos rápidos sobre este tipo de moho. Usa las pestañas para cambiar de contexto.';

  @override
  String get overview => 'Resumen';

  @override
  String get habitat => 'Hábitat';

  @override
  String get images => 'Imágenes';

  @override
  String get sampleImageCaptured => 'Imagen de muestra capturada para este escaneo.';

  @override
  String get whatExposureCanCause => 'Qué puede causar la exposición';

  @override
  String get copyHealthRisks => 'Copiar riesgos para la salud';

  @override
  String get learnMore => 'Aprender más';

  @override
  String get goToPrevention => 'Ir a Prevención';

  @override
  String get close => 'Cerrar';

  @override
  String get preventionMethods => 'Métodos de prevención';

  @override
  String get copyPrevention => 'Copiar prevención';

  @override
  String get practicalStepsToReduce => 'Pasos prácticos para reducir la exposición y prevenir el crecimiento.';

  @override
  String get downloadFullReportPDF => 'Descargar informe completo (PDF)';

  @override
  String get home => 'Inicio';

  @override
  String get history => 'Historial';

  @override
  String get notifications => 'Notificaciones';

  @override
  String copiedToClipboard(Object label) {
    return '$label copiado al portapapeles';
  }

  @override
  String get pdfExported => 'PDF exportado';

  @override
  String errorExportingPDF(Object error) {
    return 'Error al exportar PDF: $error';
  }

  @override
  String get couldNotOpenWebLink => 'No se pudo abrir el enlace web';

  @override
  String get pdfScanReportTitle => 'Informe de Escaneo de Moho';

  @override
  String get pdfDescription => 'Descripción';

  @override
  String get pdfOverview => 'Resumen';

  @override
  String get pdfHabitat => 'Hábitat';

  @override
  String get pdfDetectionStatistics => 'Estadísticas de Detección';

  @override
  String get pdfHealthRisks => 'Riesgos para la Salud';

  @override
  String get pdfPreventionMethods => 'Métodos de Prevención';

  @override
  String get pdfNoneListed => 'No hay elementos';

  @override
  String get pdfGenerated => 'Generado';

  @override
  String get couldNotCopy => 'No se pudo copiar el texto';

  @override
  String get shareSummary => 'Compartir resumen';

  @override
  String get shareSummaryDescription => 'Comparte un resumen rápido de los resultados de tu escaneo de moho con otros.';

  @override
  String unreadNotifications(Object count) {
    return '$count sin leer';
  }

  @override
  String get markAllAsRead => 'Marcar todo como leído';

  @override
  String get noNotificationsYet => 'Aún no hay notificaciones';

  @override
  String get notificationsDescription => 'Te notificaremos cuando llegue algo nuevo';

  @override
  String get notificationDeleted => 'Notificación eliminada';

  @override
  String get scanComplete => 'Escaneo completado';

  @override
  String scanCompleteMessage(Object moldType) {
    return 'Tu escaneo de $moldType ha sido analizado exitosamente';
  }

  @override
  String get highRiskDetected => 'Riesgo alto detectado';

  @override
  String highRiskDetectedMessage(Object moldType) {
    return '$moldType detectado con nivel de gravedad alto. Toma acción inmediata.';
  }

  @override
  String get scanLimitWarning => 'Advertencia de límite de escaneos';

  @override
  String scanLimitWarningMessage(Object remaining) {
    return 'Te quedan $remaining escaneos en tu plan';
  }

  @override
  String get newFeatureAvailable => 'Nueva función disponible';

  @override
  String get newFeatureAvailableMessage => 'Descubre nuestra nueva función de recomendaciones impulsada por IA';

  @override
  String get justNow => 'Justo ahora';

  @override
  String minutesAgo(Object minutes) {
    return 'hace $minutes min';
  }

  @override
  String hoursAgo(Object hours) {
    return 'hace $hours h';
  }

  @override
  String get deleteAll => 'Eliminar todo';

  @override
  String get deleteAllNotifications => 'Eliminar todas las notificaciones';

  @override
  String get deleteAllNotificationsConfirm => '¿Estás seguro de que deseas eliminar todas las notificaciones? Esta acción no se puede deshacer.';

  @override
  String get allNotificationsDeleted => 'Todas las notificaciones eliminadas';

  @override
  String get allMarkedAsRead => 'Todas las notificaciones marcadas como leídas';

  @override
  String get pleaseSignInToViewNotifications => 'Por favor, inicia sesión para ver las notificaciones';

  @override
  String get errorLoadingNotifications => 'Error al cargar las notificaciones';

  @override
  String scanResultTitle(Object moldType) {
    return 'Resultado del escaneo: $moldType';
  }

  @override
  String scanResultMessageMedium(Object moldType, Object scansLeft) {
    return '$moldType detectado (severidad media). Restan $scansLeft escaneos.';
  }

  @override
  String scanResultMessage(Object moldType, Object scansLeft) {
    return '$moldType detectado. Restan $scansLeft escaneos.';
  }

  @override
  String scanResultMessageHigh(Object moldType, Object scansLeft) {
    return 'Se detectó alta severidad para $moldType. Actúe rápido. Restan $scansLeft escaneos.';
  }

  @override
  String get checkingSession => 'Comprobando tu sesión...';

  @override
  String get kitCodePlaceholder => 'TS-XXXX-XXXX-XXXX';

  @override
  String get sessionRestored => 'Sesión restaurada';

  @override
  String get kitVerifiedSuccessfully => 'Kit verificado correctamente';

  @override
  String get noSessionToken => 'No hay token de sesión. Escanea o introduce el código del kit.';

  @override
  String get verifyingQr => 'Verificando el código QR...';

  @override
  String get verifyingCode => 'Verificando el código...';

  @override
  String get codeVerified => 'Código verificado';

  @override
  String get invalidCodeFormat => 'El código debe tener el formato: TS-XXXX-XXXX-XXXX';

  @override
  String get genericError => 'Algo salió mal. Por favor, inténtalo de nuevo.';

  @override
  String get scanOrEnterCode => 'Escanea el código QR de tu kit o introduce el código manualmente para registrarte.';

  @override
  String get kitVerification => 'Verificación del kit';

  @override
  String get enterCodeHint => 'Introduce tu código del kit a continuación';

  @override
  String get scanQr => 'Escanear QR';

  @override
  String get enterCode => 'Introducir código manualmente';

  @override
  String get verify => 'Verificar';

  @override
  String get verifiedPrompt => 'Dispositivo verificado. Puedes continuar con el registro.';

  @override
  String get proceedToSignup => 'Continuar con el registro';

  @override
  String get welcomeToTesia => '¡Bienvenido a Tesia!';

  @override
  String get getStartedMessage => 'Completa tu perfil o vincula tu cuenta de Google para aprovechar al máximo tu experiencia de detección de moho.';

  @override
  String get completeProfile => 'Completar perfil';

  @override
  String get linkGoogleAccount => 'Vincular cuenta de Google';

  @override
  String get ignoreForNow => 'Ignorar por ahora';

  @override
  String get googleAccountLinked => '¡Cuenta de Google vinculada con éxito!';

  @override
  String linkedWith(Object provider) {
    return 'Vinculado con $provider';
  }

  @override
  String get googleLinked => 'Vinculado con Google';

  @override
  String get welcomeNotificationTitle => '¡Bienvenido a TESIA! 🎉';

  @override
  String get welcomeNotificationMessage => 'Completa tu perfil para aprovechar al máximo tu experiencia';

  @override
  String get privacyAndSecurity => 'Privacidad y seguridad';

  @override
  String get privacySummaryTitle => 'Cómo manejamos tus datos';

  @override
  String get privacySummaryBody => 'Solo recopilamos lo necesario para ofrecer y mejorar TESIA. La información de tu cuenta, los resultados de las pruebas y los identificadores del dispositivo nos ayudan a brindar funciones personalizadas y una sincronización confiable entre dispositivos. Protegemos los datos con seguridad de nivel industrial, no vendemos información personal y ofrecemos opciones para gestionar o eliminar tu información.';

  @override
  String get viewPdf => 'Ver PDF';

  @override
  String get openFullPdf => 'Abrir PDF completo';

  @override
  String get openPdf => 'Abrir PDF';

  @override
  String get settings => 'Configuración';

  @override
  String get profile => 'Perfil';

  @override
  String get theme => 'Tema';

  @override
  String get english => 'Inglés';

  @override
  String get googleAccount => 'Cuenta de Google';

  @override
  String get linked => 'Vinculada';

  @override
  String get syncActive => 'Sincronización activa';

  @override
  String get syncYourDataWithGoogle => 'Sincroniza tus datos con Google';

  @override
  String get security => 'Seguridad';

  @override
  String get app => 'Aplicación';

  @override
  String get helpSupport => 'Ayuda y soporte';

  @override
  String get getHelpAndContactSupport => 'Obtén ayuda y contacta con el soporte';

  @override
  String get about => 'Acerca de';

  @override
  String get appVersionAndInformation => 'Versión e información de la aplicación';

  @override
  String get rateApp => 'Calificar la aplicación';

  @override
  String get rateUsOnTheAppStore => 'Califícanos en la tienda de aplicaciones';

  @override
  String get signOutOfYourAccount => 'Cierra sesión en tu cuenta';

  @override
  String get permanentlyDeleteYourAccount => 'Elimina tu cuenta permanentemente';

  @override
  String get emailSupport => 'Soporte por correo electrónico';

  @override
  String get emailSupportAddress => 'support@tesia.com';

  @override
  String get phoneSupport => 'Soporte telefónico';

  @override
  String get phoneSupportNumber => '+1 (555) 123-4567';

  @override
  String get faq => 'Preguntas frecuentes';

  @override
  String get frequentlyAskedQuestions => 'Preguntas frecuentes';

  @override
  String get enjoyingTesia => '¿Disfrutando de TESIA?';

  @override
  String get rateAppDescription => 'Por favor, tómate un momento para calificarnos en la tienda de aplicaciones. Tus comentarios nos ayudan a mejorar y llegar a más personas que necesitan detección de moho.';

  @override
  String get later => 'Más tarde';

  @override
  String get rateNow => 'Calificar ahora';

  @override
  String get manageYourPrivacySettings => 'Gestionar tu configuración de privacidad';

  @override
  String get keyPoints => 'Puntos clave';

  @override
  String get minimalDataCollection => 'Recopilación mínima de datos: solo lo necesario para operar el servicio.';

  @override
  String get strongEncryption => 'Cifrado fuerte en tránsito (TLS) y reglas de seguridad de Firebase.';

  @override
  String get googleSignInOptional => 'El inicio de sesión con Google es opcional y se utiliza solo para sincronización y copias de seguridad.';

  @override
  String get requestDataDeletion => 'Puedes solicitar la eliminación de tus datos en cualquier momento.';

  @override
  String get moreDetails => 'Más detalles';

  @override
  String get moreDetailsDescription => 'Este resumen destaca las prácticas más importantes de privacidad y seguridad. Para información completa, abre el PDF completo que incluye políticas detalladas e información de contacto.';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get selectTheme => 'Seleccionar tema';

  @override
  String get privacySecurityAndAppInfo => ' Información de la aplicación';

  @override
  String get aboutTesia => 'Acerca de TESIA';

  @override
  String get aboutTesiaDescription => 'TESIA es una aplicación de detección de moho impulsada por IA, diseñada para ayudar a propietarios y profesionales a identificar y analizar rápidamente los riesgos de moho. Nos enfocamos en la precisión, la privacidad y una experiencia de usuario fluida.';

  @override
  String get whatWeOffer => 'Lo que ofrecemos';

  @override
  String get aiMoldDetection => 'Detección de moho en tiempo real con puntuaciones de confianza.';

  @override
  String get detailedReportsAndSync => 'Informes detallados descargables y sincronización en la nube.';

  @override
  String get privacyFirstApproach => 'Privacidad ante todo: recopilación mínima de datos, sin venta de información.';

  @override
  String get multiLanguageSupport => 'Soporte multilingüe y temas personalizables.';

  @override
  String get version => 'Versión';

  @override
  String get support => 'Soporte';

  @override
  String get copyright => '© 2025 TESIA. Todos los derechos reservados.';

  @override
  String get visitWebsite => 'Visitar sitio web';

  @override
  String get signOutConfirmation => '¿Estás seguro de que deseas cerrar sesión? Deberás iniciar sesión nuevamente para acceder a tu cuenta y sincronizar tus datos.';

  @override
  String get deleteAccountConfirmation => '¿Estás seguro de que deseas eliminar permanentemente tu cuenta? Esta acción no se puede deshacer y resultará en:';

  @override
  String get lossOfDetectionHistory => '• Pérdida de todo el historial de detección';

  @override
  String get lossOfSettings => '• Pérdida de configuraciones y preferencias guardadas';

  @override
  String get lossOfCloudSync => '• Pérdida de los datos sincronizados en la nube';

  @override
  String get unableToRecover => '• Imposibilidad de recuperar la cuenta';

  @override
  String get reset => 'Restablecer';

  @override
  String get apply => 'Aplicar';

  @override
  String printFailed(Object error) {
    return 'Error al imprimir: $error';
  }

  @override
  String get couldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get accountLinked => 'Cuenta vinculada';

  @override
  String get googleAccountLinkedDialogDescription => 'Tu cuenta de Google está vinculada con éxito. Ahora puedes sincronizar tus datos de TESIA en todos los dispositivos y habilitar copias de seguridad.';

  @override
  String get connectGoogleAccountDescription => 'Conecta tu cuenta de Google para sincronizar tus datos de TESIA en todos tus dispositivos y habilitar la copia de seguridad automática de tu historial de detección de moho.';

  @override
  String get syncingData => 'Tus datos se están sincronizando';

  @override
  String get linkAccount => 'Vincular cuenta';

  @override
  String get unlinkAccount => 'Desvincular cuenta';

  @override
  String get googleSignInCancelled => 'Inicio de sesión de Google cancelado';

  @override
  String get googleAccountUnlinked => 'Cuenta de Google desvinculada';

  @override
  String get notSignedIn => 'No has iniciado sesión';

  @override
  String errorPrefix(Object error) {
    return 'Error: $error';
  }

  @override
  String get setPassword => 'Establecer contraseña';

  @override
  String get setPasswordExplanation => 'Para desvincular Google, debes establecer una contraseña para esta cuenta para que puedas iniciar sesión después de desvincularla.';

  @override
  String get unlinkRequiresPassword => 'Debes establecer una contraseña antes de desvincular Google.';

  @override
  String get failedToLinkPassword => 'Error al establecer la contraseña. Por favor, inténtalo de nuevo.';

  @override
  String get deletingAccount => 'Eliminando cuenta...';

  @override
  String get pleaseWait => 'Por favor espera, esto puede tardar un momento.';

  @override
  String get failedToDeleteAccount => 'Error al eliminar la cuenta. Por favor, inténtalo de nuevo.';

  @override
  String get failedToLoadPrivacyPolicy => 'Error al cargar la política de privacidad. Por favor, inténtalo de nuevo más tarde.';
}
