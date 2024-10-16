--1 ¿Cuántos corredores de la etapa 1 edición 2022 han 
--obtenido el resultado de tipo punto y la distancia total por etapa sea menor al 
--promedio de la distancia total de todas las etapas de esa edición? 

SELECT COUNT(r.idcorredor)
FROM resultados AS r
INNER JOIN etapas AS e ON r.idetapa = e.idetapa
WHERE r.idtiporesultado = (SELECT idtiporesultado
						   FROM tiposderesultados
						   WHERE nombre = 'Punto')
AND
e.distanciaTotal < (SELECT AVG(distanciatotal)
				    FROM etapas
				    WHERE idcarrera IN (SELECT idcarrera
									   FROM carreras
									   WHERE edición = '2022')
				   )
AND e.idcarrera IN (SELECT idcarrera
				  FROM carreras
				  WHERe edición = '2022')
AND
r.idcorredor IN (SELECT c.idcorredor
					 FROM corredores AS c
					 INNER JOIN corredoresdeequipos AS ce ON ce.idcorredor = c.idcorredor
					 INNER JOIN equiposcarreras AS ec ON ec.idequipo = ce.idequipo
					 INNER JOIN carreras AS ca ON ca.idcarrera = ec.idcarrera
					 INNER JOIN etapas AS e ON ca.idcarrera = e.idcarrera
					 WHERE ca.edición='2022' AND e.idetapa= 22 AND ce.fechainicio BETWEEN '2022-01-01' AND '2023-01-01')


--2 ¿Cuál es el nombre completo, incluyendo nacionalidad, del corredor de la etapa 1 
--edición 2021 que obtuvo más de un maillot y que ha participado en más ediciones de la 
--Vuelta España?

SELECT (SELECT CONCAT(p.primerNombre,' ',p.primerApellido)
	    FROM participantes AS p
	    WHERE p.idparticipante = c.idcorredor) AS nombreCompleto
FROM corredores AS c
INNER JOIN corredoresdeequipos AS ce ON ce.idcorredor = c.idcorredor
INNER JOIN equiposcarreras AS ec ON ec.idequipo = ce.idequipo
INNER JOIN carreras AS ca ON ca.idcarrera = ec.idcarrera
INNER JOIN etapas AS e ON ca.idcarrera = e.idcarrera
WHERE ca.edición='2021' AND e.idetapa= 1 AND ce.fechainicio < '2022-01-01'
AND (SELECT COUNT(pr.idpremio)
	 FROM resultados AS r
	 INNER JOIN premiosresultados AS pr ON r.idresultado = pr.idresultado
	 WHERE r.idcorredor = c.idcorredor) > 1
AND (SELECT COUNT(c2.idcorredor)
	 FROM corredores AS c2
	 INNER JOIN corredoresdeequipos AS ce ON ce.idcorredor = c2.idcorredor
	 INNER JOIN equiposcarreras AS ec ON ec.idequipo = ce.idequipo
	 INNER JOIN carreras AS ca ON ca.idcarrera = ec.idcarrera
	 WHERE c2.idcorredor = c.idcorredor
	 GROUP BY c2.idcorredor , ca.idcarrera
	 LIMIT 1) > 1


--3 ¿Cuál es el nombre completo, su nacionalidad y el numero de equipos que ha dirigido
--el director deportivo más viejo?

SELECT CONCAT(p.primerNombre,' ',p.primerApellido) AS nombreCompleto, 
	(SELECT pa.nombre
	 FROM países AS pa 
	 INNER JOIN ciudades AS ci ON pa.idpaís = ci.idpaís
	 WHERE ci.idciudad = p.idciudad) AS país,
	 COUNT(d.iddirector) numeroEquipos
