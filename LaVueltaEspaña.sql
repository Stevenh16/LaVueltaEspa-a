CREATE TABLE Ciudades(
	idCiudad INT NOT NULL PRIMARY KEY,
	idPaís INT NOT NULL,
	nombre VARCHAR(250) NOT NULL
);
CREATE TABLE Países(
	idPaís INT NOT NULL PRIMARY KEY,
	idCapital INT NOT NULL,
	nombre VARCHAR(250) NOT NULL,
	FOREIGN KEY (idCapital) REFERENCES Ciudades(idCiudad)
);

CREATE TABLE Participantes(
	idParticipante INT NOT NULL PRIMARY KEY,
	idCiudad INT NOT NULL,
	primerNombre VARCHAR(250) NOT NULL,
	segundoNombre VARCHAR(250) NULL,
	primerApellido VARCHAR(250) NOT NULL,
	segundoApellido VARCHAR(250) NULL,
	fechaNacimiento DATE NOT NULL,
	FOREIGN KEY (idCiudad) REFERENCES Ciudades(idCiudad)
);
CREATE TABLE Corredores(
	idCorredor INT NOT NULL PRIMARY KEY,
	FOREIGN KEY (idCorredor) REFERENCES Participantes(idParticipante)
);
CREATE TABLE DirectoresDeEquipo(
	idDirector INT NOT NULL PRIMARY KEY,
	FOREIGN KEY (idDirector) REFERENCES Participantes(idParticipante)
);
CREATE TABLE Carreras(
	idCarrera INT NOT NULL PRIMARY KEY,
	edición VARCHAR(250) NOT NULL,
	distancia FLOAT NOT NULL,
	fechaInicio DATE NOT NULL,
	fechaFinalización DATE NOT NULL
);
CREATE TABLE Patrocinadores(
	idPatrocinador INT NOT NULL PRIMARY KEY,
	nombre  VARCHAR(250) NOT NULL,
	descripción VARCHAR(400) NOT NULL
);
CREATE TABLE PatrocinadoresCarreras(
	idPatrocinador INT NOT NULL,
	idCarrera INT NOT NULL,
	PRIMARY KEY (idPatrocinador, idCarrera),
	FOREIGN KEY (idPatrocinador) REFERENCES Patrocinadores(idPatrocinador),
	FOREIGN KEY (idCarrera) REFERENCES Carreras(idCarrera)
);
CREATE TABLE PatrocinadoresCorredores(
	idPatrocinio INT NOT NULL PRIMARY KEY,
	idPatrocinador INT NOT NULL,
	idCorredor INT NOT NULL,
	fechaInicio DATE NOT NULL,
	fechaFinalización DATE NULL,
	FOREIGN KEY (idPatrocinador) REFERENCES Patrocinadores(idPatrocinador),
	FOREIGN KEY (idCorredor) REFERENCES Corredores(idCorredor)
);
CREATE TABLE Equipos(
	idEquipo INT NOT NULL PRIMARY KEY,
	idPaís INT NOT NULL,
	nombre VARCHAR(250) NOT NULL,
	códigoUCI VARCHAR(100) NOT NULL,
	añoFundación INT NOT NULL,
	FOREIGN KEY (idPaís) REFERENCES Países(idPaís)
);
CREATE TABLE CorredoresDeEquipos(
	idPertenecia INT NOT NULL PRIMARY KEY,
	idCorredor INT NOT NULL,
	idEquipo INT NOT NULL,
	fechaInicio DATE NOT NULL,
	fechaFinalización DATE NULL,
	numeroJugador INT NOT NULL,
	FOREIGN KEY (idCorredor) REFERENCES Corredores(idCorredor),
	FOREIGN KEY (idEquipo) REFERENCES Equipos(idEquipo)
);
CREATE TABLE DirectoresDeLosEquipos(
	idGerencia INT NOT NULL PRIMARY KEY,
	idDirector INT NOT NULL,
	idEquipo INT NOT NULL,
	fechaInicio DATE NOT NULL,
	fechaFinalización DATE NULL,
	FOREIGN KEY (idDirector) REFERENCES DirectoresDeEquipo(idDirector),
	FOREIGN KEY (idEquipo) REFERENCES Equipos(idEquipo)
);
CREATE TABLE PatrocinadoresEquipos(
	idPatrocinio INT NOT NULL PRIMARY KEY,
	idPatrocinador INT NOT NULL,
	idEquipo INT NOT NULL,
	fechaInicio DATE NOT NULL,
	fechaFinalización DATE NULL
);
CREATE TABLE EquiposCarreras(
	idEquipo INT NOT NULL,
	idCarrera INT NOT NULL,
	PRIMARY KEY(idEquipo, idCarrera),
	FOREIGN KEY (idEquipo) REFERENCES Equipos(idEquipo),
	FOREIGN KEY (idCarrera) REFERENCES Carreras(idCarrera)
);
CREATE TABLE Etapas(
	idEtapa INT NOT NULL PRIMARY KEY,
	idCarrera INT NOT NULl,
	idCiudadInicio INT NOT NULL,
	idCiudadFinal INT NOT NULL,
	distanciaTotal FLOAT NOT NULL,
	altitudMaxima FLOAT NOT NULL,
	altitudMinima FLOAT NOT NULL,
	fechaRealizacion DATE NOT NULL,
	FOREIGN KEY (idCarrera) REFERENCES Carreras(idCarrera),
	FOREIGN KEY (idCiudadInicio) REFERENCES Ciudades(idCiudad),
	FOREIGN KEY (idCiudadFinal) REFERENCES Ciudades(idCiudad)
);
CREATE TABLE TiposDeResultados(
	idTipoResultado INT NOT NULL PRIMARY KEY,
	nombre VARCHAR(250) NOT NULL
);
CREATE TABLE Resultados(
	idResultado INT NOT NULL PRIMARY KEY,
	idEtapa INT NOT NULL,
	idCorredor INT NOT NULL,
	idTipoResultado INT NOT NULL,
	FOREIGN KEY (idCorredor) REFERENCES Corredores(idCorredor),
	FOREIGN KEY (idTipoResultado) REFERENCES TiposDeResultados(idTipoResultado),
	FOREIGN KEY (idEtapa) REFERENCES Etapas(idEtapa)
);
CREATE TABLE Calificaciones(
	idCalificación INT NOT NULL PRIMARY KEY,
	nombre VARCHAR(250) NOT NULL,
	descripción VARCHAR(400) NOT NULL
);
CREATE TABLE Premios(
	idPremio INT NOT NULL PRIMARY KEY,
	idCalificación INT NOT NULL,
	nombre VARCHAR(250) NOT NULL,
	descripción VARCHAR(250) NOT NULL,
	FOREIGN KEY (idCalificación) REFERENCES Calificaciones(idCalificación)
);
CREATE TABLE PremiosCorredores(
	idPremiación INT NOT NULL PRIMARY KEY,
	idPremio INT NOT NULL,
	idCorredor INT NOT NULL,
	FOREIGN KEY (idPremio) REFERENCES Premios(idPremio),
	FOREIGN KEY (idCorredor) REFERENCES Corredores(idCorredor)
);
CREATE TABLE TipoDePuntos(
	idTipoPunto INT NOT NULL PRIMARY KEY,
	nombre VARCHAR(250) NOT NULL
);
CREATE TABLE Puntos(
	idPunto INT NOT NULL PRIMARY KEY,
	idTipoPunto INT NOT NULL,
	penalización INT NULL,
	obtenido INT NOT NULL,
	FOREIGN KEY (idPunto) REFERENCES Resultados(idResultado),
	FOREIGN KEY (idTipoPunto) REFERENCES TipoDePuntos(idTipoPunto)
);
CREATE TABLE Tiempos(
	idTiempo INT NOT NULL PRIMARY KEY,
	tiempoFinalización TIME NOT NULL,
	tiempoBonificación TIME NULL,
	tiempoPenalización TIME NULL,
	FOREIGN KEY (idTiempo) REFERENCES Resultados(idResultado)
);
CREATE TABLE PremiosResultados(
	idResultado INT NOT NULL,
	idPremio INT NOT NULL,
	PRIMARY KEY(idResultado,idPremio),
	FOREIGN KEY (idResultado) REFERENCES Resultados(idResultado),
	FOREIGN KEY (idPremio) REFERENCES Premios(idPremio)
);