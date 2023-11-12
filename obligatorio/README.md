Objetivo:
----------
Detectar la falta de atención del conductor a partir de diferentes sensores
instalados en el vehículo. El sistema analizará la información obtenida de los sensores para detectar posibles
síntomas de distracciones. A partir de estos síntomas se definen unas situaciones de riesgo, ante las cuales el
sistema realizará diferentes actuaciones para hacer reaccionar al conductor-

Sensores:
----------
* Giroscopio: Detector de giros (X,Y) para controlar la posición de la cabeza
* Giro Volante: Sensor que indica el grado de giro del volante en el rango de -180º a 180º
* Velocímetro: Indica la velocidad actual del vehículo
* Sensor de distancia: Sensor de ultrasonidos ubicado en la parte frontal del vehículo para medir la distancia con el vehículo precedente


Actuadores:
----------
* Luces de aviso: Habrá 2 luces, una luz amarilla y otra roja para indicar situaciones de mayor riesgo
* Display: Se utilizará para visualizar datos que estará a la vista del piloto y el copiloto.
* Alarma sonora: para emitir pitidos con 5 niveles de intensidad.
* Activación de freno automático: El sistema activado el freno ante el peligro inminente de colisión. 


Detección de síntomas:
----------
* Riesgos (150 ms): se analizarán los síntomas para detectar posibles riesgos, ante los cuales el sistema tendrá que reaccionar llevando a cabo algunas actuaciones
* Distancia Seguridad (300 ms): 
    - distanciaActual < distanciaSeguridad => DISTANCIA INSEGURA + LIGHT ON
    - distanciaActual < distanciaSeguridad/2 => DISTANCIA IMPRUDENTE + LIGHT ON + BEEP 4
    - distanciaActual < distanciaSeguridad/3 => PELIGRO COLISIÓN
* GiroVolante (350 ms): Si en dos lecturas consecutivas la diferencia es > 20 y velocidad > 40 => VOLANTAZO
* Cabeza inclinada (400 ms):
    - eje X es > 30º (en dos lecturas consecutivas) => CAB INCLINADA (hacia delante o hacia atrás) => SOMNOLENCIA O DISTRACCION + CAB INCLINADA
    - ejeY > 30º (en dos lecturas consecutivas) y conductor gira volante en mismo sentido que inclinacion cab => NO ES SOMNOLENCIA NI DISTRACCIÓN
    - ejeY > 30º (en dos lecturas consecutivas) y conductor no gira volante =>SOMNOLENCIA O DISTRACCION + CAB INCLINADA
* Display: sirve para visualizar los datos por pantalla. Se actualizará una vez por segundo:
    - Distancia actual con el vehículo precedente
    - Velocidad Actual
    - Síntomas detectados en el conductor, según lo especificado anteriormente. 