FROM directoresdeequipo AS d
INNER JOIN participantes AS p ON p.idparticipante = d.iddirector
INNER JOIN directoresdelosequipos AS de ON d.iddirector = de.iddirector
WHERE p.fechanacimiento = (SELECT MIN(fechanacimiento)
						   FROM participantes
						   WHERE idparticipante IN (SELECT iddirector
												    FROM directoresdeequipo))
GROUP BY nombreCompleto, p.idciudad

--4 ¿Cuáles son los nombres completos, incluyendo nacionalidad, de los corredores  
--colombianos que han ganado más de un maillot y que han obtenido el maillot verde?

SELECT CONCAT(p.primerNombre,' ',p.primerApellido) AS nombreCompleto, 
	(SELECT pa.nombre
	 FROM países AS pa 
	 INNER JOIN ciudades AS ci ON pa.idpaís = ci.idpaís
	 WHERE ci.idciudad = p.idciudad) AS país
FROM corredores AS c
INNER JOIN premioscorredores AS pc ON c.idcorredor = pc.idcorredor
INNER JOIN participantes AS p ON c.idcorredor = p.idparticipante
WHERE (SELECT COUNT(pco.idcorredor)
	   FROM premioscorredores AS pco
	   WHERE pco.idcorredor = c.idcorredor) > 1 AND (SELECT idpremio
													 FROM premios
													 WHERE nombre = 'Maillot Verde')
													 IN (SELECT idpremio
														 FROM premioscorredores AS pcor
														 WHERE pcor.idcorredor = c.idcorredor)
	  AND p.idciudad IN (SELECT idciudad
						 FROM ciudades
						 WHERE idpaís = (SELECT idpaís
										 FROM países
										 WHERE nombre = 'Colombia')
						)
GROUP BY nombreCompleto, p.idCiudad

--5 ¿Cuántos patrocinadores han patrocinado todas las ediciones de la Vuelta España?

SELECT COUNT(p.idpatrocinador) OVER(PARTITION BY p.idpatrocinador) AS numeroPatrocinadores
FROM patrocinadorescarreras AS p
WHERE (SELECT COUNT(pa.idpatrocinador)
	   FROM patrocinadorescarreras AS pa
	   WHERE pa.idpatrocinador = p.idpatrocinador) = 3


--6 ¿Cuál es el nombre completo, incluyendo nacionalidad, del corredor que ha 
--obtenido el mejor tiempo de finalización en la etapa 3 de la edición 2022 de la 
--vuelta España y el numero de etapas ganadas por tiempo en la Vuelta España a lo largo 
--de su carrera?

SELECT (SELECT CONCAT(p.primerNombre,' ',p.primerApellido)
	   	FROM participantes AS p
		WHERE p.idparticipante = c.idcorredor
	   ) AS nombreCompleto ,
	   (SELECT pa.nombre
		FROM ciudades AS ci
		INNER JOIN países AS pa ON ci.idpaís = pa.idpaís
		INNER JOIN participantes AS p ON ci.idciudad = p.idciudad
		WHERE p.idparticipante = c.idcorredor ) AS países, 
		(SELECT COUNT(re.idcorredor)
		 FROM resultados AS re
		 WHERE re.idresultado IN (SELECT pr.idresultado
								  FROM premiosresultados AS pr
								  WHERE re.idtiporesultado = (SELECT idtiporesultado
															  FROM tiposderesultados
															  WHERE nombre = 'Tiempo')
								 )
		 AND re.idcorredor = c.idcorredor
		) AS numeroEtapas
FROM corredores AS c
INNER JOIN resultados AS r ON c.idcorredor = r.idcorredor
INNER JOIN etapas AS e ON e.idetapa = r.idetapa
INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
WHERE ca.edición = '2022' AND e.idetapa = 24 
AND r.idresultado IN (SELECT pr.idresultado
					  FROM premiosresultados AS pr
					  WHERE r.idtiporesultado = (SELECT idtiporesultado
												 FROM tiposderesultados
												 WHERE nombre = 'Tiempo')
					 )
