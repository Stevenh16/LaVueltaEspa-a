CREATE VIEW Clasificacion_general_2021
AS
SELECT puesto, corredor, equipo, tiempofinal, 
	tiempofinal-(SELECT SUM(tiempo) tiempofinal
				 FROM(SELECT (SELECT CONCAT(primerNombre,' ',primerApellido)
							  FROM participantes
							  WHERE r.idcorredor = idparticipante) AS Corredor,
					  		 (SELECT eq.nombre
							  FROM corredoresdeequipos AS ce
							  INNER JOIN equipos AS eq ON ce.idequipo = eq.idequipo
							  WHERE ce.idcorredor = r.idcorredor
							  LIMIT 1) AS Equipo,
					  t.tiempofinalización AS tiempo,
					  t.tiempobonificación AS Bonificación,
					  t.tiempopenalización AS Penalización
					  FROM tiempos AS t
					  INNER JOIN resultados AS r ON t.idtiempo = r.idresultado
					  INNER JOIN etapas AS e ON e.idetapa = r.idetapa
					  INNER JOIN carreras AS c ON c.idcarrera = e.idcarrera
					  WHERE c.edición = '2021'
					  ORDER BY corredor ASC)
				 GROUP BY corredor
				 ORDER BY tiempofinal
				 LIMIT 1) AS diferencia,bonificación, penalización
FROM (SELECT ROW_NUMBER() OVER(ORDER BY SUM(tiempo)) AS Puesto,
	  corredor, MIN(equipo) AS Equipo, SUM(tiempo) tiempofinal, SUM(bonificación) AS Bonificación, SUM(penalización) AS penalización
	  FROM(SELECT (SELECT CONCAT(primerNombre,' ',primerApellido)
				   FROM participantes
				   WHERE r.idcorredor = idparticipante) AS Corredor,
		   		  (SELECT eq.nombre
				   FROM corredoresdeequipos AS ce
				   INNER JOIN equipos AS eq ON ce.idequipo = eq.idequipo
				   WHERE ce.idcorredor = r.idcorredor
				   LIMIT 1) AS Equipo,
		   		   t.tiempofinalización AS tiempo,
		   		   t.tiempobonificación AS Bonificación,
		           t.tiempopenalización AS Penalización
		   FROM tiempos AS t
		   INNER JOIN resultados AS r ON t.idtiempo = r.idresultado
		   INNER JOIN etapas AS e ON e.idetapa = r.idetapa
		   INNER JOIN carreras AS c ON c.idcarrera = e.idcarrera
		   WHERE c.edición = '2021'
		   ORDER BY corredor ASC)
	  GROUP BY corredor
	  ORDER BY tiempofinal)
GROUP BY puesto, corredor, equipo, tiempofinal, bonificación, penalización

CREATE VIEW Clasificacion_puntos_2021
AS
SELECT ROW_NUMBER() OVER(ORDER BY SUM(pu.obtenido) DESC) AS Puesto,
	(SELECT CONCAT(p.primerNombre,' ',p.primerApellido)
	 FROM participantes AS p
	 WHERE p.idparticipante = r.idcorredor) AS Corredor,
	(SELECT eq.nombre
     FROM corredoresdeequipos AS ce
	 INNER JOIN equipos AS eq ON ce.idequipo = eq.idequipo
	 WHERE ce.idcorredor = r.idcorredor AND (ce.fechafinalización IS NULL OR ce.fechafinalización > (SELECT fechafinalización
																									 FROM carreras
																									 WHERE edición = '2021'))
	 LIMIT 1
	) AS Equipo,
	 SUM(pu.obtenido) AS puntos,
	 SUM(pu.penalización) AS penalización
FROM Puntos AS pu
INNER JOIN resultados AS r ON pu.idpunto = r.idresultado
INNER JOIN etapas AS e ON r.idetapa = e.idetapa
INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
WHERE ca.edición = '2021' AND pu.idtipopunto = (SELECT idtipopunto
											    FROM tipodepuntos
											    WHERE nombre = 'Defitivos')
GROUP BY r.idcorredor

