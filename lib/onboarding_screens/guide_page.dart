import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tesia_app/l10n/app_localizations.dart';
import 'package:tesia_app/shared/colors.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  int get _totalPages => _guideChaptersEn.length;

  final List<ScrollController> _scrollControllers = [];

  bool _isLoadingFromStorage = false;
  String? _storagePdfError;

  final List<Map<String, String>> _guideChaptersEn = [
    {
      'title': 'Chapter 1 : What is Mold?',
      'content':
          '''Mold is a kind of fungus rather than a plant or an animal. Thousands of mold species are known worldwide. Mold plays a significant role in the natural environment by decomposing organic substances. Nevertheless, mold can also lead to property damage, food deterioration, and produce toxic compounds known as mycotoxins. Mycotoxins are part of the natural defense mechanism of mold, but they may be detrimental to human health. Furthermore, many molds can trigger allergic reactions in sensitive individuals.

Mold propagates by generating minute spores that float in the air or alight on object surfaces and commence growth. Mold spores are imperceptible to the naked eye and are highly prevalent.''',
    },
    {
      'title': 'Chapter 2 : The Conditions for Mold Growth',
      'content':
          '''Mold growth necessitates two elements: a biodegradable organic food source and moisture. Within buildings and houses, there exist numerous food sources for mold, such as wood, paper, and natural fiber materials. Although we typically have no control over the presence of these food sources, we can restrict mold growth by modulating the humidity within the buildings.

Sources of moisture that may lead to mold growth include slow leaks from plumbing fixtures, condensation due to high humidity, floods and other leaks.''',
    },
    {
      'title': 'Chapter 3 : How Can We Restrict The Growth Of Mold?',
      'content':
          '''We can control the growth of mold in our home by regulating the humidity.

1. Repair leaks promptly and dry out damp areas within 48 hours.
2. Pay attention to condensation and damp spots and fix the sources of moisture.
3. Keep HVAC drip pans clean, free-flowing and unobstructed.
4. Exhaust moisture to the outside rather than into crawl spaces or attics.
5. Aim for a relatively low indoor humidity level (below 60%).
6. Regularly inspect your building and HVAC systems and carry out all maintenance as scheduled.''',
    },
    {
      'title': 'Chapter 4 : Protect Yourself',
      'content':
          '''Mold is capable of generating toxins and provoking allergic responses in susceptible individuals. Thus, it is of paramount importance to adopt precautionary measures when handling mold. One should refrain from touching mold with bare hands, prevent mold or mold spores from entering the eyes, and avoid inhaling mold or mold spores. It is highly recommended to utilize personal protective equipment.''',
    },
    {
      'title': 'Chapter 5 : Three Test Methods',
      'content': '''METHOD 1: Test room air
1. Close the door and windows of the room, and take out a petri dish.
2. Write down the test location and time on a label and stick it to the bottom of the petri dish.
3. Remove the lid of the petri dish and place it on a flat surface. Let the petri dish be exposed for 1 hour.
4. After 1 hour, put the lid back on. Put the petri dish in a sealed bag and place it in a warm and dark place.
5. The ideal temperature for mold growth is between 70 and 80 degrees Fahrenheit. Check the petri dish for mold growth after 2 to 4 days (if the temperature is lower, it may take more days).

METHOD 2: Test HVAC system (tape is required)
1. Open the lid of the culture dish and stick the open culture dish to the exhaust port with tape.
2. Set the system fan to high speed for 10 minutes to let the forced air impact the inner surface of the culture dish.
3. After 10 minutes, remove the culture dish and cover it with the lid. Put the petri dish in a sealed bag and place it in a warm and dark place.

METHOD 3: Test an object's surface for mold
1. Use a swab to wipe the surface of the suspected object.
2. Gently rub the tip of the swab back and forth on the culture dish to ensure the sample is transferred to the dish. Then cover the culture dish.
3. Put the culture dish in a sealed bag and place it in a warm and dark place.''',
    },
    {
      'title': 'Chapter 6 : Tips For Detecting Mold On Object Surfaces',
      'content':
          '''1. If the object is small or fragile, you can use a sterile swab to collect mold samples from the air around the object.
2. If the object is large or difficult to wipe, you can press an agar plate directly onto the surface for a few seconds.
3. If you are testing multiple objects, please clearly label each agar plate to avoid confusion.
4. To properly store unused agar plates, follow these steps: tightly wrap the plates with paraffin film or foil. Store the plates upside down in the refrigerator. Use these plates within 2 to 4 weeks.''',
    },
    {
      'title': 'Chapter 7 : How To Handle The Used Petri Dishes',
      'content':
          '''Petri dishes with mold growth need to be handled carefully to prevent the spread of mold and potential health hazards. Choose an appropriate method to deal with used agar plates based on your specific circumstances.

1. Boiling: Carefully open the used agar plate. Place the petri dish in boiling water for at least 20 minutes. After boiling, dispose of it as regular trash.
2. Disinfectant solution: Carefully open the used agar plate. Soak the petri dish in disinfectant solution or bleach for at least 8 hours. After soaking, dispose of it as regular trash.''',
    },
    {
      'title': 'Chapter 8 : Aspergillus niger',
      'content':
          '''Basic Information: Aspergillus niger is a common species belonging to the genus Aspergillus, within the order Eurotiales, class Eurotiomycetes, and phylum Ascomycota.

Distribution Range: It is extensively distributed in soil, decaying plants, compost, and elsewhere. It also exists in grains, plant-based products, and damp indoor environments.

Industrial Value: Aspergillus niger is a significant industrial fermentation strain, capable of generating amylase, acid protease, cellulase, pectinase, glucose oxidase, citric acid, gluconic acid, gallic acid, and others.

Threats to Food and Health: It can cause spoilage and deterioration of food, grains, fruits, and vegetables, resulting in "black mold disease", reducing the nutritional value of food, altering its flavor and texture, shortening the shelf life of fruits and other foods, and causing economic losses. Individuals with compromised immune systems are susceptible to opportunistic infections by Aspergillus niger.''',
    },
    {
      'title': 'Chapter 9 : Aspergillus Flavus',
      'content':
          '''Basic Information: Aspergillus flavus belongs to the genus Aspergillus and is a member of the subphylum Eurotiomycetes, class Eurotiomycetes, order Eurotiales, and family Trichocomaceae. It acquires its name as it generates yellow pigments during the growth process, presenting a conspicuous yellow appearance of the colonies.

Distribution Range: It is extensively distributed in various environments such as soil, air, grains, nuts, fruits, etc. across the world. In tropical and subtropical regions, its distribution is more prevalent due to the suitable temperature and humidity.

Food Safety Hazard: The most significant hazard posed by Aspergillus flavus lies in its capacity to produce aflatoxins. Commonly contaminated foods include peanuts, corn, walnuts, almonds and other nuts, as well as grains like rice and wheat.''',
    },
    {
      'title': 'Chapter 10 : Mucor',
      'content':
          '''Basic information: Mucor belongs to the Zygomycota phylum, Mucorales order, and Mucoraceae family. Within this genus, there are many different species, such as Mucor rouxii and Mucor racemosus.

Distribution: It is widely distributed in soil, air, water, and on the surfaces of various organic materials. In soil, Mucor participates in the decomposition and transformation of organic matter, playing a significant role in the formation and maintenance of soil fertility.

Food aspect: Mucor can cause food to spoil and deteriorate. In high-temperature and high-humidity environments, it can grow rapidly on foods such as bread and fruits, causing the food to develop mold, change color, and develop an unpleasant odor.

Human health: Mucor is a conditional pathogen. For people with weakened immune systems, such as AIDS patients and those who have undergone organ transplants and are taking immunosuppressants, Mucor may cause severe infections, such as mucormycosis.''',
    },
    {
      'title': 'Chapter 11 : Penicillium',
      'content':
          '''Basic Information: Penicillium belongs to the Ascomycota phylum, Eurotiales order, Trichocomaceae family, and Penicillium genus. This genus contains numerous species, with hundreds having been discovered.

Distribution: Penicillium is widely distributed around the world and can be found in soil, air, water, plants, animals, and on various surfaces. In soil, it participates in the decomposition and transformation of organic matter.

Medical Field: Penicillium is an important medicinal fungus. Antibiotics and other medicinal components extracted from Penicillium or produced through fermentation technology are widely used in clinical treatment.

Food Industry: On one hand, certain Penicillium species play a positive role in food fermentation. On the other hand, Penicillium is a common spoilage fungus in food.''',
    },
    {
      'title': 'Chapter 12 : Rhizopus',
      'content':
          '''Basic Information: Rhizopus belongs to the phylum Zygomycota, the order Mucorales, and the genus Rhizopus. This genus encompasses diverse species, such as Rhizopus oryzae and Rhizopus nigricans.

Distribution Range: Rhizopus is prevalently distributed in soil, air, water, and on the surfaces of various organic substances. In soil, it participates in the decomposition and transformation of organic matter.

Food Aspect: In the realm of food fermentation, Rhizopus possesses significant application value. Nevertheless, Rhizopus can also lead to food spoilage and deterioration.

Medical Aspect: Rhizopus is capable of generating certain metabolites with medicinal value, such as specific enzymes and antibiotics. However, Rhizopus is also a conditional pathogen.''',
    },
    {
      'title': 'Chapter 13 : Alternaria alternata',
      'content':
          '''Basic Information: Alternaria belongs to the class Deuteromycetes, order Hyphomycetes, family Dematiaceae, and genus Alternaria. This genus contains numerous species and is one of the larger genera in the fungal kingdom.

Distribution: It is widely distributed around the world and can be found in soil, air, water, plants, animals, and on various surfaces. In daily life, it often appears on moldy fruits, vegetables, grains, and damp walls.

Food: It can cause food to mold and deteriorate, shortening the shelf life of food. During the storage of grains, the growth of Alternaria can cause the grains to mold.

Health: The spores of Alternaria are common allergens that can trigger allergic reactions in humans, such as allergic rhinitis and asthma.''',
    },
    {
      'title': 'Chapter 14 : How to Remove Mold',
      'content':
          '''Please wear an N95 mask, rubber gloves and goggles, and take proper protective measures.

1. Use a professional anti-mold spray. Shake it well and spray it evenly on the moldy surface. Let it sit for a few minutes to take effect, then wipe off the mold and the spray residue with a clean damp cloth.

2. If there are stains after removing the mold, choose a dedicated mold stain remover or deep cleaning anti-mold agent and follow the product instructions to remove the stains and kill the mold at the bottom layer.

3. After cleaning, repaint the walls in damp areas such as bathrooms and kitchens with high-quality anti-mold paint. At the same time, place dehumidifiers and air purifiers in appropriate locations indoors.

4. If there are gaps in the walls, fixtures, etc., use a caulking tool to remove the old sealant. After ensuring that the gaps are free of debris, reseal them to prevent water from seeping in and causing mold to reappear.''',
    },
    {
      'title': 'Chapter 15 : Remove mold from tiles and grout lines',
      'content':
          '''White vinegar and baking soda method: Spray white vinegar and let it stand for 10 minutes. Sprinkle baking soda and scrub until bubbles form. Rinse with warm water, dry thoroughly (natural and safe).

Mold removal gel: Spray directly into the crevices of the floor. After 5 minutes, the mold will be decomposed. Wipe clean without scrubbing. (Fast and efficient.)

Ultraviolet lamp: Wear protective goggles and shine the light into the crevices on the floor to destroy the DNA of mold (professional operation required).''',
    },
    {
      'title': 'Chapter 16 : Remove the mold on the indoor walls',
      'content':
          '''White vinegar or hydrogen peroxide: Spray white vinegar directly and let it stand for 1 hour before scrubbing; or spray 3% hydrogen peroxide and let it stand for 10 minutes before brushing (suitable for colored walls).

Commercial mold-removing spray (such as Lysol): containing quaternary ammonium salts, it can be directly sprayed to kill mold and prevent recurrence. Just follow the instructions for ventilation and no rinsing is required.''',
    },
    {
      'title': 'Chapter 17 : Remove mold stains from fabrics',
      'content':
          '''Pre-treatment: Put the moldy fabric in a separate sealed plastic bag to prevent spore spread. Handle it outdoors or in a well-ventilated area. Wear a mask and gloves, and gently brush off the surface mold with a dry soft brush.

Washing fabrics: Follow the care label instructions. Wash in the hottest water recommended with a laundry disinfectant; if there are mold spots, use an oxygen-based bleach; for dry-clean only fabrics, inform the dry cleaner that there is mold.''',
    },
    {
      'title': 'Chapter 18 : Remove mold from leather',
      'content':
          '''Pre-treatment: Move the moldy leather to a well-ventilated area (such as a balcony), wear an N95 mask and rubber gloves, and gently brush the surface mold spots with a soft-bristled brush.

For mild mold: Mix white vinegar and water in a 1:1 ratio, wipe the area, and let it air dry naturally.

Stubborn mold: Gently wipe with a 70% alcohol cotton ball (do not overly saturate), or use a specialized leather cleaner (such as Lexol).

For dark leather with mold spots: Apply 3% hydrogen peroxide locally, let it stand and then wipe clean.

When unable to handle: Send to a professional leather repair shop.''',
    },
    {
      'title': 'Chapter 19 : Remove mold from electrical appliances',
      'content':
          '''For the microwave oven: Put 1 cup of water and 2 tablespoons of white vinegar in a bowl, heat on high for 5 minutes. The steam will soften the mold. Then wipe the inner walls clean with a damp cloth and open the door to air dry.

Washing machine: Use a special washing machine cleaner. Alternatively, add warm water at approximately 40°C to the washing machine until it reaches half of its height, pour in 500 milliliters of white vinegar, let the washing machine run for 5 to 10 minutes, then soak for 1 hour. After draining the water, add half a cup of baking soda, run a complete washing cycle, and finally rinse it several times. After each laundry cycle, wipe the inner drum with a damp cloth, focusing on areas such as the sealing ring and the door seal to keep the inner drum dry.

To remove mold from the refrigerator: Mix white vinegar and water in a 1:1 ratio and put it in a spray bottle. Spray the moldy areas in the refrigerator, let it air dry, and it can kill bacteria and remove odors. Or make a solution by adding baking soda to warm water, dip a cloth in it and wipe the inside of the refrigerator to remove stains and odors. Rinse with clean water and dry. Dip a cotton ball in medical alcohol and wipe stubborn mold to quickly kill bacteria without leaving residue. Rinse with clean water and dry after wiping. Use a special disinfectant and cleaner for refrigerators as per the instructions to remove mold and prevent its recurrence. Rinse with clean water and dry.''',
    },
    {
      'title': 'Conclusion : Essential Reading Before Use',
      'content':
          '''Sometimes there may be a small amount of water in the petri dish, which is a normal phenomenon and will not affect the test results. As long as the agar at the bottom remains intact, the test can proceed as usual.

If the agar in the petri dish is damaged due to temperature or transportation, please contact us promptly. We will send you a new test kit for free or process a refund according to your needs. There is no need to return the damaged agar to us.

After you complete the mold test, you can send the mold photos to our laboratory email. Our staff will identify and analyze them for you. To better analyze the mold, you can wait until the mold on the petri dish grows large enough (refer to the size of the mold shown in the guide) before sending the photos. When taking photos, you need to remove the petri dish from the sealed bag and place it on a flat table with good lighting. We need photos of both the front and back of the petri dish. Try to avoid any obstruction of the mold in the petri dish. Our laboratory team will send you the mold analysis report and provide methods for dealing with mold within 24 hours.

If you have any questions about your order or any other matters, please contact us. We will help you solve any problems you encounter.''',
    },
  ];

  final List<Map<String, String>> _guideChaptersEs = [
    {
      'title': 'Capítulo 1 : ¿Qué es el moho?',
      'content':
          '''El moho es un tipo de hongo, no una planta ni un animal. Se conocen miles de especies de moho en todo el mundo. El moho desempeña un papel importante en el medio ambiente al descomponer materia orgánica. Sin embargo, también puede causar daños en la propiedad, deterioro de alimentos y producir compuestos tóxicos llamados micotoxinas. Las micotoxinas forman parte del mecanismo de defensa natural del moho, pero pueden ser perjudiciales para la salud humana. Además, muchos mohos pueden desencadenar reacciones alérgicas en personas sensibles.

El moho se propaga mediante la generación de diminutas esporas que flotan en el aire o se depositan en superficies y empiezan a crecer. Las esporas son invisibles a simple vista y están muy extendidas.''',
    },
    {
      'title': 'Capítulo 2 : Condiciones para el crecimiento del moho',
      'content':
          '''El crecimiento del moho requiere dos elementos: una fuente de alimento orgánico biodegradable y humedad. En edificios y viviendas existen muchas fuentes de alimento para el moho, como madera, papel y materiales de fibra natural. Aunque normalmente no podemos controlar la presencia de estas fuentes, sí podemos limitar el crecimiento del moho regulando la humedad interior.

Fuentes de humedad que favorecen el crecimiento incluyen fugas lentas en fontanería, condensación por alta humedad, inundaciones y otras filtraciones.''',
    },
    {
      'title': 'Capítulo 3 : ¿Cómo podemos limitar el crecimiento del moho?',
      'content':
          '''Podemos controlar el crecimiento del moho en el hogar regulando la humedad.

1. Repare las fugas con prontitud y seque las áreas húmedas en 48 horas.
2. Controle la condensación y los puntos húmedos y arregle las fuentes de humedad.
3. Mantenga las bandejas de drenaje del HVAC limpias y sin obstrucciones.
4. Expulse la humedad al exterior en lugar de a espacios cerrados o áticos.
5. Mantenga el nivel de humedad interior relativamente bajo (por debajo del 60%).
6. Inspeccione regularmente el edificio y los sistemas HVAC y realice el mantenimiento programado.''',
    },
    {
      'title': 'Capítulo 4 : Protéjase',
      'content':
          '''El moho puede generar toxinas y provocar respuestas alérgicas en individuos sensibles. Por ello es importante tomar precauciones al manipular moho. Evite tocar el moho con las manos desnudas, evite que las esporas entren en los ojos y evite inhalarlas. Se recomienda usar equipo de protección personal.''',
    },
    {
      'title': 'Capítulo 5 : Tres métodos de prueba',
      'content': '''MÉTODO 1: Probar el aire de la habitación
1. Cierre la puerta y ventanas de la habitación y saque una placa de Petri.
2. Anote la ubicación y la hora en una etiqueta y péguela en el fondo de la placa.
3. Retire la tapa y coloque la placa sobre una superficie plana. Déjela expuesta durante 1 hora.
4. Después de 1 hora, vuelva a taparla y guárdala en una bolsa sellada en un lugar cálido y oscuro.
5. La temperatura ideal para el crecimiento del moho es entre 21-27 °C. Compruebe la placa después de 2 a 4 días (si la temperatura es menor puede tardar más).

MÉTODO 2: Probar el sistema HVAC (se requiere cinta)
1. Abra la placa y fíjela con cinta en la salida de aire.
2. Ponga el ventilador a alta velocidad durante 10 minutos para que el aire impacte la placa.
3. Retire la placa, tápela y colóquela en una bolsa sellada en un lugar cálido y oscuro.

MÉTODO 3: Probar la superficie de un objeto
1. Use un hisopo para frotar la superficie sospechosa.
2. Frote la punta del hisopo sobre la placa para transferir la muestra y luego tápela.
3. Coloque la placa en una bolsa sellada en un lugar cálido y oscuro.''',
    },
    {
      'title': 'Capítulo 6 : Consejos para detectar moho en superficies',
      'content':
          '''1. Si el objeto es pequeño o frágil, use un hisopo estéril para recoger muestras del aire alrededor del objeto.
2. Si el objeto es grande, presione la placa de agar directamente sobre la superficie durante unos segundos.
3. Si prueba varios objetos, etiquete claramente cada placa para evitar confusiones.
4. Para almacenar placas sin usar: envuélvalas bien con film o papel de aluminio. Guárdelas boca abajo en el refrigerador y utilícelas en 2 a 4 semanas.''',
    },
    {
      'title': 'Capítulo 7 : Cómo manejar las placas usadas',
      'content':
          '''Las placas con crecimiento de moho deben manejarse con cuidado para evitar la dispersión de esporas y riesgos para la salud. Elija el método adecuado según su caso.

1. Hervido: Abra la placa con cuidado y colóquela en agua hirviendo durante al menos 20 minutos. Tras hervir, deseche como residuo doméstico.
2. Solución desinfectante: Abra la placa y sumérjala en solución desinfectante o lejía durante al menos 8 horas. Tras el remojo, deseche como residuo doméstico.''',
    },
    {
      'title': 'Capítulo 8 : Aspergillus niger',
      'content':
          '''Información básica: Aspergillus niger es una especie común del género Aspergillus.

Distribución: Se encuentra en suelo, materia vegetal en descomposición, compost y ambientes interiores húmedos. También puede aparecer en granos y productos vegetales.

Valor industrial: Se usa en fermentaciones industriales para producir enzimas y ácidos como el ácido cítrico.

Riesgos: Puede causar deterioro de alimentos y, en personas con sistemas inmunitarios debilitados, infecciones oportunistas.''',
    },
    {
      'title': 'Capítulo 9 : Aspergillus flavus',
      'content':
          '''Información básica: Aspergillus flavus produce colonias de color amarillo y puede encontrarse en suelos, aire, frutos secos y granos.

Riesgos alimentarios: Es conocido por producir aflatoxinas, potentes toxinas que contaminan cacahuetes, maíz, frutos secos y cereales.''',
    },
    {
      'title': 'Capítulo 10 : Mucor',
      'content':
          '''Información básica: Mucor es un género de hongos presente en suelo, aire y superficies orgánicas.

Distribución y alimentos: Puede causar deterioro de alimentos en condiciones de alta temperatura y humedad.

Salud: Es un patógeno oportunista en personas con defensas debilitadas.''',
    },
    {
      'title': 'Capítulo 11 : Penicillium',
      'content':
          '''Información básica: Penicillium comprende muchas especies; algunas son útiles en la producción de antibióticos y en alimentos fermentados, otras causan deterioro alimentario.''',
    },
    {
      'title': 'Capítulo 12 : Rhizopus',
      'content':
          '''Información básica: Rhizopus aparece en suelo, agua y materiales orgánicos. Tiene aplicaciones en fermentación pero también puede provocar deterioro de alimentos.''',
    },
    {
      'title': 'Capítulo 13 : Alternaria alternata',
      'content':
          '''Información básica: Alternaria es frecuente en frutas, vegetales y paredes húmedas. Sus esporas son alérgenos comunes que pueden causar rinitis y asma.''',
    },
    {
      'title': 'Capítulo 14 : Cómo eliminar el moho',
      'content': '''Use mascarilla N95, guantes de goma y gafas de protección.

1. Use un spray anti-moho profesional; rocíe y deje actuar, luego limpie con un paño húmedo.
2. Para manchas persistentes use un removedor específico según las instrucciones.
3. Repinte con pintura anti-moho y coloque deshumidificadores o purificadores de aire si es necesario.
4. Selle grietas y juntas para evitar la entrada de humedad.''',
    },
    {
      'title': 'Capítulo 15 : Eliminar moho de baldosas y juntas',
      'content':
          '''Método vinagre y bicarbonato: Aplique vinagre blanco, deje 10 minutos, espolvoree bicarbonato y frote hasta que haga espuma. Enjuague y seque.

Gel anti-moho: Aplique en las grietas, espere 5 minutos y limpie.

Lámpara UV: Uso profesional con protección ocular.''',
    },
    {
      'title': 'Capítulo 16 : Eliminar moho de paredes interiores',
      'content':
          '''Vinagre o peróxido: Aplique vinagre blanco o peróxido de 3% según la superficie y deje actuar antes de frotar. Siga las instrucciones del producto y ventile.''',
    },
    {
      'title': 'Capítulo 17 : Quitar manchas de moho en tejidos',
      'content':
          '''Pretratamiento: Selle la prenda en una bolsa para evitar esporas. Lave según etiqueta con desinfectante. Para manchas use blanqueador a base de oxígeno si procede.''',
    },
    {
      'title': 'Capítulo 18 : Eliminar moho del cuero',
      'content':
          '''Pretratamiento: Lleve la pieza a un área ventilada, use mascarilla y guantes, cepille suavemente.

Para moho leve: mezcle vinagre y agua 1:1 y limpie.

Para moho persistente: use alcohol 70% o limpiadores específicos para cuero.''',
    },
    {
      'title': 'Capítulo 19 : Eliminar moho de electrodomésticos',
      'content':
          '''Microondas: Caliente agua con vinagre para generar vapor y facilitar la limpieza.

Lavadora: Use limpiadores específicos o vinagre y bicarbonato según el procedimiento descrito.

Nevera: Limpie con mezcla de vinagre y agua 1:1 o bicarbonato y enjuague bien.''',
    },
    {
      'title': 'Conclusión : Lectura esencial antes de usar',
      'content':
          '''Puede haber algo de agua en la placa sin afectar los resultados. Si el agar se daña durante el envío, contacte y se le reemplazará la placa o se tramitará un reembolso.

Tras completar la prueba, puede enviar fotos a nuestro laboratorio para análisis. Envíe fotos bien iluminadas delantera y trasera. Nuestro equipo proporcionará un informe en 24 horas aproximadamente.

Si tiene preguntas sobre su pedido o el proceso, contacte con nuestro soporte.''',
    },
  ];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _totalPages; i++) {
      _scrollControllers.add(ScrollController());
    }
  }

  @override
  void dispose() {
    for (final c in _scrollControllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _exportPDFFromStorage() async {
    final locale = Localizations.localeOf(context);
    final isEs = (locale.languageCode.toLowerCase() == 'es');
    final fileName = isEs ? 'guide_es.pdf' : 'guide_en.pdf';

    setState(() {
      _isLoadingFromStorage = true;
      _storagePdfError = null;
    });

    try {
      final ref = FirebaseStorage.instance.ref('guides/$fileName');
      final bytes = await ref.getData();

      if (bytes == null || bytes.isEmpty) {
        throw Exception('PDF file is empty');
      }

      await Printing.layoutPdf(
        onLayout: (format) => Future.value(bytes),
        name: isEs ? 'TESIA_Guia_Moho.pdf' : 'TESIA_Mold_Guide.pdf',
      );

      setState(() => _isLoadingFromStorage = false);
    } catch (e) {
      setState(() {
        _storagePdfError = e.toString();
        _isLoadingFromStorage = false;
      });

      await _generateFallbackPDF();
    }
  }

  Future<void> _generateFallbackPDF() async {
    final locale = Localizations.localeOf(context);
    final isEs = (locale.languageCode.toLowerCase() == 'es');
    final chapters = isEs ? _guideChaptersEs : _guideChaptersEn;

    final pdf = pw.Document();

    final logoData = await rootBundle.load('assets/logos/Tesia_nobg.png');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final titleText = isEs ? 'Guía de Moho TESIA' : 'TESIA Mold Guide';
    final titleStyle = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.indigo800,
    );
    final chapterTitleStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.indigo800,
    );
    final bodyStyle = const pw.TextStyle(fontSize: 12, lineSpacing: 1.5);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        footer:
            (context) => pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                isEs
                    ? 'Página ${context.pageNumber} de ${context.pagesCount}'
                    : 'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),
        build: (context) {
          final content = <pw.Widget>[];

          content.add(
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Image(logo, width: 80, height: 80),
                pw.SizedBox(width: 16),
                pw.Text(titleText, style: titleStyle),
              ],
            ),
          );
          content.add(pw.SizedBox(height: 12));
          content.add(pw.Divider(thickness: 1, color: PdfColors.grey400));
          content.add(pw.SizedBox(height: 24));

          for (int i = 0; i < chapters.length; i++) {
            final chapter = chapters[i];

            content.addAll([
              pw.Text(chapter['title']!, style: chapterTitleStyle),
              pw.SizedBox(height: 8),
              pw.Text(chapter['content']!, style: bodyStyle),
              if (i < chapters.length - 1) pw.SizedBox(height: 28),
            ]);
          }

          return content;
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: isEs ? 'TESIA_Guia_Moho.pdf' : 'TESIA_Mold_Guide.pdf',
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color.fromARGB(255, 48, 67, 178) : kTesiaColor;
    final locale = Localizations.localeOf(context);
    final chapters =
        (locale.languageCode.toLowerCase() == 'es')
            ? _guideChaptersEs
            : _guideChaptersEn;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.08,
                  ),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.grey).withOpacity(
                      0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.guideTitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.guideDescription,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withOpacity(0.15),
                            accentColor.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap:
                              _isLoadingFromStorage
                                  ? null
                                  : _exportPDFFromStorage,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child:
                                _isLoadingFromStorage
                                    ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          accentColor,
                                        ),
                                      ),
                                    )
                                    : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.picture_as_pdf_rounded,
                                          size: 20,
                                          color: accentColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          loc.export,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isDark
                          ? [const Color(0xFF1E1E2E), const Color(0xFF252535)]
                          : [Colors.white, const Color(0xFFFAFAFA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isDark ? Colors.white : kTesiaColor).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(isDark ? 0.15 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    final scrollController = _scrollControllers[index];

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Scrollbar(
                          controller: scrollController,
                          thumbVisibility: true,
                          radius: const Radius.circular(8),
                          thickness: 6,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(28),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight - 56,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: accentColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.auto_stories_rounded,
                                          size: 16,
                                          color: accentColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Chapter ${index + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: accentColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  Text(
                                    chapters[index]['title']!.replaceFirst(
                                      RegExp(r'^(Chapter|Capítulo) \d+ : '),
                                      '',
                                    ),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                      height: 1.3,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Container(
                                    height: 3,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          accentColor,
                                          accentColor.withOpacity(0.3),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  SelectableText(
                                    chapters[index]['content']!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.8,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.85),
                                      letterSpacing: 0.2,
                                    ),
                                    showCursor: false,
                                  ),

                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.04,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.08,
                  ),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    children: List.generate(
                      _totalPages,
                      (index) => Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(
                            right: index < _totalPages - 1 ? 6 : 0,
                          ),
                          decoration: BoxDecoration(
                            gradient:
                                index <= _currentPage
                                    ? LinearGradient(
                                      colors: [
                                        accentColor,
                                        accentColor.withOpacity(0.6),
                                      ],
                                    )
                                    : null,
                            color:
                                index > _currentPage
                                    ? (isDark ? Colors.white : Colors.grey)
                                        .withOpacity(0.2)
                                    : null,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    loc.pageXofY((_currentPage + 1), _totalPages),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _currentPage > 0 ? _previousPage : null,
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: Text(loc.previous),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentColor,
                            disabledForegroundColor:
                                Theme.of(context).disabledColor,
                            side: BorderSide(
                              color:
                                  _currentPage > 0
                                      ? accentColor.withOpacity(0.4)
                                      : Colors.grey.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _currentPage < _totalPages - 1 ? _nextPage : null,
                          label: Text(loc.next),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                          iconAlignment: IconAlignment.end,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade500,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