GROUP BY c.idcorredor
LIMIT 1

--7 ¿Cuántos corredores colombianos han participado en alguna edicion
--de la Vuelta España, son de la década de los 90 y han obtenido un resultado 
--de tipo punto?

SELECT COUNT(c.idcorredor) AS numerocolombianos
FROM (SELECT c.idcorredor idcorredor
	  FROM corredores AS c
	  INNER JOIN participantes AS p ON c.idcorredor = p.idparticipante
	  WHERE p.idciudad IN (SELECT idciudad
						   FROM ciudades
					 	   WHERE idpaís IN (SELECT idpaís
									  		FROM países
									  		WHERE nombre = 'Colombia')
						  )
	  AND p.fechanacimiento BETWEEN '1990-01-01' AND '1999-12-31'
	 ) AS c
WHERE c.idcorredor IN (SELECT r.idcorredor
					   FROM resultados AS r
					   WHERE r.idtiporesultado IN (SELECT idtiporesultado
												   FROM tiposderesultados
												   WHERE nombre = 'Punto')
					  )

--8 ¿Cuál es el nombre de los corredores con un tipo de resultado 
--tipo punto que no han ganado un maillot?

SELECT (SELECT CONCAT(p.primerNombre,' ',p.primerApellido)
	    FROM participantes AS p
	    WHERE p.idparticipante = c.idcorredor) AS nombre
FROM corredores AS c
INNER JOIN resultados AS r ON c.idcorredor = r.idresultado
WHERE r.idresultado NOT IN (SELECT idresultado
						    FROM premiosresultados)

--9 ¿Cuáles son los nombres de los patrocinadores de cada corredor?

SELECT (SELECT p.nombre
	    FROM patrocinadores AS p
	    WHERE p.idpatrocinador = pc.idpatrocinador) AS Patrocinador,
		(SELECT CONCAT(pa.primerNombre,' ',pa.primerApellido)
		 FROM participantes AS pa
		 WHERE pa.idparticipante = pc.idcorredor) AS Corredor
FROM patrocinadorescorredores AS pc
ORDER BY Patrocinador

--10 ¿Cuáles son los nombres de los participantes mayores a 25 años que no están en 
--la lista de directores de equipos?

SELECT CONCAT(p.primerNombre,' ', p.primerApellido) AS Nombre, 
	EXTRACT (YEAR FROM AGE(NOW(),p.fechanacimiento)) AS Edad
FROM participantes AS p
WHERE p.idparticipante NOT IN (SELECT iddirector
							   FROM directoresdeequipo)
AND EXTRACT (YEAR FROM AGE(NOW(),p.fechanacimiento)) > 25

--11 ¿Cuántos corredores han participado en la edición 2021 de la vuelta a España?

SELECT COUNT(*) NumeroCorredores
FROM (SELECT r.idcorredor
	  FROM resultados AS r 
	  INNER JOIN etapas AS e ON r.idetapa = e.idetapa
	  INNER JOIN carreras AS c ON e.idcarrera = c.idcarrera
	  WHERE c.edición = '2021'
	  GROUP BY r.idcorredor) AS p

--12 ¿Cuál es la cantidad de premios obtenidos por cada corredor, donde su maillot 
--obtenido sea "Maillot Rojo" de la edición 2023 de la vuetla a España?

SELECT CONCAT(p.primernombre,' ',p.primerapellido ) AS Nombre,
	(SELECT COUNT(pr.idpremio)
	 FROM premiosresultados AS pr
	 INNER JOIN resultados AS r ON pr.idresultado = r.idresultado
	 INNER JOIN etapas AS e ON r.idetapa = e.idetapa
	 INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
	 WHERE pr.idpremio = (SELECT idpremio
						  FROM premios
						  WHERE nombre = 'Maillot Rojo')
	 AND p.idparticipante = r.idcorredor AND ca.edición = '2023'
	 GROUP BY r.idcorredor
	) AS MaillotsRojos