CREATE VIEW Clasificacion_montaña_2021
AS
SELECT ROW_NUMBER() OVER(ORDER BY SUM(pu.obtenido) DESC) AS Puesto,
	(SELECT CONCAT(p.primerNombre,' ',p.primerApellido)
	 FROM participantes AS p
	 WHERE p.idparticipante = r.idcorredor) AS Corredor,
	(SELECT eq.nombre
     FROM corredoresdeequipos AS ce
	 INNER JOIN equipos AS eq ON ce.idequipo = eq.idequipo
	 WHERE ce.idcorredor = r.idcorredor AND (ce.fechafinalización IS NULL OR ce.fechafinalización > (SELECT fechafinalización
																									 FROM carreras
																									 WHERE edición = '2021'))
	 LIMIT 1
	) AS Equipo,
	 SUM(pu.obtenido) AS puntos,
	 SUM(pu.penalización) AS penalización
FROM Puntos AS pu
INNER JOIN resultados AS r ON pu.idpunto = r.idresultado
INNER JOIN etapas AS e ON r.idetapa = e.idetapa
INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
WHERE ca.edición = '2021' AND pu.idtipopunto = (SELECT idtipopunto
											    FROM tipodepuntos
											    WHERE nombre = 'Montaña')
GROUP BY r.idcorredor

CREATE VIEW Clasificacion_joven_2021
AS
SELECT ROW_NUMBER() OVER(ORDER BY SUM(t.tiempofinalización)) AS puesto,
	CONCAT(p.primerNombre,' ',p.primerApellido) AS corredor,
	(SELECT eq.nombre
     FROM corredoresdeequipos AS ce
	 INNER JOIN equipos AS eq ON ce.idequipo = eq.idequipo
	 WHERE ce.idcorredor = p.idparticipante AND (ce.fechafinalización IS NULL OR ce.fechafinalización > (SELECT fechafinalización
																									 FROM carreras
																									 WHERE edición = '2021'))
	 LIMIT 1
	) AS equipo,
	SUM(t.tiempofinalización) AS tiempofinalización,
	SUM(t.tiempofinalización)-(SELECT SUM(t.tiempofinalización)
				   FROM tiempos AS t
				   INNER JOIN resultados AS r ON t.idtiempo = r.idresultado
				   INNER JOIN etapas AS e ON r.idetapa = e.idetapa
				   INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
				   INNER JOIN participantes AS p ON r.idcorredor = p.idparticipante
				   WHERE ca.edición = '2021' AND EXTRACT(YEAR FROM AGE(NOW(),p.fechanacimiento)) < 26
				   GROUP BY r.idcorredor
				   ORDER BY SUM(t.tiempofinalización)
				   LIMIT 1
				  ) AS diferencia,
	SUM(t.tiempobonificación) AS bonificación,
	SUM(t.tiempopenalización) AS penalización
FROM tiempos AS t
INNER JOIN resultados AS r ON t.idtiempo = r.idresultado
INNER JOIN etapas AS e ON r.idetapa = e.idetapa
INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
INNER JOIN participantes AS p ON r.idcorredor = p.idparticipante
WHERE ca.edición = '2021' AND EXTRACT(YEAR FROM AGE(NOW(),p.fechanacimiento)) < 26
GROUP BY p.idparticipante

CREATE VIEW clasificacion_equipos_2021
AS
SELECT ROW_NUMBER() OVER(ORDER BY SUM(t.tiempofinalización)) AS puesto,
	(SELECT nombre
	 FROM equipos
	 WHERE equipos.idequipo = ce.idequipo) AS equipo,
	 SUM(t.tiempofinalización) AS tiempos,
	 SUM(t.tiempofinalización)-(SELECT SUM(t.tiempofinalización) AS tiempo
								FROM Tiempos AS t
								INNER JOIN resultados AS r ON t.idtiempo = r.idresultado
								INNER JOIN etapas AS e ON r.idetapa = e.idetapa
								INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
								INNER JOIN corredoresdeequipos AS ce ON r.idcorredor = ce.idcorredor
								WHERE ca.edición = '2021'
								GROUP BY ce.idequipo
								ORDER BY tiempo
								LIMIT 1
							   ) AS diferencia,
	 SUM(t.tiempopenalización) AS penalización
FROM Tiempos AS t
INNER JOIN resultados AS r ON t.idtiempo = r.idresultado
INNER JOIN etapas AS e ON r.idetapa = e.idetapa
INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
INNER JOIN corredoresdeequipos AS ce ON r.idcorredor = ce.idcorredor
WHERE ca.edición = '2021'
GROUP BY ce.idequipo