FROM Participantes AS p
WHERE idparticipante IN (SELECT idcorredor
						 FROM corredores)
AND (SELECT COUNT(pr.idpremio)
	 FROM premiosresultados AS pr
	 INNER JOIN resultados AS r ON pr.idresultado = r.idresultado
	 INNER JOIN etapas AS e ON r.idetapa = e.idetapa
	 INNER JOIN carreras AS ca ON e.idcarrera = ca.idcarrera
	 WHERE pr.idpremio = (SELECT idpremio
						  FROM premios
						  WHERE nombre = 'Maillot Rojo')
	 AND p.idparticipante = r.idcorredor AND ca.edición = '2023'
	 GROUP BY r.idcorredor
	) > 0
ORDER BY MaillotsRojos DESC

--13 ¿Cuáles son los nombres de los patrocinadores que han patrocinado una carrera, 
--pero que no han patrocinado un equipo?

SELECT (SELECT p.nombre
	    FROM patrocinadores AS p
	    WHERE p.idpatrocinador = pc.idpatrocinador) AS Patrocinador
FROM patrocinadorescarreras AS pc
INNER JOIN 
(SELECT p.idpatrocinador
 FROM patrocinadores AS p
 WHERE p.idpatrocinador NOT IN (SELECT idpatrocinador
							    FROM patrocinadoresequipos)
) AS p ON pc.idpatrocinador = p.idpatrocinador

--14 ¿Cuáles son los nombres de las ciudades de los corredores que no son ciudad capital 
--de un país?

SELECT (SELECT nombre
	    FROM ciudades c
	    WHERE p.idciudad = c.idciudad)
FROM participantes AS p
WHERE idparticipante IN (SELECT idcorredor
						 FROM corredores)
UNION
SELECT c.nombre
FROM Ciudades AS c
WHERE c.idciudad NOT IN (SELECT idcapital
						 FROM países)

--15 ¿Cuál es el ranking de los corredores por cantidad total de puntos obtenidos en 
--todas las etapas de todas las carreras en las que han participado? Muestra el nombre 
--del corredor y su posición en el ranking.

SELECT NombreCorredor,
    TotalPuntos,
    RANK() OVER (ORDER BY TotalPuntos DESC) AS PosicionRanking
FROM (SELECT CONCAT(p.primerNombre, ' ',p.primerApellido) AS NombreCorredor,
      SUM(puntos.obtenido) AS TotalPuntos
      FROM Participantes p
      JOIN Corredores c ON p.idParticipante = c.idCorredor
      JOIN Resultados r ON c.idCorredor = r.idCorredor
      JOIN Puntos puntos ON r.idResultado = puntos.idPunto
      GROUP BY p.idParticipante, p.primerNombre, p.segundoNombre, p.primerApellido, p.segundoApellido
     ) AS Totales
ORDER BY TotalPuntos DESC;


--16 ¿Cuál es la cantidad total de premios obtenidos por cada corredor en la última 
--edición de la Vuelta a España en la que han participado? Muestra el nombre del corredor 
--y la cantidad total de premios.

SELECT CONCAT(p.primerNombre, ' ', COALESCE(p.segundoNombre, ''), ' ', p.primerApellido, ' ', COALESCE(p.segundoApellido, '')) AS NombreCorredor,
    COUNT(pc.idPremio) AS CantidadTotalPremios
FROM Participantes p
JOIN Corredores c ON p.idParticipante = c.idCorredor
JOIN PremiosCorredores pc ON c.idCorredor = pc.idCorredor
JOIN Premios pr ON pc.idPremio = pr.idPremio
JOIN Resultados r ON pc.idCorredor = r.idCorredor
JOIN Etapas e ON r.idEtapa = e.idEtapa
JOIN Carreras ca ON e.idCarrera = ca.idCarrera
WHERE ca.edición = (SELECT 
            		MAX(ca2.edición)
      				FROM Carreras ca2
        			JOIN Etapas e2 ON ca2.idCarrera = e2.idCarrera
        			JOIN Resultados r2 ON e2.idEtapa = r2.idEtapa
        			WHERE r2.idCorredor = c.idCorredor 
    				)