CREATE VIEW corredoresjovenes
AS
SELECT p.idparticipante,
	CONCAT(p.primerNombre,' ', p.primerApellido) Corredor,
	EXTRACT(YEAR FROM AGE(NOW(),p.fechanacimiento)) AS Edad, (SELECT pa.nombre
															  FROM países AS pa
															  INNER JOIN ciudades AS c ON c.idpaís = pa.idpaís
															  WHERE c.idciudad = p.idciudad) AS País
FROM participantes AS p
WHERE EXTRACT(YEAR FROM AGE(NOW(),p.fechanacimiento)) < 26

CREATE OR REPLACE FUNCTION paísParticipante(participante INT)
RETURNS VARCHAR AS $$
DECLARE 
	país VARCHAR;
BEGIN
	SELECT pa.nombre INTO país
	FROM participantes AS p
	INNER JOIN ciudades AS c ON p.idciudad = c.idciudad
	INNER JOIN países AS pa ON c.idpaís = pa.idpaís
	WHERE p.idparticipante = participante;
	RETURN país;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION tiempoTotalCorredor(corredor INT, ediciónb VARCHAR)
RETURNS INTERVAL AS $$
DECLARE
	tiempo INTERVAL;
BEGIN
	SELECT SUM(t.tiempofinalización) INTO tiempo
	FROM tiempos AS t
	INNER JOIN resultados AS r ON t.idtiempo = r.idresultado
	INNER JOIN etapas AS e ON r.idetapa = e.idetapa
	INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
	WHERE ca.edición = ediciónb AND r.idcorredor = corredor
	GROUP BY r.idcorredor;
	RETURN tiempo;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION corredoresCarrera(ediciónb TEXT)
RETURNS TABLE (
	idcorredor INT,
	corredor TEXT
) AS $$
BEGIN
	RETURN QUERY
	SELECT r.idcorredor, (SELECT CONCAT(p.primerNombre,' ',p.primerApellido)
						  FROM participantes AS p
						  WHERE p.idparticipante = r.idcorredor) AS corredor
	FROM resultados AS r
	INNER JOIN etapas AS e ON r.idetapa = e.idetapa
	INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
	WHERE ca.edición  = ediciónb
	GROUP BY r.idcorredor;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION distanciaTotalCorredor(corredor INT, edicion TEXT)
RETURNS FLOAT AS $$
DECLARE
	distancia FLOAT;
BEGIN
	SELECT SUM(e.distanciatotal) INTO distancia
	FROM resultados AS r
	INNER JOIN etapas AS e ON r.idetapa = e.idetapa
	INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
	WHERE ca.edición = edicion AND r.idcorredor = corredor;
	RETURN distancia;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION puntostotalcorredor(corredor INT, edicion TEXT)
RETURNS INT AS $$
DECLARE
	puntos INT;
BEGIN
	SELECT SUM(pu.obtenido) INTO puntos
	FROM puntos AS pu
	INNER JOIN resultados AS r ON pu.idpunto = r.idresultado
	INNER JOIN etapas AS e ON r.idetapa = e.idetapa
	INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
	WHERE ca.edición = edicion AND r.idcorredor =  corredor AND pu.idtipopunto = (SELECT idtipopunto
																			    FROM tipodepuntos
																			    WHERE nombre = 'Defitivos')
	GROUP BY r.idcorredor;
	RETURN puntos;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION montañatotalcorredor(corredor INT, edicion TEXT)
RETURNS INT AS $$
DECLARE
	puntos INT;
BEGIN
	SELECT SUM(pu.obtenido) INTO puntos
	FROM puntos AS pu
	INNER JOIN resultados AS r ON pu.idpunto = r.idresultado
	INNER JOIN etapas AS e ON r.idetapa = e.idetapa
	INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
	WHERE ca.edición = edicion AND r.idcorredor =  corredor AND pu.idtipopunto = (SELECT idtipopunto
																			    FROM tipodepuntos
																			    WHERE nombre = 'Montaña')
	GROUP BY r.idcorredor;
	RETURN puntos;
END;
$$ LANGUAGE 'plpgsql';