GROUP BY p.idParticipante, p.primerNombre, p.segundoNombre, p.primerApellido, p.segundoApellido
ORDER BY CantidadTotalPremios DESC;


--17 ¿Cuál es el tiempo promedio de finalización de cada etapa en cada 
--carrera? Muestra la edición de la carrera, el número de etapa y el tiempo promedio 
--de finalización.

SELECT c.edición,
	e.idetapa, AVG(t.tiempofinalización) tiempoPromedio
FROM Carreras AS c
JOIN Etapas AS e ON c.idCarrera = e.idCarrera
JOIN Resultados AS r ON r.idEtapa = e.idEtapa
JOIN Tiempos AS t ON r.idResultado = t.idTiempo
GROUP BY c.edición , e.idEtapa
ORDER BY c.edición , e.idEtapa

--18 ¿Cuál es la diferencia de tiempo entre el primer y el último corredor en cada 
--etapa de cada carrera? Muestra la edicion de la carrera, el número de etapa y la 
--diferencia de tiempo.

SELECT c.edición,
	e.idetapa AS Etapa,
	MAX(t.tiempofinalización)-MIN(t.tiempofinalización) AS diferenciaTiempo
FROM Carreras AS c
JOIN Etapas AS e ON c.idcarrera = e.idcarrera
JOIN Resultados AS r ON e.idetapa = r.idetapa
JOIN Tiempos AS t ON r.idresultado = t.idtiempo
GROUP BY c.edición , e.idetapa
ORDER BY c.edición , e.idetapa

--19 ¿Cuál es el porcentaje de corredores que han ganado un “Maillot Rojo” en cada 
--carrera? Muestra la edicion de la carrera y el porcentaje de corredores.

SELECT  c.edición,
    (COUNT(DISTINCT pc.idCorredor) * 100.0 / tc.TotalCorredores) AS PorcentajeGanadoresMaillotRojo
FROM  Premios p
JOIN PremiosCorredores pc ON p.idPremio = pc.idPremio
JOIN Resultados r ON pc.idCorredor = r.idCorredor
JOIN Etapas e ON r.idEtapa = e.idEtapa
JOIN Carreras c ON e.idCarrera = c.idCarrera
JOIN (SELECT e.idCarrera,
            COUNT(DISTINCT r.idCorredor) AS TotalCorredores
        FROM Etapas e
        JOIN Resultados r ON e.idEtapa = r.idEtapa
        GROUP BY e.idCarrera
     ) AS tc ON e.idCarrera = tc.idCarrera
WHERE p.nombre = 'Maillot Rojo'
GROUP BY c.edición, tc.TotalCorredores
ORDER BY c.edición;

--20 ¿Cuál es la duración total de patrocinio de cada patrocinador para cada 
--equipo que ha patrocinado? Muestra el nombre del patrocinador, el nombre del equipo
--y la duración total del patrocinio en días.

SELECT p.nombre AS NombrePatrocinador, e.nombre AS NombreEquipo,
    SUM(EXTRACT (YEAR FROM AGE(COALESCE(pe.fechaFinalización, NOW()), pe.fechaInicio)))*365 AS DuracionTotalPatrocinio
FROM PatrocinadoresEquipos pe
JOIN Patrocinadores p ON pe.idPatrocinador = p.idPatrocinador
JOIN Equipos e ON pe.idEquipo = e.idEquipo
WHERE EXTRACT (YEAR FROM AGE(COALESCE(pe.fechaFinalización, NOW()), pe.fechaInicio))*365 > 0
GROUP BY p.nombre, e.nombre
ORDER BY p.nombre;

		 